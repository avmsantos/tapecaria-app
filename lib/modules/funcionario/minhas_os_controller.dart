import 'package:get/get.dart';

import '../../core/api_client.dart';
import '../../data/models/apontamento_model.dart';
import '../../data/models/ordem_servico_model.dart';
import '../../data/repositories/funcionario_repository.dart';
import '../../routes/app_routes.dart';

class MinhasOsController extends GetxController {
  MinhasOsController(this._repo);
  final FuncionarioRepository _repo;

  final lista = <OrdemServicoModel>[].obs;
  final atual = Rxn<ApontamentoModel>();
  final loading = true.obs;
  final erro = RxnString();

  List<OrdemServicoModel> get meus => lista.where((o) => !o.livre).toList();
  List<OrdemServicoModel> get disponiveis => lista.where((o) => o.livre).toList();

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  Future<void> carregar() async {
    loading.value = true;
    erro.value = null;
    try {
      lista.assignAll(await _repo.listar());
      atual.value = await _repo.atual();
    } on ApiException catch (e) {
      erro.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  Future<void> abrir(int osId) async {
    await Get.toNamed(Routes.funcionarioOs, arguments: osId);
    carregar(); // ao voltar, atualiza a lista
  }
}
