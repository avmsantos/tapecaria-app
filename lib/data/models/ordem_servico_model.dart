import '../../core/formatters.dart';

class AgendamentoModel {
  AgendamentoModel({required this.id, required this.tipo, required this.dataHora, required this.status});

  final int id;
  final String tipo;
  final DateTime? dataHora;
  final String status;

  String get tipoLabel {
    switch (tipo) {
      case 'entrada':
        return 'Entrada do veículo';
      case 'entrega':
        return 'Entrega';
      default:
        return 'Retorno';
    }
  }

  factory AgendamentoModel.fromJson(Map<String, dynamic> j) => AgendamentoModel(
        id: j['id'] as int,
        tipo: j['tipo'] as String,
        dataHora: parseDate(j['data_hora']),
        status: j['status'] as String,
      );
}

/// Funcionário designado a uma OS (com o aceite dele).
class FuncionarioOsModel {
  FuncionarioOsModel({required this.id, required this.nome, this.funcao, this.aceitoEm});

  final int id;
  final String nome;
  final String? funcao;
  final DateTime? aceitoEm;

  factory FuncionarioOsModel.fromJson(Map<String, dynamic> j) {
    final pivot = j['pivot'] as Map?;
    return FuncionarioOsModel(
      id: j['id'] as int,
      nome: (j['nome'] as String?) ?? '',
      funcao: j['funcao'] as String?,
      aceitoEm: parseDate(pivot?['aceito_em']),
    );
  }
}

/// Um turno de trabalho de um funcionário na OS.
class ApontamentoResumoModel {
  ApontamentoResumoModel({required this.id, required this.funcionarioNome, required this.inicio, this.fim});

  final int id;
  final String funcionarioNome;
  final DateTime? inicio;
  final DateTime? fim;

  factory ApontamentoResumoModel.fromJson(Map<String, dynamic> j) => ApontamentoResumoModel(
        id: j['id'] as int,
        funcionarioNome: ((j['funcionario'] as Map?)?['nome'] as String?) ?? '-',
        inicio: parseDate(j['inicio']),
        fim: parseDate(j['fim']),
      );
}

class OrdemServicoModel {
  OrdemServicoModel({
    required this.id,
    required this.titulo,
    required this.status,
    required this.clienteNome,
    required this.veiculoTitulo,
    required this.agendamentos,
    this.clienteId,
    this.veiculoId,
    this.descricao,
    this.instrucoes,
    this.dataPrevista,
    this.clienteTelefone,
    this.veiculoPlaca,
    this.veiculoCor,
    this.aceitoEm,
    this.valorOrcado,
    this.valorFinal,
    this.funcionarios = const [],
    this.apontamentos = const [],
  });

  final int id;
  final String titulo;
  final String status;
  final int? clienteId;
  final int? veiculoId;
  final String? descricao;
  final String? instrucoes;
  final DateTime? dataPrevista;
  final String clienteNome;
  final String? clienteTelefone;
  final String veiculoTitulo;
  final String? veiculoPlaca;
  final String? veiculoCor;
  final List<AgendamentoModel> agendamentos;
  final DateTime? aceitoEm; // aceite do funcionário logado (fluxo do funcionário)
  final double? valorOrcado;
  final double? valorFinal;
  final List<FuncionarioOsModel> funcionarios;
  final List<ApontamentoResumoModel> apontamentos;

  bool get aceito => aceitoEm != null;

  /// Na lista do funcionário: OS sem ninguém designado, disponível para quem aceitar.
  bool get livre => funcionarios.isEmpty;

  String get funcionariosNomes =>
      funcionarios.map((f) => f.nome).where((n) => n.isNotEmpty).join(', ');

  /// Próximo agendamento ainda pendente (ou o primeiro da lista).
  AgendamentoModel? get proximoAgendamento {
    if (agendamentos.isEmpty) return null;
    final pendentes = agendamentos.where((a) => a.status == 'agendado').toList()
      ..sort((a, b) => (a.dataHora ?? DateTime(2100)).compareTo(b.dataHora ?? DateTime(2100)));
    return pendentes.isNotEmpty ? pendentes.first : agendamentos.first;
  }

  factory OrdemServicoModel.fromJson(Map<String, dynamic> j) {
    final cliente = (j['cliente'] as Map?) ?? const {};
    final veiculo = (j['veiculo'] as Map?) ?? const {};
    final funcs = ((j['funcionarios'] as List?) ?? const [])
        .map((e) => FuncionarioOsModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    String veiculoTitulo = '';
    if (veiculo.isNotEmpty) {
      final tipo = veiculo['tipo'] == 'moto' ? 'Moto' : 'Carro';
      final marca = veiculo['marca'] as String?;
      final modelo = (veiculo['modelo'] as String?) ?? '';
      veiculoTitulo = [tipo, if (marca != null && marca.isNotEmpty) marca, modelo].join(' ').trim();
    }

    return OrdemServicoModel(
      id: j['id'] as int,
      titulo: j['titulo'] as String,
      status: j['status'] as String,
      clienteId: (j['cliente_id'] as num?)?.toInt(),
      veiculoId: (j['veiculo_id'] as num?)?.toInt(),
      descricao: j['descricao'] as String?,
      instrucoes: j['instrucoes'] as String?,
      dataPrevista: parseDate(j['data_prevista']),
      clienteNome: (cliente['nome'] as String?) ?? '-',
      clienteTelefone: cliente['telefone'] as String?,
      veiculoTitulo: veiculoTitulo,
      veiculoPlaca: veiculo['placa'] as String?,
      veiculoCor: veiculo['cor'] as String?,
      agendamentos: ((j['agendamentos'] as List?) ?? const [])
          .map((e) => AgendamentoModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      aceitoEm: funcs.isNotEmpty ? funcs.first.aceitoEm : null,
      valorOrcado: double.tryParse('${j['valor_orcado']}'),
      valorFinal: double.tryParse('${j['valor_final']}'),
      funcionarios: funcs,
      apontamentos: ((j['apontamentos'] as List?) ?? const [])
          .map((e) => ApontamentoResumoModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
