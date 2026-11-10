import '../../core/formatters.dart';

class MaterialModel {
  MaterialModel({
    required this.id,
    required this.nome,
    required this.unidade,
    required this.estoqueAtual,
    required this.estoqueMinimo,
    required this.custoUnitario,
    required this.abaixoDoMinimo,
  });

  final int id;
  final String nome;
  final String unidade;
  final double estoqueAtual;
  final double estoqueMinimo;
  final double? custoUnitario; // o servidor não envia o custo para funcionários
  final bool abaixoDoMinimo;

  double get valorEmEstoque => estoqueAtual * (custoUnitario ?? 0);

  factory MaterialModel.fromJson(Map<String, dynamic> j) {
    final atual = double.tryParse('${j['estoque_atual']}') ?? 0;
    final minimo = double.tryParse('${j['estoque_minimo']}') ?? 0;
    return MaterialModel(
      id: j['id'] as int,
      nome: j['nome'] as String,
      unidade: (j['unidade'] as String?) ?? 'un',
      estoqueAtual: atual,
      estoqueMinimo: minimo,
      custoUnitario: j['custo_unitario'] == null ? null : double.tryParse('${j['custo_unitario']}'),
      abaixoDoMinimo: j['abaixo_do_minimo'] is bool ? j['abaixo_do_minimo'] as bool : (minimo > 0 && atual <= minimo),
    );
  }
}

class MovimentacaoMaterialModel {
  MovimentacaoMaterialModel({
    required this.id,
    required this.tipo,
    required this.quantidade,
    required this.custoUnitario,
    required this.dataHora,
    this.osId,
    this.observacao,
    this.estornado = false,
    this.ehEstorno = false,
    this.motivoEstorno,
  });

  final int id;
  final String tipo; // entrada | saida
  final double quantidade;
  final double custoUnitario;
  final DateTime? dataHora;
  final int? osId;
  final String? observacao;
  final bool estornado; // este lançamento foi estornado
  final bool ehEstorno; // este lançamento É o estorno de outro
  final String? motivoEstorno;

  bool get entrada => tipo == 'entrada';
  double get total => quantidade * custoUnitario;

  factory MovimentacaoMaterialModel.fromJson(Map<String, dynamic> j) => MovimentacaoMaterialModel(
        id: j['id'] as int,
        tipo: j['tipo'] as String,
        quantidade: double.tryParse('${j['quantidade']}') ?? 0,
        custoUnitario: double.tryParse('${j['custo_unitario']}') ?? 0,
        dataHora: parseDate(j['data_hora']),
        osId: (j['os_id'] as num?)?.toInt(),
        observacao: j['observacao'] as String?,
        estornado: j['estornado_em'] != null,
        ehEstorno: j['estorno_de_id'] != null,
        motivoEstorno: j['motivo_estorno'] as String?,
      );
}
