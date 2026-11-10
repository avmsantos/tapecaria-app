import '../../core/api_client.dart';
import '../../core/formatters.dart';
import '../models/agenda_item_model.dart';
import '../models/cliente_model.dart';
import '../models/financeiro_model.dart';
import '../models/funcionario_model.dart';
import '../models/material_model.dart';
import '../models/relatorio_model.dart';
import '../models/ordem_servico_model.dart';
import '../models/veiculo_model.dart';

Map<String, dynamic> _map(dynamic v) => Map<String, dynamic>.from(v as Map);

List<Map<String, dynamic>> _lista(dynamic body) {
  // endpoints paginados devolvem {data: [...]}; outros devolvem a lista direto
  final raw = body is Map ? body['data'] : body;
  return (raw as List).map(_map).toList();
}

class NovoFuncionario {
  NovoFuncionario(this.funcionario, this.senha);
  final FuncionarioModel funcionario;
  final String senha;
}

class AdminRepository {
  AdminRepository(this._api);
  final ApiClient _api;

  // ---------- Painel ----------
  Future<Map<String, dynamic>> dashboard() => _api.run((dio) async {
        final r = await dio.get('/relatorios/dashboard');
        return _map(r.data);
      });

  // ---------- Agenda ----------
  Future<List<AgendaItemModel>> agenda({required DateTime de, required DateTime ate}) =>
      _api.run((dio) async {
        final r = await dio.get('/agenda',
            queryParameters: {'de': fmtDataIso(de), 'ate': fmtDataIso(ate)});
        return _lista(r.data).map(AgendaItemModel.fromJson).toList();
      });

  Future<void> agendar(int osId, String tipo, DateTime quando) => _api.run<void>((dio) async {
        await dio.post('/ordens-servico/$osId/agendamentos',
            data: {'tipo': tipo, 'data_hora': isoComOffset(quando)});
      });

  Future<void> atualizarAgendamento(int id, String status) => _api.run<void>((dio) async {
        await dio.patch('/agendamentos/$id', data: {'status': status});
      });

  // ---------- Ordens de serviço ----------
  Future<List<OrdemServicoModel>> listarOs({String? status}) => _api.run((dio) async {
        final r = await dio.get('/ordens-servico',
            queryParameters: {if (status != null) 'status': status});
        return _lista(r.data).map(OrdemServicoModel.fromJson).toList();
      });

  Future<OrdemServicoModel> detalheOs(int id) => _api.run((dio) async {
        final r = await dio.get('/ordens-servico/$id');
        return OrdemServicoModel.fromJson(_map(r.data));
      });

  Future<OrdemServicoModel> criarOs(Map<String, dynamic> payload) => _api.run((dio) async {
        final r = await dio.post('/ordens-servico', data: payload);
        return OrdemServicoModel.fromJson(_map(r.data));
      });

  Future<void> atualizarStatusOs(int id, String status) => _api.run<void>((dio) async {
        await dio.put('/ordens-servico/$id', data: {'status': status});
      });

  Future<void> atualizarOs(int id, Map<String, dynamic> dados) => _api.run<void>((dio) async {
        await dio.put('/ordens-servico/$id', data: dados);
      });

  Future<void> atribuirFuncionarios(int osId, List<int> ids) => _api.run<void>((dio) async {
        await dio.post('/ordens-servico/$osId/funcionarios', data: {'user_ids': ids});
      });

  // ---------- Veículo: entrada e saída ----------
  /// 'entrada', 'saida' ou null (sem movimentação ainda).
  Future<String?> ultimoMovimentoVeiculo(int osId) => _api.run((dio) async {
        final r = await dio.get('/ordens-servico/$osId/movimentacoes');
        final lista = r.data as List;
        return lista.isEmpty ? null : (lista.last as Map)['tipo'] as String?;
      });

  Future<void> entradaVeiculo(int osId) => _api.run<void>((dio) async {
        await dio.post('/ordens-servico/$osId/entrada-veiculo', data: {});
      });

  Future<void> saidaVeiculo(int osId, String quemRetirou) => _api.run<void>((dio) async {
        await dio.post('/ordens-servico/$osId/saida-veiculo', data: {'quem_retirou': quemRetirou});
      });

  // ---------- Clientes e veículos ----------
  Future<List<ClienteModel>> clientes({String? busca}) => _api.run((dio) async {
        final r = await dio.get('/clientes', queryParameters: {
          if (busca != null && busca.trim().isNotEmpty) 'busca': busca.trim(),
        });
        return _lista(r.data).map(ClienteModel.fromJson).toList();
      });

