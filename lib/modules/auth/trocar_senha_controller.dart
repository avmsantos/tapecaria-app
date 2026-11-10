import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/api_client.dart';
import 'auth_controller.dart';

class TrocarSenhaController extends GetxController {
  TrocarSenhaController(this._auth);
  final AuthController _auth;

  final atualCtrl = TextEditingController();
  final novaCtrl = TextEditingController();
  final confirmaCtrl = TextEditingController();

  final loading = false.obs;
  final erro = RxnString();

  Future<void> salvar() async {
    final atual = atualCtrl.text;
    final nova = novaCtrl.text;

    if (atual.isEmpty || nova.isEmpty) {
      erro.value = 'Preencha todos os campos.';
      return;
    }
    if (nova.length < 6) {
      erro.value = 'A nova senha precisa ter pelo menos 6 caracteres.';
      return;
    }
    if (nova != confirmaCtrl.text) {
      erro.value = 'A confirmação não confere com a nova senha.';
      return;
    }

    loading.value = true;
    erro.value = null;
    try {
      await _auth.trocarSenha(atual, nova);
    } on ApiException catch (e) {
      erro.value = e.message;
    } catch (e) {
      debugPrint('Falha ao trocar a senha: $e');
      erro.value = 'Não foi possível concluir a troca de senha: $e';
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    atualCtrl.dispose();
    novaCtrl.dispose();
    confirmaCtrl.dispose();
    super.onClose();
  }
}
