import 'package:get/get.dart';

import '../../../core/api_client.dart';
import '../../../data/models/cliente_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../routes/app_routes.dart';
import '../widgets/forms_dialogs.dart';

class ClientesController extends GetxController {
  ClientesController(this._repo);
  final AdminRepository _repo;

  final lista = <ClienteModel>[].obs;
  final busca = ''.obs;
  final loading = true.obs;
  final erro = RxnString();

  @override
  void onInit() {
    super.onInit();
    debounce(busca, (_) => carregar(), time: const Duration(milliseconds: 400));
    carregar();
  }

  Future<void> carregar() async {
    loading.value = true;
    erro.value = null;
    try {
      lista.assignAll(await _repo.clientes(busca: busca.value));
    } on ApiException catch (e) {
      erro.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  Future<void> abrir(int id) async {
    await Get.toNamed(Routes.adminCliente, arguments: id);
    carregar();
  }

  Future<void> novo() async {
    final c = await mostrarDialogNovoCliente(_repo.criarCliente);
    if (c != null) abrir(c.id);
  }
}