  Future<ClienteModel> cliente(int id) => _api.run((dio) async {
        final r = await dio.get('/clientes/$id');
        return ClienteModel.fromJson(_map(r.data));
      });

  Future<ClienteModel> criarCliente(String nome, String telefone, String? obs) =>
      _api.run((dio) async {
        final r = await dio.post('/clientes', data: {
          'nome': nome,
          'telefone': telefone,
          if (obs != null && obs.isNotEmpty) 'observacoes': obs,
        });
        return ClienteModel.fromJson(_map(r.data));
      });

  Future<List<VeiculoModel>> veiculosDoCliente(int clienteId) => _api.run((dio) async {
        final r = await dio.get('/veiculos', queryParameters: {'cliente_id': clienteId});
        return _lista(r.data).map(VeiculoModel.fromJson).toList();
      });

  Future<VeiculoModel> criarVeiculo(Map<String, dynamic> payload) => _api.run((dio) async {
        final r = await dio.post('/veiculos', data: payload);
        return VeiculoModel.fromJson(_map(r.data));
      });

  // ---------- Funcionários (lista para seleção) ----------
  Future<List<FuncionarioModel>> funcionarios({bool? ativo}) => _api.run((dio) async {
        final r = await dio.get('/funcionarios',
            queryParameters: {if (ativo != null) 'ativo': ativo ? 1 : 0});
        return _lista(r.data).map(FuncionarioModel.fromJson).toList();
      });

  // ---------- Funcionários (gestão) ----------
  Future<NovoFuncionario> criarFuncionario(Map<String, dynamic> dados) => _api.run((dio) async {
        final r = await dio.post('/funcionarios', data: dados);
        final m = _map(r.data);
        return NovoFuncionario(
          FuncionarioModel.fromJson(_map(m['funcionario'])),
          m['senha_temporaria'].toString(),
        );
      });

  Future<FuncionarioModel> atualizarFuncionario(int id, Map<String, dynamic> dados) =>
      _api.run((dio) async {
        final r = await dio.put('/funcionarios/$id', data: dados);
        return FuncionarioModel.fromJson(_map(r.data));
      });

  Future<void> ativarFuncionario(int id) => _api.run<void>((dio) async {
        await dio.patch('/funcionarios/$id/ativar');
      });

  Future<void> desativarFuncionario(int id) => _api.run<void>((dio) async {
        await dio.patch('/funcionarios/$id/desativar');
      });

  /// Devolve a nova senha temporária.
  Future<String> redefinirSenhaFuncionario(int id) => _api.run((dio) async {
        final r = await dio.post('/funcionarios/$id/redefinir-senha');
        return _map(r.data)['senha_temporaria'].toString();
      });

  // ---------- Materiais ----------
  Future<List<MaterialModel>> materiais() => _api.run((dio) async {
        final r = await dio.get('/materiais');
        return _lista(r.data).map(MaterialModel.fromJson).toList();
      });

  Future<MaterialModel> criarMaterial(Map<String, dynamic> dados) => _api.run((dio) async {
        final r = await dio.post('/materiais', data: dados);
        return MaterialModel.fromJson(_map(r.data));
      });

  Future<MaterialModel> atualizarMaterial(int id, Map<String, dynamic> dados) => _api.run((dio) async {
        final r = await dio.put('/materiais/$id', data: dados);
        return MaterialModel.fromJson(_map(r.data));
      });

  Future<void> entradaMaterial(int id, Map<String, dynamic> dados) => _api.run<void>((dio) async {
        await dio.post('/materiais/$id/entrada', data: dados);
      });

  Future<void> saidaMaterial(int id, Map<String, dynamic> dados) => _api.run<void>((dio) async {
        await dio.post('/materiais/$id/saida', data: dados);
      });

  Future<List<MovimentacaoMaterialModel>> movimentacoesMaterial(int id) => _api.run((dio) async {
        final r = await dio.get('/materiais/$id/movimentacoes');
        return _lista(r.data).map(MovimentacaoMaterialModel.fromJson).toList();
      });

  // ---------- Financeiro ----------
  Future<ResumoFinanceiroModel> resumoFinanceiro({required DateTime de, required DateTime ate}) =>
      _api.run((dio) async {
        final r = await dio.get('/relatorios/financeiro',
            queryParameters: {'de': fmtDataIso(de), 'ate': fmtDataIso(ate)});
        return ResumoFinanceiroModel.fromJson(_map(r.data));
      });

