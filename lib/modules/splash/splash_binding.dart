import 'package:get/get.dart';

import '../auth/auth_controller.dart';
import 'splash_controller.dart';

/// Registra as dependências desta tela. Os controllers são criados só quando a tela
/// abre e descartados quando ela fecha.
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController(Get.find<AuthController>()));
  }
}
