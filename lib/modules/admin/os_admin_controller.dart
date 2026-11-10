import 'package:get/get.dart';

import '../../core/api_client.dart';
import '../../data/models/funcionario_model.dart';
import '../../data/models/ordem_servico_model.dart';
import '../../data/repositories/admin_repository.dart';
import 'widgets/forms_dialogs.dart';

class OsAdminController extends GetxController {
  OsAdminController(this._repo);
  final AdminRepository _repo;

  late final int osId = Get.arguments as int;

  final os = Rxn<OrdemServicoModel>();
  final ultimoMovimento = Rxn<String>(); // 'entrada' | 'saida' | null
  final loading = true.obs;
  final acting = false.obs;
  final erro = RxnString();

  bool get veiculoNaLoja => ultimoMovimento.value == 'entrada';

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  Future<void> carregar({bool silencioso = false}) async {
    if (!silencioso) loading.value = true;
    erro.value = null;
    try {
      os.value = await _repo.detalheOs(osId);
      ultimoMovimento.value = await _repo.ultimoMovimentoVeiculo(osId);
    } on ApiException catch (e) {
      erro.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  Future<bool> _executar(Future<void> Function() acao, {String? sucesso}) async {
    if (acting.value) return false;
    acting.value = true;
    try {
      await acao();
      await carregar(silencioso: true);
      if (sucesso != null) Get.snackbar('Pronto', sucesso, snackPosition: SnackPosition.BOTTOM);
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Atenção', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      acting.value = false;
    }
  }

  Future<void> mudarStatus(String status) =>
      _executar(() => _repo.atualizarStatusOs(osId, status), sucesso: 'Status atualizado.');

  Future<void> registrarEntrada() =>
      _executar(() => _repo.entradaVeiculo(osId), sucesso: 'Entrada do veículo registrada.');

  Future<void> registrarSaida(String quemRetirou) =>
      _executar(() => _repo.saidaVeiculo(osId, quemRetirou), sucesso: 'Saída do veículo registrada.');

  Future<void> agendar() async {
    final ok = await mostrarDialogAgendar((tipo, quando) => _repo.agendar(osId, tipo, quando));
    if (ok == true) {
      await carregar(silencioso: true);
      Get.snackbar('Pronto', 'Agendamento salvo.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> marcarAgendamento(int agendamentoId, String status) => _executar(
        () => _repo.atualizarAgendamento(agendamentoId, status),
        sucesso: status == 'realizado' ? 'Marcado como realizado.' : 'Agendamento cancelado.',
      );

  Future<void> alterarFuncionarios() async {
    final atual = os.value;
    if (atual == null) return;

    List<FuncionarioModel> todos;
    try {
      todos = await _repo.funcionarios(ativo: true);
    } on ApiException catch (e) {
      Get.snackbar('Atenção', e.message, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final novos = await mostrarDialogFuncionarios(todos, atual.funcionarios.map((f) => f.id).toSet());
    if (novos != null) {
      await _executar(() => _repo.atribuirFuncionarios(osId, novos), sucesso: 'Equipe atualizada.');
    }
  }
}
