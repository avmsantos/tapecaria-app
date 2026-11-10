import 'package:get/get.dart';

import '../../../data/repositories/admin_repository.dart';
import 'os_admin_controller.dart';

/// Registra as dependências desta tela. Os controllers são criados só quando a tela
/// abre e descartados quando ela fecha.
class OsAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OsAdminController(Get.find<AdminRepository>()));
  }
}
