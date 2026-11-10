import 'package:get/get.dart';

import '../../data/repositories/funcionario_repository.dart';
import 'minhas_os_controller.dart';

/// Registra as dependências desta tela. Os controllers são criados só quando a tela
/// abre e descartados quando ela fecha.
class MinhasOsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MinhasOsController(Get.find<FuncionarioRepository>()));
  }
}
