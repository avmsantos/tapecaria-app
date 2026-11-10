import 'package:get/get.dart';

import '../../../core/api_client.dart';
import '../../../core/widgets.dart';
import '../../../data/models/funcionario_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../widgets/funcionario_dialogs.dart';

class FuncionariosController extends GetxController {
  FuncionariosController(this._repo);
  final AdminRepository _repo;

  final lista = <FuncionarioModel>[].obs;
  final mostrarInativos = false.obs;
  final loading = true.obs;
  final erro = RxnString();

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  Future<void> carregar() async {
    loading.value = true;
    erro.value = null;
    try {
      lista.assignAll(await _repo.funcionarios(ativo: mostrarInativos.value ? null : true));
    } on ApiException catch (e) {
      erro.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  void alternarInativos(bool v) {
    mostrarInativos.value = v;
    carregar();
  }

  Future<void> novo() async {
    NovoFuncionario? criado;
    final ok = await mostrarDialogFuncionario(
      onSalvar: (dados) async => criado = await _repo.criarFuncionario(dados),
    );
    if (ok == true && criado != null) {
      await carregar();
      await mostrarSenhaTemporaria(
        nome: criado!.funcionario.nome,
        login: criado!.funcionario.login,
        senha: criado!.senha,
      );
    }
  }

  Future<void> editar(FuncionarioModel f) async {
    final ok = await mostrarDialogFuncionario(
      existente: f,
      onSalvar: (dados) async => _repo.atualizarFuncionario(f.id, dados),
    );
    if (ok == true) carregar();
  }

  Future<void> redefinirSenha(FuncionarioModel f) async {
    final sim = await confirmar(
      'Redefinir senha',
      'Gerar uma nova senha temporária para ${f.nome}? Ele(a) será desconectado(a) de todos os aparelhos.',
      confirmarLabel: 'Redefinir',
    );
    if (!sim) return;
    try {
      final senha = await _repo.redefinirSenhaFuncionario(f.id);
      await mostrarSenhaTemporaria(nome: f.nome, login: f.login, senha: senha);
    } on ApiException catch (e) {
      Get.snackbar('Atenção', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> alternarAtivo(FuncionarioModel f) async {
    if (f.ativo) {
      final sim = await confirmar(
        'Desativar funcionário',
        '${f.nome} perde o acesso ao app na hora. O histórico de trabalho é mantido.',
        confirmarLabel: 'Desativar',
      );
      if (!sim) return;
    }
    try {
      f.ativo ? await _repo.desativarFuncionario(f.id) : await _repo.ativarFuncionario(f.id);
      await carregar();
    } on ApiException catch (e) {
      Get.snackbar('Atenção', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
