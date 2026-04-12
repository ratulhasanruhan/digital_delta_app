import 'package:flutter/material.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:provider/provider.dart';

import 'app/app_theme.dart';
import 'app/session_controller.dart';
import 'core/rbac.dart';
import 'app/sync_status_controller.dart';
import 'data/supply_repository.dart';
import 'features/identity/services/identity_service.dart';
import 'features/mesh/ble_mesh_controller.dart';
import 'features/mesh/relay_service.dart';
import 'features/pod/pod_service.dart';
import 'ui/app_entry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  OrtEnv.instance.init();
  final repository = SupplyRepository();
  await repository.init();
  final identity = IdentityService(repository: repository);
  await identity.init();
  repository.bindAccessChecker((p) => identity.role.can(p));
  final sync = SyncStatusController();
  final relay = MeshRelayService(repository: repository);
  await relay.hydrateFromDisk();
  final pod = PodService(identity, repository);
  final bleMesh = BleMeshController(repository: repository);
  final session = SessionController(identity);
  await session.load();

  runApp(
    MultiProvider(
      providers: [
        Provider<SupplyRepository>.value(value: repository),
        ChangeNotifierProvider<IdentityService>.value(value: identity),
        ChangeNotifierProvider<SessionController>.value(value: session),
        ChangeNotifierProvider<SyncStatusController>.value(value: sync),
        ChangeNotifierProvider<MeshRelayService>.value(value: relay),
        ChangeNotifierProvider<BleMeshController>.value(value: bleMesh),
        Provider<PodService>.value(value: pod),
      ],
      child: const DigitalDeltaApp(),
    ),
  );
}

class DigitalDeltaApp extends StatelessWidget {
  const DigitalDeltaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Delta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const AppEntry(),
    );
  }
}
