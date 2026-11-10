import '../../core/formatters.dart';

class AgendaItemModel {
  AgendaItemModel({
    required this.id,
    required this.osId,
    required this.tipo,
    required this.dataHora,
    required this.status,
    required this.osTitulo,
    required this.clienteNome,
    required this.veiculoTitulo,
    this.clienteTelefone,
    this.placa,
  });

  final int id;
  final int osId;
  final String tipo;
  final DateTime? dataHora;
  final String status;
  final String osTitulo;
  final String clienteNome;
  final String? clienteTelefone;
  final String veiculoTitulo;
  final String? placa;

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

  factory AgendaItemModel.fromJson(Map<String, dynamic> j) {
    final os = (j['os'] as Map?) ?? const {};
    final cliente = (os['cliente'] as Map?) ?? const {};
    final veiculo = (os['veiculo'] as Map?) ?? const {};
    final tipoV = veiculo['tipo'] == 'moto' ? 'Moto' : 'Carro';

    return AgendaItemModel(
      id: j['id'] as int,
      osId: j['os_id'] as int,
      tipo: j['tipo'] as String,
      dataHora: parseDate(j['data_hora']),
      status: j['status'] as String,
      osTitulo: (os['titulo'] as String?) ?? 'OS #${j['os_id']}',
      clienteNome: (cliente['nome'] as String?) ?? '-',
      clienteTelefone: cliente['telefone'] as String?,
      veiculoTitulo: veiculo.isEmpty ? '' : '$tipoV ${veiculo['modelo'] ?? ''}'.trim(),
      placa: veiculo['placa'] as String?,
    );
  }
}
