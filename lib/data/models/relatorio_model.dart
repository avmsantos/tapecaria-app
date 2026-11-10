import '../../core/formatters.dart';

class RelFuncionarioModel {
  RelFuncionarioModel({required this.id, required this.nome, required this.servicos, required this.horas, this.funcao});

  final int id;
  final String nome;
  final String? funcao;
  final int servicos;
  final double horas;

  factory RelFuncionarioModel.fromJson(Map<String, dynamic> j) => RelFuncionarioModel(
        id: j['id'] as int,
        nome: j['nome'] as String,
        funcao: j['funcao'] as String?,
        servicos: numero(j['servicos']).toInt(),
        horas: numero(j['horas']),
      );
}

class RelTurnoModel {
  RelTurnoModel({required this.osId, required this.titulo, required this.inicio, required this.fim, required this.horas});

  final int osId;
  final String titulo;
  final DateTime? inicio;
  final DateTime? fim;
  final double horas;

  factory RelTurnoModel.fromJson(Map<String, dynamic> j) => RelTurnoModel(
        osId: j['os_id'] as int,
        titulo: (j['titulo'] as String?) ?? '',
        inicio: parseDate(j['inicio']),
        fim: parseDate(j['fim']),
        horas: numero(j['horas']),
      );
}

class RelSemanaModel {
  RelSemanaModel({required this.semana, required this.servicos, required this.horas});

  final DateTime? semana;
  final int servicos;
  final double horas;

  factory RelSemanaModel.fromJson(Map<String, dynamic> j) => RelSemanaModel(
        semana: parseDate(j['semana']),
        servicos: numero(j['servicos']).toInt(),
        horas: numero(j['horas_trabalhadas']),
      );
}

class RelFuncionarioDetalheModel {
  RelFuncionarioDetalheModel({required this.totalHoras, required this.turnos, required this.semanas});

  final double totalHoras;
  final List<RelTurnoModel> turnos;
  final List<RelSemanaModel> semanas;

  factory RelFuncionarioDetalheModel.fromJson(Map<String, dynamic> j) => RelFuncionarioDetalheModel(
        totalHoras: numero(j['total_horas']),
        turnos: ((j['servicos'] as List?) ?? const [])
            .map((e) => RelTurnoModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        semanas: ((j['horas_por_semana'] as List?) ?? const [])
            .map((e) => RelSemanaModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class RelDiaModel {
  RelDiaModel({required this.dia, required this.total});
  final DateTime? dia;
  final int total;

  factory RelDiaModel.fromJson(Map<String, dynamic> j) =>
      RelDiaModel(dia: parseDate(j['dia']), total: numero(j['total']).toInt());
}

class RelServicosModel {
  RelServicosModel({required this.total, required this.dias});
  final int total;
  final List<RelDiaModel> dias;

  factory RelServicosModel.fromJson(Map<String, dynamic> j) => RelServicosModel(
        total: numero(j['total']).toInt(),
        dias: ((j['dias'] as List?) ?? const [])
            .map((e) => RelDiaModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class RelConsumoModel {
  RelConsumoModel({required this.nome, required this.unidade, required this.quantidade, required this.custo});
  final String nome;
  final String unidade;
  final double quantidade;
  final double custo;

  factory RelConsumoModel.fromJson(Map<String, dynamic> j) => RelConsumoModel(
        nome: j['nome'] as String,
        unidade: (j['unidade'] as String?) ?? 'un',
        quantidade: numero(j['quantidade']),
        custo: numero(j['custo']),
      );
}

class RelEstoqueBaixoModel {
  RelEstoqueBaixoModel({required this.nome, required this.unidade, required this.atual, required this.minimo});
  final String nome;
  final String unidade;
  final double atual;
  final double minimo;

  factory RelEstoqueBaixoModel.fromJson(Map<String, dynamic> j) => RelEstoqueBaixoModel(
        nome: j['nome'] as String,
        unidade: (j['unidade'] as String?) ?? 'un',
        atual: numero(j['estoque_atual']),
        minimo: numero(j['estoque_minimo']),
      );
}

class RelMateriaisModel {
  RelMateriaisModel({
    required this.totalConsumido,
    required this.totalComprado,
    required this.consumo,
    required this.estoqueBaixo,
  });

  final double totalConsumido;
  final double totalComprado;
  final List<RelConsumoModel> consumo;
  final List<RelEstoqueBaixoModel> estoqueBaixo;

  factory RelMateriaisModel.fromJson(Map<String, dynamic> j) => RelMateriaisModel(
        totalConsumido: numero(j['total_consumido']),
        totalComprado: numero(j['total_comprado']),
        consumo: ((j['consumo'] as List?) ?? const [])
            .map((e) => RelConsumoModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        estoqueBaixo: ((j['estoque_baixo'] as List?) ?? const [])
            .map((e) => RelEstoqueBaixoModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class RelMotivoModel {
  RelMotivoModel({required this.motivo, required this.total});
  final String motivo;
  final int total;

  factory RelMotivoModel.fromJson(Map<String, dynamic> j) => RelMotivoModel(
        motivo: (j['motivo_perda'] as String?) ?? 'Sem motivo informado',
        total: numero(j['total']).toInt(),
      );
}

class RelLeadsModel {
  RelLeadsModel({required this.motivos, required this.porEtapa});
  final List<RelMotivoModel> motivos;
  final Map<String, int> porEtapa;

  int get totalPerdidos => motivos.fold(0, (s, m) => s + m.total);

  factory RelLeadsModel.fromJson(Map<String, dynamic> j) {
    final etapas = (j['leads_por_etapa'] as Map?) ?? const {};
    return RelLeadsModel(
      motivos: ((j['motivos_perda'] as List?) ?? const [])
          .map((e) => RelMotivoModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      porEtapa: {for (final e in etapas.entries) e.key.toString(): numero(e.value).toInt()},
    );
  }
}
