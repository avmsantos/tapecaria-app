import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() {
          final erro = controller.erro.value;
          if (erro == null) return const CircularProgressIndicator();
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 56),
                const SizedBox(height: 12),
                Text(erro, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(onPressed: controller.iniciar, child: const Text('Tentar novamente')),
              ],
            ),
          );
        }),
      ),
    );
  }
}
