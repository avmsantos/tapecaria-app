import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.chair_alt, size: 72, color: cores.primary),
                  const SizedBox(height: 12),
                  Text('Tapeçaria & Capotaria',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 32),
                  TextField(
                    controller: controller.loginCtrl,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Login',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => TextField(
                        controller: controller.senhaCtrl,
                        obscureText: !controller.mostrarSenha.value,
                        onSubmitted: (_) => controller.entrar(),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(controller.mostrarSenha.value
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => controller.mostrarSenha.toggle(),
                          ),
                        ),
                      )),
                  Obx(() => controller.erro.value == null
                      ? const SizedBox(height: 16)
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(controller.erro.value!,
                              style: TextStyle(color: cores.error)),
                        )),
                  Obx(() => FilledButton(
                        onPressed: controller.loading.value ? null : controller.entrar,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: controller.loading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Entrar'),
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
