import 'package:get/get.dart';

import 'auth_controller.dart';
import 'trocar_senha_controller.dart';

/// Registra as dependências desta tela. Os controllers são criados só quando a tela
/// abre e descartados quando ela fecha.
class TrocarSenhaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TrocarSenhaController(Get.find<AuthController>()));
  }
}
