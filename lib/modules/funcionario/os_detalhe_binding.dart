import 'package:get/get.dart';

import '../../data/repositories/funcionario_repository.dart';
import 'os_detalhe_controller.dart';

/// Registra as dependências desta tela. Os controllers são criados só quando a tela
/// abre e descartados quando ela fecha.
class OsDetalheBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OsDetalheController(Get.find<FuncionarioRepository>()));
  }
}
