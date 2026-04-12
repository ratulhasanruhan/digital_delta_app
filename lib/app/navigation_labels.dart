import 'operator_destination.dart';

/// User-facing names (module codes only where useful for judges).
class NavLabels {
  NavLabels._();

  static String title(OperatorDestination d) => switch (d) {
        OperatorDestination.dashboard => 'Operations',
        OperatorDestination.identity => 'Security & identity',
        OperatorDestination.supply => 'Supply ledger',
        OperatorDestination.relay => 'Encrypted relay',
        OperatorDestination.map => 'Routes & map',
        OperatorDestination.pod => 'Proof of delivery',
        OperatorDestination.triage => 'Priority & deadlines',
        OperatorDestination.modules => 'Flood & route risk',
        OperatorDestination.fleet => 'Fleet & handoff',
        OperatorDestination.mesh => 'Peer sync',
        OperatorDestination.tools => 'All tools',
      };

  static String drawerLabel(OperatorDestination d) => switch (d) {
        OperatorDestination.dashboard => 'Home',
        OperatorDestination.identity => 'Security',
        OperatorDestination.supply => 'Supply',
        OperatorDestination.relay => 'Relay',
        OperatorDestination.map => 'Map',
        OperatorDestination.pod => 'Delivery',
        OperatorDestination.triage => 'Priorities',
        OperatorDestination.modules => 'Flood risk',
        OperatorDestination.fleet => 'Fleet',
        OperatorDestination.mesh => 'Sync',
        OperatorDestination.tools => 'More',
      };

  static String moduleTag(OperatorDestination d) => switch (d) {
        OperatorDestination.dashboard => '',
        OperatorDestination.identity => 'M1',
        OperatorDestination.supply => 'M2',
        OperatorDestination.relay => 'M3',
        OperatorDestination.map => 'M4',
        OperatorDestination.pod => 'M5',
        OperatorDestination.triage => 'M6',
        OperatorDestination.modules => 'M7',
        OperatorDestination.fleet => 'M8',
        OperatorDestination.mesh => 'M2.4',
        OperatorDestination.tools => '',
      };
}
