import '../../core/api_client.dart';
import '../models/user_model.dart';

class LoginResult {
  LoginResult(this.token, this.user);
  final String token;
  final UserModel user;
}

class AuthRepository {
  AuthRepository(this._api);
  final ApiClient _api;

  Future<LoginResult> login(String login, String senha) => _api.run((dio) async {
        final r = await dio.post('/login', data: {
          'login': login,
          'password': senha,
          'device_name': 'app',
        });
        final data = Map<String, dynamic>.from(r.data as Map);
        return LoginResult(
          data['token'] as String,
          UserModel.fromJson(Map<String, dynamic>.from(data['user'] as Map)),
        );
      });

  Future<UserModel> me() => _api.run((dio) async {
        final r = await dio.get('/me');
        return UserModel.fromJson(Map<String, dynamic>.from(r.data as Map));
      });

  Future<void> logout() => _api.run<void>((dio) async {
        await dio.post('/logout');
      });

  Future<void> trocarSenha(String atual, String nova) => _api.run<void>((dio) async {
        await dio.post('/trocar-senha', data: {'senha_atual': atual, 'nova_senha': nova});
      });
}
