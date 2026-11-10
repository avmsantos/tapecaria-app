import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets.dart';
import 'clientes_controller.dart';

class ClientesView extends GetView<ClientesController> {
  const ClientesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.novo,
        icon: const Icon(Icons.person_add),
        label: const Text('Novo cliente'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => controller.busca.value = v,
              decoration: const InputDecoration(
                hintText: 'Buscar por nome ou telefone',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.loading.value && controller.lista.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.erro.value != null && controller.lista.isEmpty) {
                return ErroTentar(mensagem: controller.erro.value!, onTentar: controller.carregar);
              }
              if (controller.lista.isEmpty) {
                return const Center(child: Text('Nenhum cliente encontrado.'));
              }
              return RefreshIndicator(
                onRefresh: controller.carregar,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: controller.lista.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final c = controller.lista[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text(c.nome.isEmpty ? '?' : c.nome[0].toUpperCase())),
                      title: Text(c.nome),
                      subtitle: Text(c.telefone),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => controller.abrir(c.id),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
