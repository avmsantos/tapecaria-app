import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'trocar_senha_controller.dart';

class TrocarSenhaView extends GetView<TrocarSenhaController> {
  const TrocarSenhaView({super.key});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    Widget campo(TextEditingController c, String label, {bool ultimo = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextField(
            controller: c,
            obscureText: true,
            textInputAction: ultimo ? TextInputAction.done : TextInputAction.next,
            onSubmitted: ultimo ? (_) => controller.salvar() : null,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
            ),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Criar nova senha'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Por segurança, troque a senha temporária antes de continuar.'),
                  const SizedBox(height: 24),
                  campo(controller.atualCtrl, 'Senha atual (temporária)'),
                  campo(controller.novaCtrl, 'Nova senha'),
                  campo(controller.confirmaCtrl, 'Confirmar nova senha', ultimo: true),
                  Obx(() => controller.erro.value == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(controller.erro.value!,
                              style: TextStyle(color: cores.error)),
                        )),
                  Obx(() => FilledButton(
                        onPressed: controller.loading.value ? null : controller.salvar,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: controller.loading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Salvar nova senha'),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
