import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'app/app_theme.dart';
import 'app/sync_status_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'data/supply_repository.dart';
import 'features/identity/services/identity_service.dart';
import 'features/mesh/relay_service.dart';
import 'features/pod/pod_service.dart';
import 'features/risk/route_risk_controller.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/hub_session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repo = SupplyRepository();
  await repo.init();

  final identity = IdentityService(repository: repo);
  await identity.init();

  Get.put<SupplyRepository>(repo, permanent: true);
  Get.put<IdentityService>(identity, permanent: true);

  final auth = AuthController();
  await auth.hydrateBeforeFirstFrame();
  Get.put<AuthController>(auth, permanent: true);

  final hub = HubSessionController();
  await hub.loadPersisted();
  Get.put<HubSessionController>(hub, permanent: true);

  final meshRelay = MeshRelayService(repository: repo);
  await meshRelay.hydrateFromDisk();

  final pod = PodService(identity, repo);

  final routeRisk = RouteRiskController();
  await routeRisk.init();
  if (kDebugMode && routeRisk.loadError != null) {
    debugPrint('Route ML: ${routeRisk.loadError}');
  }

  runApp(
    DigitalDeltaApp(
      repo: repo,
      identity: identity,
      meshRelay: meshRelay,
      pod: pod,
      routeRisk: routeRisk,
    ),
  );
}

class DigitalDeltaApp extends StatelessWidget {
  const DigitalDeltaApp({
    super.key,
    required this.repo,
    required this.identity,
    required this.meshRelay,
    required this.pod,
    required this.routeRisk,
  });

  final SupplyRepository repo;
  final IdentityService identity;
  final MeshRelayService meshRelay;
  final PodService pod;
  final RouteRiskController routeRisk;

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return MultiProvider(
      providers: [
        Provider<SupplyRepository>.value(value: repo),
        ChangeNotifierProvider<IdentityService>.value(value: identity),
        ChangeNotifierProvider<MeshRelayService>.value(value: meshRelay),
        Provider<PodService>.value(value: pod),
        ChangeNotifierProvider<RouteRiskController>.value(value: routeRisk),
        ChangeNotifierProvider(create: (_) => SyncStatusController()),
      ],
      child: GetMaterialApp(
        title: 'Digital Delta',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        initialRoute: auth.isLoggedIn.value ? AppRoutes.home : AppRoutes.login,
        getPages: AppPages.pages,
        defaultTransition: Transition.cupertino,
      ),
    );
  }
}
