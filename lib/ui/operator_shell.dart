import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/navigation_labels.dart';
import '../app/session_controller.dart';
import '../app/sync_status_controller.dart';
import '../core/rbac.dart';
import '../data/supply_repository.dart';
import '../features/dashboard/operator_dashboard_page.dart';
import '../features/fleet/fleet_hub_page.dart';
import '../features/identity/services/identity_service.dart';
import '../features/identity/ui/identity_hub_page.dart';
import '../features/mesh/relay_hub_page.dart';
import '../app/operator_destination.dart';
import '../features/pod/pod_hub_page.dart';
import '../features/risk/flood_risk_page.dart';
import '../features/mesh/ble_mesh_controller.dart';
import '../features/triage/triage_hub_page.dart';
import '../widgets/connection_status_bar.dart';
import 'compliance_sheet.dart';
import 'interactive_map_page.dart';
import 'mesh_sync_page.dart';
import 'more_tools_page.dart';
import 'supply_crdt_page.dart';

int _bottomNavIndex(OperatorDestination d) {
  switch (d) {
    case OperatorDestination.dashboard:
      return 0;
    case OperatorDestination.map:
      return 1;
    case OperatorDestination.supply:
      return 2;
    case OperatorDestination.mesh:
      return 3;
    case OperatorDestination.tools:
    case OperatorDestination.triage:
    case OperatorDestination.pod:
    case OperatorDestination.fleet:
    case OperatorDestination.relay:
    case OperatorDestination.modules:
    case OperatorDestination.identity:
      return 4;
  }
}

class OperatorShell extends StatefulWidget {
  const OperatorShell({super.key, required this.repository});

  final SupplyRepository repository;

  @override
  State<OperatorShell> createState() => _OperatorShellState();
}

class _OperatorShellState extends State<OperatorShell> with WidgetsBindingObserver {
  OperatorDestination _dest = OperatorDestination.dashboard;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startBleBeacon());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startBleBeacon();
    }
  }

  Future<void> _startBleBeacon() async {
    if (!mounted) return;
    try {
      await context.read<BleMeshController>().startAdvertising();
    } catch (_) {}
  }

  void _go(OperatorDestination d) {
    setState(() => _dest = d);
  }

  void _goHome() {
    setState(() => _dest = OperatorDestination.dashboard);
  }

  Future<void> _confirmLock() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lock session?'),
        content: const Text('You will need your code again to open operations.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Lock')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<SessionController>().lockSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncStatusController>();
    final id = context.watch<IdentityService>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 52,
        leading: IconButton(
          tooltip: 'Home',
          onPressed: _goHome,
          icon: Icon(
            Icons.home_rounded,
            color: _dest == OperatorDestination.dashboard ? cs.primary : cs.onSurfaceVariant,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              NavLabels.title(_dest),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              id.role.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More options',
            icon: Icon(Icons.more_vert_rounded, color: cs.onSurfaceVariant),
            onSelected: (v) {
              if (v == 'checklist') {
                showComplianceSheet(context);
              } else if (v == 'lock') {
                _confirmLock();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'checklist',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.fact_check_outlined),
                  title: Text('Implementation checklist'),
                ),
              ),
              const PopupMenuItem(
                value: 'lock',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.lock_outline),
                  title: Text('Lock app'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConnectionStatusBar(controller: sync),
          Expanded(child: _pageFor(_dest)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _bottomNavIndex(_dest),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (int index) {
          setState(() {
            _dest = switch (index) {
              0 => OperatorDestination.dashboard,
              1 => OperatorDestination.map,
              2 => OperatorDestination.supply,
              3 => OperatorDestination.mesh,
              _ => OperatorDestination.tools,
            };
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: 'Supply',
          ),
          NavigationDestination(
            icon: Icon(Icons.sync_alt_outlined),
            selectedIcon: Icon(Icons.sync_alt_rounded),
            label: 'Sync',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }

  Widget _pageFor(OperatorDestination d) {
    return switch (d) {
      OperatorDestination.dashboard => OperatorDashboardPage(onOpen: _go),
      OperatorDestination.tools => MoreToolsPage(onOpen: _go),
      OperatorDestination.identity => const IdentityHubPage(),
      OperatorDestination.supply => SupplyCrdtPage(repository: widget.repository),
      OperatorDestination.relay => const RelayHubPage(),
      OperatorDestination.map => const InteractiveMapPage(),
      OperatorDestination.pod => const PodHubPage(),
      OperatorDestination.triage => const TriageHubPage(),
      OperatorDestination.modules => FloodRiskPage(
          onOpenSupply: () => _go(OperatorDestination.supply),
        ),
      OperatorDestination.fleet => const FleetHubPage(),
      OperatorDestination.mesh => MeshSyncPage(repository: widget.repository),
    };
  }
}
