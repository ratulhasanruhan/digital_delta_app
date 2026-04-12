import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app_theme.dart';
import 'app/sync_status_controller.dart';
import 'data/supply_repository.dart';
import 'features/identity/services/identity_service.dart';
import 'features/mesh/relay_service.dart';
import 'features/pod/pod_service.dart';
import 'features/risk/route_risk_controller.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/hub_session_controller.dart';
import 'presentation/controllers/shell_controller.dart';
import 'presentation/views/auth/otp_login_view.dart';
import 'presentation/views/shell/main_shell_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repo = SupplyRepository();
  await repo.init();

  final identity = IdentityService(repository: repo);
  await identity.init();

  final meshRelay = MeshRelayService(repository: repo);
  await meshRelay.hydrateFromDisk();

  final pod = PodService(identity, repo);

  final routeRisk = RouteRiskController();
  await routeRisk.init();
  if (kDebugMode && routeRisk.loadError != null) {
    debugPrint('Route ML: ${routeRisk.loadError}');
  }

  final shell = ShellController();
  final auth = AuthController(identity, shell);
  await auth.hydrateBeforeFirstFrame();

  final hub = HubSessionController();
  await hub.loadPersisted();

  runApp(
    MultiProvider(
      providers: [
        Provider<SupplyRepository>.value(value: repo),
        ChangeNotifierProvider<IdentityService>.value(value: identity),
        ChangeNotifierProvider<MeshRelayService>.value(value: meshRelay),
        Provider<PodService>.value(value: pod),
        ChangeNotifierProvider<RouteRiskController>.value(value: routeRisk),
        ChangeNotifierProvider(create: (_) => SyncStatusController()),
        ChangeNotifierProvider<ShellController>.value(value: shell),
        ChangeNotifierProvider<HubSessionController>.value(value: hub),
        ChangeNotifierProvider<AuthController>.value(value: auth),
      ],
      child: const DigitalDeltaApp(),
    ),
  );
}

class DigitalDeltaApp extends StatelessWidget {
  const DigitalDeltaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();
    return MaterialApp(
      title: 'Digital Delta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      navigatorObservers: [_AuthNavigatorObserver(auth)],
      initialRoute: auth.isLoggedIn ? '/shell' : '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute<void>(
              builder: (_) => const OtpLoginView(),
              settings: settings,
            );
          case '/shell':
            return MaterialPageRoute<void>(
              builder: (_) => const MainShellView(),
              settings: settings,
            );
          default:
            return MaterialPageRoute<void>(
              builder: (_) => const OtpLoginView(),
              settings: settings,
            );
        }
      },
    );
  }
}

/// Observer that redirects when auth state changes.
class _AuthNavigatorObserver extends NavigatorObserver {
  final AuthController auth;
  bool _isHandlingAuthChange = false;

  _AuthNavigatorObserver(this.auth) {
    auth.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (_isHandlingAuthChange) return;

    final isLoggedIn = auth.isLoggedIn;
    final navigator = this.navigator;
    if (navigator == null) return;

    _isHandlingAuthChange = true;
    try {
      final currentRoute = navigator.widget.pages.isEmpty
          ? null
          : navigator.widget.pages.last.name;

      if (isLoggedIn && currentRoute != '/shell') {
        navigator.pushReplacementNamed('/shell');
      } else if (!isLoggedIn && currentRoute != '/login') {
        navigator.pushReplacementNamed('/login');
      }
    } finally {
      _isHandlingAuthChange = false;
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {}

  @override
  void didPop(Route route, Route? previousRoute) {}
}

