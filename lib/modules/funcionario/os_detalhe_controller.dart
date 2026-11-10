import 'dart:async';

import 'package:get/get.dart';

import '../../core/api_client.dart';
import '../../core/formatters.dart';
import '../../data/models/apontamento_model.dart';
import '../../data/models/ordem_servico_model.dart';
import '../../data/repositories/funcionario_repository.dart';

class OsDetalheController extends GetxController {
  OsDetalheController(this._repo);
  final FuncionarioRepository _repo;

  late final int osId = Get.arguments as int;

  final os = Rxn<OrdemServicoModel>();
  final apontamento = Rxn<ApontamentoModel>();
  final loading = true.obs;
  final acting = false.obs;
  final erro = RxnString();
  final decorrido = Duration.zero.obs;
  final congelado = false.obs; // true enquanto um diálogo (pausar/finalizar) está aberto

  Timer? _timer;

  bool get aceito => os.value?.aceito ?? false;
  bool get emAndamento => apontamento.value != null;
  bool get pausado => apontamento.value?.pausado ?? false;
  bool get servicoEncerrado => const ['pronto', 'entregue', 'cancelado'].contains(os.value?.status);

  @override
  void onInit() {
    super.onInit();
    carregar();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _atualizarRelogio());
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _atualizarRelogio() {
    if (congelado.value) return;
    final a = apontamento.value;
    if (a != null) decorrido.value = a.trabalhado(DateTime.now());
  }

  /// Mantém o cronômetro parado na tela enquanto o diálogo está aberto.
  Future<T?> comRelogioCongelado<T>(Future<T?> Function() acao) async {
    congelado.value = true;
    try {
      return await acao();
    } finally {
      congelado.value = false;
    }
  }

  Future<void> carregar({bool silencioso = false}) async {
    if (!silencioso) loading.value = true;
    erro.value = null;
    try {
      final d = await _repo.detalhe(osId);
      os.value = d.os;
      apontamento.value = d.apontamentoAberto;
      _atualizarRelogio();
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

  Future<void> aceitar() => _executar(() => _repo.aceitar(osId), sucesso: 'Serviço aceito.');

  Future<void> iniciar() => _executar(() => _repo.iniciar(osId), sucesso: 'Serviço iniciado.');

  Future<void> pausar(String? motivo) => _executar(
        () => _repo.pausar(osId, motivo: (motivo == null || motivo.trim().isEmpty) ? null : motivo.trim()),
        sucesso: 'Serviço pausado.',
      );

  Future<void> retomar() => _executar(() => _repo.retomar(osId), sucesso: 'Serviço retomado.');

  /// [concluirServico] = true marca a OS como pronta; false apenas encerra o turno.
  Future<void> finalizar({required bool concluirServico}) async {
    int segundos = 0;
    final ok = await _executar(() async {
      segundos = await _repo.finalizar(osId, concluirServico: concluirServico);
    });
    if (ok) {
      Get.back(); // volta para a lista
      Get.snackbar(
        concluirServico ? 'Serviço concluído' : 'Turno encerrado',
        'Tempo trabalhado: ${fmtHorasMin(segundos)}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
