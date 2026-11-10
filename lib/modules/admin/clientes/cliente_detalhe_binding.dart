import 'package:get/get.dart';

import '../../../data/repositories/admin_repository.dart';
import 'cliente_detalhe_controller.dart';

/// Registra as dependências desta tela. Os controllers são criados só quando a tela
/// abre e descartados quando ela fecha.
class ClienteDetalheBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ClienteDetalheController(Get.find<AdminRepository>()));
  }
}
