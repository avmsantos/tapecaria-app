import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/api_client.dart';
import '../../core/formatters.dart';
import '../../data/models/cliente_model.dart';
import '../../data/models/funcionario_model.dart';
import '../../data/models/veiculo_model.dart';
import '../../data/repositories/admin_repository.dart';
import '../../routes/app_routes.dart';
import 'widgets/forms_dialogs.dart';

class OsNovaController extends GetxController {
  OsNovaController(this._repo);
  final AdminRepository _repo;

  // seleção
  final cliente = Rxn<ClienteModel>();
  final veiculos = <VeiculoModel>[].obs;
  final veiculo = Rxn<VeiculoModel>();
  final funcionarios = <FuncionarioModel>[].obs;
  final selecionados = <int>{}.obs;
  final entrada = Rxn<DateTime>();

  // busca de cliente (bottom sheet)
  final termo = ''.obs;
  final resultados = <ClienteModel>[].obs;
  final buscando = false.obs;

  // campos de texto
  final tituloCtrl = TextEditingController();
  final instrucoesCtrl = TextEditingController();
  final valorCtrl = TextEditingController();

  final saving = false.obs;
  final erro = RxnString();

  @override
  void onInit() {
    super.onInit();
    debounce(termo, (_) => buscarClientes(), time: const Duration(milliseconds: 400));
    buscarClientes();
    carregarFuncionarios();

    final args = Get.arguments;
    if (args is Map && args['cliente_id'] is int) {
      _carregarClienteInicial(args['cliente_id'] as int);
    }
  }

  Future<void> _carregarClienteInicial(int id) async {
    try {
      await selecionarCliente(await _repo.cliente(id));
    } on ApiException catch (e) {
      erro.value = e.message;
    }
  }

  Future<void> carregarFuncionarios() async {
    try {
      funcionarios.assignAll(await _repo.funcionarios(ativo: true));
    } on ApiException catch (e) {
      erro.value = e.message;
    }
  }

  Future<void> buscarClientes() async {
    buscando.value = true;
    try {
      resultados.assignAll(await _repo.clientes(busca: termo.value));
    } on ApiException catch (e) {
      erro.value = e.message;
    } finally {
      buscando.value = false;
    }
  }

  Future<void> selecionarCliente(ClienteModel c) async {
    cliente.value = c;
    veiculo.value = null;
    veiculos.clear();
    try {
      veiculos.assignAll(await _repo.veiculosDoCliente(c.id));
      if (veiculos.length == 1) veiculo.value = veiculos.first;
    } on ApiException catch (e) {
      erro.value = e.message;
    }
  }

  Future<void> novoCliente() async {
    final c = await mostrarDialogNovoCliente(_repo.criarCliente);
    if (c != null) await selecionarCliente(c);
  }

  Future<void> novoVeiculo() async {
    final c = cliente.value;
    if (c == null) {
      erro.value = 'Escolha o cliente primeiro.';
      return;
    }
    final v = await mostrarDialogNovoVeiculo(
      (dados) => _repo.criarVeiculo({...dados, 'cliente_id': c.id}),
    );
    if (v != null) {
      veiculos.add(v);
      veiculo.value = v;
    }
  }

  void alternarFuncionario(int id) {
    if (selecionados.contains(id)) {
      selecionados.remove(id);
    } else {
      selecionados.add(id);
    }
  }

  Future<void> salvar() async {
    final c = cliente.value;
    final v = veiculo.value;
    final titulo = tituloCtrl.text.trim();

    if (c == null) return _falha('Escolha o cliente.');
    if (v == null) return _falha('Escolha o veículo.');
    if (titulo.isEmpty) return _falha('Informe o título do serviço.');

    double? valor;
    if (valorCtrl.text.trim().isNotEmpty) {
      valor = parseDecimal(valorCtrl.text);
      if (valor == null) return _falha('Valor inválido.');
    }

    final payload = <String, dynamic>{
      'cliente_id': c.id,
      'veiculo_id': v.id,
      'titulo': titulo,
      if (instrucoesCtrl.text.trim().isNotEmpty) 'instrucoes': instrucoesCtrl.text.trim(),
      if (valor != null) 'valor_orcado': valor,
      if (selecionados.isNotEmpty) 'funcionarios': selecionados.toList(),
      if (entrada.value != null)
        'agendamento': {'tipo': 'entrada', 'data_hora': isoComOffset(entrada.value!)},
    };

    saving.value = true;
    erro.value = null;
    try {
      final os = await _repo.criarOs(payload);
      Get.offNamed(Routes.adminOsDetalhe, arguments: os.id);
      Get.snackbar('Pronto', 'Ordem de serviço criada.', snackPosition: SnackPosition.BOTTOM);
    } on ApiException catch (e) {
      erro.value = e.message;
    } finally {
      saving.value = false;
    }
  }

  void _falha(String msg) => erro.value = msg;

  @override
  void onClose() {
    tituloCtrl.dispose();
    instrucoesCtrl.dispose();
    valorCtrl.dispose();
    super.onClose();
  }
}
