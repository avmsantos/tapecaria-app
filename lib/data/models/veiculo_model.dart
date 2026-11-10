class VeiculoModel {
  VeiculoModel({
    required this.id,
    required this.clienteId,
    required this.tipo,
    required this.modelo,
    this.marca,
    this.placa,
    this.cor,
    this.ano,
  });

  final int id;
  final int clienteId;
  final String tipo;
  final String modelo;
  final String? marca;
  final String? placa;
  final String? cor;
  final int? ano;

  String get titulo {
    final t = tipo == 'moto' ? 'Moto' : 'Carro';
    return [t, if (marca != null && marca!.isNotEmpty) marca!, modelo].join(' ');
  }

  String get rotulo => (placa != null && placa!.isNotEmpty) ? '$titulo • $placa' : titulo;

  factory VeiculoModel.fromJson(Map<String, dynamic> j) => VeiculoModel(
        id: j['id'] as int,
        clienteId: (j['cliente_id'] as int?) ?? 0,
        tipo: j['tipo'] as String,
        modelo: (j['modelo'] as String?) ?? '',
        marca: j['marca'] as String?,
        placa: j['placa'] as String?,
        cor: j['cor'] as String?,
        ano: (j['ano'] as num?)?.toInt(),
      );
}
