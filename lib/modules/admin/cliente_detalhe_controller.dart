import 'package:get/get.dart';

import '../../core/api_client.dart';
import '../../data/models/cliente_model.dart';
import '../../data/repositories/admin_repository.dart';
import '../../routes/app_routes.dart';
import 'widgets/forms_dialogs.dart';

class ClienteDetalheController extends GetxController {
  ClienteDetalheController(this._repo);
  final AdminRepository _repo;

  late final int clienteId = Get.arguments as int;

  final cliente = Rxn<ClienteModel>();
  final loading = true.obs;
  final erro = RxnString();

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  Future<void> carregar() async {
    loading.value = true;
    erro.value = null;
    try {
      cliente.value = await _repo.cliente(clienteId);
    } on ApiException catch (e) {
      erro.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  Future<void> novoVeiculo() async {
    final v = await mostrarDialogNovoVeiculo(
      (dados) => _repo.criarVeiculo({...dados, 'cliente_id': clienteId}),
    );
    if (v != null) carregar();
  }

  Future<void> novaOs() async {
    await Get.toNamed(Routes.adminOsNova, arguments: {'cliente_id': clienteId});
    carregar();
  }

  Future<void> abrirOs(int osId) async {
    await Get.toNamed(Routes.adminOsDetalhe, arguments: osId);
    carregar();
  }
}
