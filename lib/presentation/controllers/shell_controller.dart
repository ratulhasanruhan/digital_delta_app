import 'package:flutter/foundation.dart';

/// Bottom navigation + section title for the main shell (Provider + [ChangeNotifier]).
class ShellController extends ChangeNotifier {
  int currentTab = 0;

  static const titles = <String>[
    'Dashboard',
    'Relief supplies',
    'Drone ops',
    'Road risk',
  ];

  String get title =>
      currentTab >= 0 && currentTab < titles.length
          ? titles[currentTab]
          : 'Digital Delta';

  void selectTab(int index) {
    if (index < 0 || index >= titles.length) return;
    if (currentTab == index) return;
    currentTab = index;
    notifyListeners();
  }

  /// Called on sign-out so the next session opens on Dashboard.
  void reset() {
    currentTab = 0;
    notifyListeners();
  }
}
