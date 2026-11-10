import 'package:get/get.dart';

import '../../../data/repositories/admin_repository.dart';
import '../agenda/agenda_controller.dart';
import '../clientes/clientes_controller.dart';
import '../ordens/ordens_controller.dart';
import '../painel/admin_home_controller.dart';
import 'admin_shell_controller.dart';

/// Registra as dependências desta tela. Os controllers são criados só quando a tela
/// abre e descartados quando ela fecha.
class AdminShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminShellController());
    Get.lazyPut(() => AdminHomeController(Get.find<AdminRepository>()));
    Get.lazyPut(() => AgendaController(Get.find<AdminRepository>()));
    Get.lazyPut(() => OrdensController(Get.find<AdminRepository>()));
    Get.lazyPut(() => ClientesController(Get.find<AdminRepository>()));
  }
}
