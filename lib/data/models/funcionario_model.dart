class FuncionarioModel {
  FuncionarioModel({
    required this.id,
    required this.nome,
    required this.login,
    required this.ativo,
    this.funcao,
    this.telefone,
    this.valorHora,
  });

  final int id;
  final String nome;
  final String login;
  final bool ativo;
  final String? funcao;
  final String? telefone;
  final double? valorHora;

  factory FuncionarioModel.fromJson(Map<String, dynamic> j) => FuncionarioModel(
        id: j['id'] as int,
        nome: j['nome'] as String,
        login: j['login'] as String,
        ativo: j['ativo'] == true,
        funcao: j['funcao'] as String?,
        telefone: j['telefone'] as String?,
        valorHora: j['valor_hora'] == null ? null : double.tryParse('${j['valor_hora']}'),
      );
}
