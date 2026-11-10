import 'package:get/get.dart';

import '../../../data/repositories/admin_repository.dart';
import 'material_detalhe_controller.dart';

/// Registra as dependências desta tela. Os controllers são criados só quando a tela
/// abre e descartados quando ela fecha.
class MaterialDetalheBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MaterialDetalheController(Get.find<AdminRepository>()));
  }
}
