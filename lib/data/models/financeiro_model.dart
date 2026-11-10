import '../../core/formatters.dart';

const Map<String, String> formasPagamento = {
  'pix': 'Pix',
  'dinheiro': 'Dinheiro',
  'cartao_debito': 'Cartão de débito',
  'cartao_credito': 'Cartão de crédito',
  'transferencia': 'Transferência',
};

class PagamentoModel {
  PagamentoModel({
    required this.id,
    required this.valor,
    required this.forma,
    this.pagoEm,
    this.observacao,
    this.estornado = false,
    this.motivoEstorno,
  });

  final int id;
  final double valor;
  final String forma;
  final DateTime? pagoEm;
  final String? observacao;
  final bool estornado;
  final String? motivoEstorno;

  String get formaLabel => formasPagamento[forma] ?? forma;

  factory PagamentoModel.fromJson(Map<String, dynamic> j) => PagamentoModel(
        id: j['id'] as int,
        valor: numero(j['valor']),
        forma: (j['forma'] as String?) ?? 'pix',
        pagoEm: parseDate(j['pago_em']),
        observacao: j['observacao'] as String?,
        estornado: j['estornado_em'] != null,
        motivoEstorno: j['motivo_estorno'] as String?,
      );
}

/// Situação financeira de uma OS: total, pago e quanto falta.
class PagamentosOsModel {
  PagamentosOsModel({required this.valorTotal, required this.totalPago, required this.saldo, required this.pagamentos});

  final double valorTotal;
  final double totalPago;
  final double saldo;
  final List<PagamentoModel> pagamentos;

  bool get quitado => valorTotal > 0 && saldo <= 0;

  factory PagamentosOsModel.fromJson(Map<String, dynamic> j) => PagamentosOsModel(
        valorTotal: numero(j['valor_total']),
        totalPago: numero(j['total_pago']),
        saldo: numero(j['saldo']),
        pagamentos: ((j['pagamentos'] as List?) ?? const [])
            .map((e) => PagamentoModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class DespesaModel {
  DespesaModel({required this.id, required this.categoria, required this.descricao, required this.valor, this.data});

  final int id;
  final String categoria;
  final String descricao;
  final double valor;
  final DateTime? data;

  factory DespesaModel.fromJson(Map<String, dynamic> j) => DespesaModel(
        id: j['id'] as int,
        categoria: (j['categoria'] as String?) ?? 'outros',
        descricao: j['descricao'] as String,
        valor: numero(j['valor']),
        data: parseDate(j['data']),
      );
}

class ResumoFinanceiroModel {
  ResumoFinanceiroModel({
    required this.receita,
    required this.despesas,
    required this.resultado,
    required this.materialConsumido,
    required this.maoDeObraEstimada,
    required this.aReceber,
  });

  final double receita;
  final double despesas;
  final double resultado;
  final double materialConsumido;
  final double maoDeObraEstimada;
  final double aReceber;

  factory ResumoFinanceiroModel.fromJson(Map<String, dynamic> j) {
    final t = Map<String, dynamic>.from((j['totais'] as Map?) ?? const {});
    return ResumoFinanceiroModel(
      receita: numero(t['receita']),
      despesas: numero(t['despesas']),
      resultado: numero(t['resultado']),
      materialConsumido: numero(t['material_consumido']),
      maoDeObraEstimada: numero(t['mao_de_obra_estimada']),
      aReceber: numero(t['a_receber']),
    );
  }
}
