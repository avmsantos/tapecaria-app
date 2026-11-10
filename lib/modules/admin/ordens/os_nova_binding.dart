import 'package:get/get.dart';

import '../../../data/repositories/admin_repository.dart';
import 'os_nova_controller.dart';

/// Registra as dependências desta tela. Os controllers são criados só quando a tela
/// abre e descartados quando ela fecha.
class OsNovaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OsNovaController(Get.find<AdminRepository>()));
  }
}
