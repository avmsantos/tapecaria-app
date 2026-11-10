import 'package:get/get.dart';

import '../../core/api_client.dart';
import '../../core/storage_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

/// Controller global: guarda quem está logado e decide para onde ir.
class AuthController extends GetxController {
  AuthController(this._repo, this._storage, this._api);

  final AuthRepository _repo;
  final StorageService _storage;
  final ApiClient _api;

  final Rxn<UserModel> user = Rxn<UserModel>();

  bool get isAdmin => user.value?.isAdmin ?? false;

  @override
  void onInit() {
    super.onInit();
    _api.onUnauthorized = _sessaoExpirada;
  }

  String _rotaPara(UserModel u) {
    if (u.mustChangePassword) return Routes.trocarSenha;
    return u.isAdmin ? Routes.admin : Routes.funcionario;
  }

  /// Usado pela splash. Lança ApiException se o servidor não responder.
  Future<String> descobrirRotaInicial() async {
    if (_storage.token == null) return Routes.login;
    try {
      final u = await _repo.me();
      user.value = u;
      return _rotaPara(u);
    } on ApiException catch (e) {
      if (e.status == 401) {
        await _storage.clear();
        return Routes.login;
      }
      rethrow;
    }
  }

  Future<void> login(String login, String senha) async {
    final result = await _repo.login(login, senha);
    await _storage.saveToken(result.token);
    user.value = result.user;
    Get.offAllNamed(_rotaPara(result.user));
  }

  Future<void> trocarSenha(String atual, String nova) async {
    await _repo.trocarSenha(atual, nova);

    // A senha já foi trocada no servidor. Tentamos atualizar o usuário, mas se essa
    // segunda chamada falhar usamos o que já temos: a troca em si não pode "falhar" por isso.
    UserModel? u;
    try {
      u = await _repo.me();
    } catch (_) {
      u = user.value?.comSenhaTrocada();
    }

    if (u == null) {
      await _storage.clear();
      Get.offAllNamed(Routes.login);
      return;
    }

    user.value = u;
    Get.offAllNamed(_rotaPara(u));
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (_) {
      // sem internet: encerra a sessão localmente mesmo assim
    }
    await _storage.clear();
    user.value = null;
    Get.offAllNamed(Routes.login);
  }

  Future<void> _sessaoExpirada() async {
    if (user.value == null) return;
    await _storage.clear();
    user.value = null;
    Get.offAllNamed(Routes.login);
    Get.snackbar('Sessão expirada', 'Entre novamente para continuar.');
  }
}
