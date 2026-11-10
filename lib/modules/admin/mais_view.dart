import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets.dart';
import '../../routes/app_routes.dart';
import '../auth/auth_controller.dart';

class MaisView extends StatelessWidget {
  const MaisView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mais')),
      body: ListView(
        children: [
          Obx(() => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(auth.user.value?.nome ?? ''),
                subtitle: const Text('Administrador'),
              )),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.engineering),
            title: const Text('Funcionários'),
            subtitle: const Text('Cadastro, acesso e senhas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(Routes.adminFuncionarios),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('Materiais'),
            subtitle: const Text('Estoque, compras e consumo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(Routes.adminMateriais),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () async {
              if (await confirmar('Sair', 'Deseja encerrar a sessão?', confirmarLabel: 'Sair')) {
                auth.logout();
              }
            },
          ),
        ],
      ),
    );
  }
}
