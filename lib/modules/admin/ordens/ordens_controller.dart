import 'package:get/get.dart';

import '../../../core/api_client.dart';
import '../../../data/models/ordem_servico_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../routes/app_routes.dart';

class OrdensController extends GetxController {
  OrdensController(this._repo);
  final AdminRepository _repo;

  final lista = <OrdemServicoModel>[].obs;
  final filtro = Rxn<String>(); // null = todas
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
      lista.assignAll(await _repo.listarOs(status: filtro.value));
    } on ApiException catch (e) {
      erro.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  void filtrar(String? status) {
    filtro.value = status;
    carregar();
  }

  Future<void> abrir(int osId) async {
    await Get.toNamed(Routes.adminOsDetalhe, arguments: osId);
    carregar();
  }

  Future<void> nova() async {
    await Get.toNamed(Routes.adminOsNova);
    carregar();
  }
}
