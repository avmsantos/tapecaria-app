import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/api_client.dart';
import '../../../core/formatters.dart';
import '../../../data/models/funcionario_model.dart';

/// Cadastro/edição de funcionário. Devolve true se salvou.
/// [onSalvar] faz a chamada à API; erros aparecem dentro do diálogo.
Future<bool?> mostrarDialogFuncionario({
  FuncionarioModel? existente,
  required Future<void> Function(Map<String, dynamic> dados) onSalvar,
}) =>
    Get.dialog<bool>(_FuncionarioDialog(existente: existente, onSalvar: onSalvar));

class _FuncionarioDialog extends StatefulWidget {
  const _FuncionarioDialog({required this.existente, required this.onSalvar});
  final FuncionarioModel? existente;
  final Future<void> Function(Map<String, dynamic> dados) onSalvar;

  @override
  State<_FuncionarioDialog> createState() => _FuncionarioDialogState();
}

class _FuncionarioDialogState extends State<_FuncionarioDialog> {
  late final _nome = TextEditingController(text: widget.existente?.nome);
  late final _login = TextEditingController(text: widget.existente?.login);
  late final _tel = TextEditingController(text: widget.existente?.telefone);
  late final _funcao = TextEditingController(text: widget.existente?.funcao);
  late final _valor = TextEditingController(
    text: widget.existente?.valorHora == null
        ? ''
        : widget.existente!.valorHora!.toStringAsFixed(2).replaceAll('.', ','),
  );
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _login.dispose();
    _tel.dispose();
    _funcao.dispose();
    _valor.dispose();
    super.dispose();
  }

  String? _vazioNulo(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _salvar() async {
    if (_nome.text.trim().isEmpty || _login.text.trim().isEmpty) {
      setState(() => _erro = 'Informe o nome e o login.');
      return;
    }
    double? valor;
    if (_valor.text.trim().isNotEmpty) {
      valor = parseDecimal(_valor.text);
      if (valor == null) {
        setState(() => _erro = 'Valor da hora inválido.');
        return;
      }
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await widget.onSalvar({
        'nome': _nome.text.trim(),
        'login': _login.text.trim(),
        'telefone': _vazioNulo(_tel),
        'funcao': _vazioNulo(_funcao),
        'valor_hora': valor,
      });
      Get.back(result: true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.existente != null;
    return AlertDialog(
      title: Text(editando ? 'Editar funcionário' : 'Novo funcionário'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nome,
              autofocus: !editando,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nome completo'),
            ),
            TextField(
              controller: _login,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Login',
                helperText: 'Com ele o funcionário entra no app (ex.: joao)',
              ),
            ),
            TextField(
              controller: _tel,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Telefone (opcional)'),
            ),
            TextField(
              controller: _funcao,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Função (ex.: Estofador)'),
            ),
            TextField(
              controller: _valor,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor da hora (opcional)',
                prefixText: 'R\$ ',
                helperText: 'Só o administrador vê. Usado no custo de mão de obra.',
              ),
            ),
            if (_erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_erro!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _salvando ? null : () => Get.back(), child: const Text('Cancelar')),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          child: _salvando
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salvar'),
        ),
      ],
    );
  }
}

/// Mostra a senha temporária (só aparece nesta hora).
Future<void> mostrarSenhaTemporaria({
  required String nome,
  required String login,
  required String senha,
}) =>
    Get.dialog<void>(
      AlertDialog(
        title: const Text('Senha temporária'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Passe estes dados para $nome. No primeiro acesso ele(a) será obrigado(a) a trocar a senha.'),
            const SizedBox(height: 16),
            Text('Login: $login'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Senha: '),
                SelectableText(senha,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ],
            ),
            const SizedBox(height: 12),
            Text('Esta senha não será mostrada de novo.', style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: 'Login: $login\nSenha: $senha'));
              Get.snackbar('Copiado', 'Login e senha copiados.', snackPosition: SnackPosition.BOTTOM);
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copiar'),
          ),
          FilledButton(onPressed: () => Get.back(), child: const Text('Fechar')),
        ],
      ),
    );
