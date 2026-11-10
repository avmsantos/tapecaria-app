import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/api_client.dart';
import 'auth_controller.dart';

class LoginController extends GetxController {
  LoginController(this._auth);
  final AuthController _auth;

  final loginCtrl = TextEditingController();
  final senhaCtrl = TextEditingController();

  final loading = false.obs;
  final mostrarSenha = false.obs;
  final erro = RxnString();

  Future<void> entrar() async {
    final login = loginCtrl.text.trim();
    final senha = senhaCtrl.text;

    if (login.isEmpty || senha.isEmpty) {
      erro.value = 'Informe o login e a senha.';
      return;
    }

    loading.value = true;
    erro.value = null;
    try {
      await _auth.login(login, senha);
    } on ApiException catch (e) {
      erro.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    loginCtrl.dispose();
    senhaCtrl.dispose();
    super.onClose();
  }
}