  Future<List<DespesaModel>> despesas({required DateTime de, required DateTime ate}) =>
      _api.run((dio) async {
        final r = await dio.get('/despesas',
            queryParameters: {'de': fmtDataIso(de), 'ate': fmtDataIso(ate)});
        final lista = (_map(r.data)['despesas'] as List?) ?? const [];
        return lista.map((e) => DespesaModel.fromJson(_map(e))).toList();
      });

  Future<void> criarDespesa(Map<String, dynamic> dados) => _api.run<void>((dio) async {
        await dio.post('/despesas', data: dados);
      });

  Future<PagamentosOsModel> pagamentosOs(int osId) => _api.run((dio) async {
        final r = await dio.get('/ordens-servico/$osId/pagamentos');
        return PagamentosOsModel.fromJson(_map(r.data));
      });

  Future<void> registrarPagamento(int osId, Map<String, dynamic> dados) => _api.run<void>((dio) async {
        await dio.post('/ordens-servico/$osId/pagamentos', data: dados);
      });

  // ---------- Relatórios ----------
  Map<String, String> _periodo(DateTime de, DateTime ate) => {'de': fmtDataIso(de), 'ate': fmtDataIso(ate)};

  Future<List<RelFuncionarioModel>> relFuncionarios({required DateTime de, required DateTime ate}) =>
      _api.run((dio) async {
        final r = await dio.get('/relatorios/funcionarios', queryParameters: _periodo(de, ate));
        return ((_map(r.data)['funcionarios'] as List?) ?? const [])
            .map((e) => RelFuncionarioModel.fromJson(_map(e)))
            .toList();
      });

  Future<RelFuncionarioDetalheModel> relFuncionarioDetalhe(int id, {required DateTime de, required DateTime ate}) =>
      _api.run((dio) async {
        final r = await dio.get('/relatorios/funcionarios/$id', queryParameters: _periodo(de, ate));
        return RelFuncionarioDetalheModel.fromJson(_map(r.data));
      });

  Future<RelServicosModel> relServicosPorDia({required DateTime de, required DateTime ate}) =>
      _api.run((dio) async {
        final r = await dio.get('/relatorios/servicos-por-dia', queryParameters: _periodo(de, ate));
        return RelServicosModel.fromJson(_map(r.data));
      });

  Future<RelMateriaisModel> relMateriais({required DateTime de, required DateTime ate}) =>
      _api.run((dio) async {
        final r = await dio.get('/relatorios/materiais', queryParameters: _periodo(de, ate));
        return RelMateriaisModel.fromJson(_map(r.data));
      });

  Future<RelLeadsModel> relLeads({required DateTime de, required DateTime ate}) =>
      _api.run((dio) async {
        final r = await dio.get('/relatorios/leads', queryParameters: _periodo(de, ate));
        return RelLeadsModel.fromJson(_map(r.data));
      });

  // ---------- Correções: estornos, edições e exclusões ----------
  Future<void> estornarPagamento(int id, String motivo) => _api.run<void>((dio) async {
        await dio.post('/pagamentos/$id/estornar', data: {'motivo': motivo});
      });

  Future<void> atualizarDespesa(int id, Map<String, dynamic> dados) => _api.run<void>((dio) async {
        await dio.put('/despesas/$id', data: dados);
      });

  Future<void> excluirDespesa(int id) => _api.run<void>((dio) async {
        await dio.delete('/despesas/$id');
      });

  Future<void> estornarMovimentoMaterial(int id, String motivo) => _api.run<void>((dio) async {
        await dio.post('/movimentacoes-material/$id/estornar', data: {'motivo': motivo});
      });

  Future<ClienteModel> atualizarCliente(int id, String nome, String telefone, String? obs) =>
      _api.run((dio) async {
        final r = await dio.put('/clientes/$id', data: {
          'nome': nome,
          'telefone': telefone,
          'observacoes': (obs == null || obs.isEmpty) ? null : obs,
        });
        return ClienteModel.fromJson(_map(r.data));
      });

  Future<VeiculoModel> atualizarVeiculo(int id, Map<String, dynamic> dados) => _api.run((dio) async {
        final r = await dio.put('/veiculos/$id', data: dados);
        return VeiculoModel.fromJson(_map(r.data));
      });

  Future<void> remarcarAgendamento(int id, DateTime quando) => _api.run<void>((dio) async {
        await dio.patch('/agendamentos/$id', data: {'data_hora': isoComOffset(quando)});
      });
}
