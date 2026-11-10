
import 'package:get/get.dart';
import 'package:tapecaria_app/modules/admin/admin_home_controller.dart';
import 'package:tapecaria_app/modules/admin/agenda/agenda_controller.dart';
import 'package:tapecaria_app/modules/admin/clientes/clientes_controller.dart';
import 'package:tapecaria_app/modules/admin/ordens/ordens_controller.dart';

class AdminShellController extends GetxController {
  final index = 0.obs;

  /// Troca de aba e recarrega os dados dela.
  void ir(int i) {
    if (i == index.value) return;
    index.value = i;
    switch (i) {
      case 0:
        Get.find<AdminHomeController>().carregar();
        break;
      case 1:
        Get.find<AgendaController>().carregar();
        break;
      case 2:
        Get.find<OrdensController>().carregar();
        break;
      case 3:
        Get.find<ClientesController>().carregar();
        break;
    }
  }
}
