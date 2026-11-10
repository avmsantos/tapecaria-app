import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/formatters.dart';
import '../../core/widgets.dart';
import 'funcionarios_controller.dart';

class FuncionariosView extends GetView<FuncionariosController> {
  const FuncionariosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Funcionários')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.novo,
        icon: const Icon(Icons.person_add),
        label: const Text('Novo funcionário'),
      ),
      body: Column(
        children: [
          Obx(() => SwitchListTile(
                title: const Text('Mostrar inativos'),
                value: controller.mostrarInativos.value,
                onChanged: controller.alternarInativos,
              )),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              if (controller.loading.value && controller.lista.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.erro.value != null && controller.lista.isEmpty) {
                return ErroTentar(mensagem: controller.erro.value!, onTentar: controller.carregar);
              }
              if (controller.lista.isEmpty) {
                return const Center(child: Text('Nenhum funcionário cadastrado.'));
              }
              return RefreshIndicator(
                onRefresh: controller.carregar,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: controller.lista.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final f = controller.lista[i];
                    final detalhe = [
                      if (f.funcao?.isNotEmpty ?? false) f.funcao!,
                      'login: ${f.login}',
                      if (f.valorHora != null) '${fmtMoeda(f.valorHora)}/h',
                    ].join(' • ');

                    return ListTile(
                      enabled: f.ativo,
                      leading: CircleAvatar(child: Text(f.nome.isEmpty ? '?' : f.nome[0].toUpperCase())),
                      title: Text(f.nome),
                      subtitle: Text(f.ativo ? detalhe : 'Inativo • $detalhe'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (acao) {
                          switch (acao) {
                            case 'editar':
                              controller.editar(f);
                              break;
                            case 'senha':
                              controller.redefinirSenha(f);
                              break;
                            case 'ativo':
                              controller.alternarAtivo(f);
                              break;
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'editar', child: Text('Editar')),
                          if (f.ativo) const PopupMenuItem(value: 'senha', child: Text('Redefinir senha')),
                          PopupMenuItem(value: 'ativo', child: Text(f.ativo ? 'Desativar' : 'Reativar')),
                        ],
                      ),
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
