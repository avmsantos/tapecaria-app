import 'package:get/get.dart';

import '../../../core/api_client.dart';
import '../../../data/models/material_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../routes/app_routes.dart';
import '../widgets/material_dialogs.dart';

class MateriaisController extends GetxController {
  MateriaisController(this._repo);
  final AdminRepository _repo;

  final lista = <MaterialModel>[].obs;
  final busca = ''.obs;
  final loading = true.obs;
  final erro = RxnString();

  final somenteBaixo = false.obs;

  List<MaterialModel> get filtrados {
    final q = busca.value.trim().toLowerCase();
    return lista.where((m) {
      if (somenteBaixo.value && !m.abaixoDoMinimo) return false;
      return q.isEmpty || m.nome.toLowerCase().contains(q);
    }).toList();
  }

  int get qtdEstoqueBaixo => lista.where((m) => m.abaixoDoMinimo).length;

  double get valorTotalEstoque => lista.fold(0.0, (soma, m) => soma + m.valorEmEstoque);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['somente_baixo'] == true) somenteBaixo.value = true;
    carregar();
  }

  Future<void> carregar() async {
    loading.value = true;
    erro.value = null;
    try {
      lista.assignAll(await _repo.materiais());
    } on ApiException catch (e) {
      erro.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  Future<void> novo() async {
    final ok = await mostrarDialogMaterial(
      onSalvar: (dados) async => _repo.criarMaterial(dados),
    );
    if (ok == true) carregar();
  }

  Future<void> abrir(int id) async {
    await Get.toNamed(Routes.adminMaterial, arguments: id);
    carregar();
  }
}
