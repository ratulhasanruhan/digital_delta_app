import 'package:get/get.dart';

/// Bottom navigation + section title for the main shell.
class ShellController extends GetxController {
  final RxInt currentTab = 0.obs;

  static const titles = <String>[
    'Dashboard',
    'Relief supplies',
    'Drone ops',
    'Field hospital',
  ];

  String get title =>
      currentTab.value >= 0 && currentTab.value < titles.length
          ? titles[currentTab.value]
          : 'Digital Delta';

  void selectTab(int index) {
    if (index < 0 || index >= titles.length) return;
    currentTab.value = index;
  }
}
