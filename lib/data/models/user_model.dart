class UserModel {
  UserModel({
    required this.id,
    required this.nome,
    required this.login,
    required this.role,
    required this.mustChangePassword,
    this.funcao,
  });

  final int id;
  final String nome;
  final String login;
  final String role;
  final String? funcao;
  final bool mustChangePassword;

  bool get isAdmin => role == 'admin';

  /// Mesmo usuário, já sem a troca de senha pendente.
  UserModel comSenhaTrocada() => UserModel(
        id: id,
        nome: nome,
        login: login,
        role: role,
        funcao: funcao,
        mustChangePassword: false,
      );

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'] as int,
        nome: j['nome'] as String,
        login: j['login'] as String,
        role: j['role'] as String,
        funcao: j['funcao'] as String?,
        mustChangePassword: j['must_change_password'] == true,
      );
}
