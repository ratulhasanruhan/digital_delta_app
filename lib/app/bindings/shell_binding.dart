import 'package:get/get.dart';

import '../../presentation/controllers/shell_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShellController>(ShellController.new, fenix: true);
  }
}
