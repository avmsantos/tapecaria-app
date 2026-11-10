import '../../core/formatters.dart';

class PausaModel {
  PausaModel({required this.id, required this.inicio, this.fim, this.motivo});

  final int id;
  final DateTime inicio;
  final DateTime? fim;
  final String? motivo;

  factory PausaModel.fromJson(Map<String, dynamic> j) => PausaModel(
        id: j['id'] as int,
        inicio: parseDate(j['inicio'])!,
        fim: parseDate(j['fim']),
        motivo: j['motivo'] as String?,
      );
}

class ApontamentoModel {
  ApontamentoModel({
    required this.id,
    required this.osId,
    required this.inicio,
    required this.pausas,
    this.osTitulo,
  });

  final int id;
  final int osId;
  final DateTime inicio;
  final List<PausaModel> pausas;
  final String? osTitulo;

  bool get pausado => pausas.any((p) => p.fim == null);

  /// Tempo efetivamente trabalhado (desconta as pausas). Só para exibição:
  /// o valor oficial é calculado no servidor ao finalizar.
  Duration trabalhado(DateTime agora) {
    var total = agora.difference(inicio);
    for (final p in pausas) {
      total -= (p.fim ?? agora).difference(p.inicio);
    }
    return total.isNegative ? Duration.zero : total;
  }

  factory ApontamentoModel.fromJson(Map<String, dynamic> j) => ApontamentoModel(
        id: j['id'] as int,
        osId: j['os_id'] as int,
        inicio: parseDate(j['inicio'])!,
        pausas: ((j['pausas'] as List?) ?? const [])
            .map((e) => PausaModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        osTitulo: (j['os'] as Map?)?['titulo'] as String?,
      );
}
