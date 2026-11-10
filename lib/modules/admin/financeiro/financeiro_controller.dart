import 'package:get/get.dart';

import '../../../core/api_client.dart';
import '../../../core/formatters.dart';
import '../../../core/widgets.dart';
import '../../../data/models/financeiro_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../widgets/financeiro_dialogs.dart';

class FinanceiroController extends GetxController {
  FinanceiroController(this._repo);
  final AdminRepository _repo;

  final mes = primeiroDiaDoMes(DateTime.now()).obs;
  final resumo = Rxn<ResumoFinanceiroModel>();
  final despesas = <DespesaModel>[].obs;
  final loading = true.obs;
  final erro = RxnString();

  double get totalDespesas => despesas.fold(0.0, (soma, d) => soma + d.valor);

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  Future<void> carregar() async {
    loading.value = true;
    erro.value = null;
    final de = mes.value;
    final ate = ultimoDiaDoMes(de);
    try {
      resumo.value = await _repo.resumoFinanceiro(de: de, ate: ate);
      despesas.assignAll(await _repo.despesas(de: de, ate: ate));
    } on ApiException catch (e) {
      erro.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  void mesAnterior() {
    mes.value = DateTime(mes.value.year, mes.value.month - 1, 1);
    carregar();
  }

  void proximoMes() {
    mes.value = DateTime(mes.value.year, mes.value.month + 1, 1);
    carregar();
  }

  Future<void> novaDespesa() async {
    final ok = await mostrarDialogDespesa(onSalvar: _repo.criarDespesa);
    if (ok == true) carregar();
  }

  Future<void> editarDespesa(DespesaModel d) async {
    final ok = await mostrarDialogDespesa(
      existente: d,
      onSalvar: (dados) => _repo.atualizarDespesa(d.id, dados),
    );
    if (ok == true) carregar();
  }

  Future<void> excluirDespesa(DespesaModel d) async {
    final sim = await confirmar(
      'Excluir despesa',
      'Excluir "${d.descricao}" (${fmtMoeda(d.valor)})? Isso não pode ser desfeito.',
      confirmarLabel: 'Excluir',
    );
    if (!sim) return;
    try {
      await _repo.excluirDespesa(d.id);
      await carregar();
    } on ApiException catch (e) {
      Get.snackbar('Atenção', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
