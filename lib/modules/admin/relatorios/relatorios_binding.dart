import 'package:get/get.dart';

import '../../../data/repositories/admin_repository.dart';
import 'relatorios_controller.dart';

/// Registra as dependências desta tela. Os controllers são criados só quando a tela
/// abre e descartados quando ela fecha.
class RelatoriosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RelatoriosController(Get.find<AdminRepository>()));
  }
}
