import 'package:get/get.dart';

import '../../core/api_client.dart';
import '../../core/widgets.dart';
import '../../data/models/material_model.dart';
import '../../data/repositories/admin_repository.dart';
import 'widgets/material_dialogs.dart';

class MaterialDetalheController extends GetxController {
  MaterialDetalheController(this._repo);
  final AdminRepository _repo;

  late final int materialId = Get.arguments as int;

  final material = Rxn<MaterialModel>();
  final movimentos = <MovimentacaoMaterialModel>[].obs;
  final loading = true.obs;
  final erro = RxnString();

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  Future<void> carregar({bool silencioso = false}) async {
    if (!silencioso) loading.value = true;
    erro.value = null;
    try {
      // não existe "buscar um material": pegamos a lista e filtramos pelo id
      final todos = await _repo.materiais();
      material.value = todos.firstWhereOrNull((m) => m.id == materialId);
      if (material.value == null) {
        erro.value = 'Material não encontrado (pode ter sido desativado).';
      } else {
        movimentos.assignAll(await _repo.movimentacoesMaterial(materialId));
      }
    } on ApiException catch (e) {
      erro.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  Future<void> entrada() async {
    final m = material.value;
    if (m == null) return;
    final ok = await mostrarDialogMovimento(
      entrada: true,
      nomeMaterial: m.nome,
      unidade: m.unidade,
      custoSugerido: m.custoUnitario,
      onSalvar: (dados) => _repo.entradaMaterial(materialId, dados),
    );
    if (ok == true) {
      await carregar(silencioso: true);
      Get.snackbar('Pronto', 'Entrada registrada.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> saida() async {
    final m = material.value;
    if (m == null) return;
    final ok = await mostrarDialogMovimento(
      entrada: false,
      nomeMaterial: m.nome,
      unidade: m.unidade,
      onSalvar: (dados) => _repo.saidaMaterial(materialId, dados),
    );
    if (ok == true) {
      await carregar(silencioso: true);
      Get.snackbar('Pronto', 'Saída registrada.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> editar() async {
    final m = material.value;
    if (m == null) return;
    final ok = await mostrarDialogMaterial(
      existente: m,
      onSalvar: (dados) async => _repo.atualizarMaterial(materialId, dados),
    );
    if (ok == true) carregar(silencioso: true);
  }

  Future<void> desativar() async {
    final m = material.value;
    if (m == null) return;
    final sim = await confirmar(
      'Desativar material',
      '"${m.nome}" deixa de aparecer na lista. O histórico de movimentações é mantido.',
      confirmarLabel: 'Desativar',
    );
    if (!sim) return;
    try {
      await _repo.atualizarMaterial(materialId, {'ativo': false});
      Get.back();
    } on ApiException catch (e) {
      Get.snackbar('Atenção', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
