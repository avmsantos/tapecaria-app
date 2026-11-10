import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/formatters.dart';
import '../../../core/widgets.dart';
import 'materiais_controller.dart';

class MateriaisView extends GetView<MateriaisController> {
  const MateriaisView({super.key});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Materiais')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.novo,
        icon: const Icon(Icons.add),
        label: const Text('Novo material'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => controller.busca.value = v,
              decoration: const InputDecoration(
                hintText: 'Buscar material',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Obx(() => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChip(
                    label: const Text('Só estoque baixo'),
                    selected: controller.somenteBaixo.value,
                    onSelected: (v) => controller.somenteBaixo.value = v,
                  ),
                ),
              )),
          Obx(() {
            if (controller.lista.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Valor em estoque: ${fmtMoeda(controller.valorTotalEstoque)}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                  if (controller.qtdEstoqueBaixo > 0)
                    Text('${controller.qtdEstoqueBaixo} com estoque baixo',
                        style: TextStyle(color: cores.error, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              if (controller.loading.value && controller.lista.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.erro.value != null && controller.lista.isEmpty) {
                return ErroTentar(mensagem: controller.erro.value!, onTentar: controller.carregar);
              }
              final itens = controller.filtrados;
              if (itens.isEmpty) {
                return const Center(child: Text('Nenhum material cadastrado.'));
              }
              return RefreshIndicator(
                onRefresh: controller.carregar,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: itens.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final m = itens[i];
                    return ListTile(
                      onTap: () => controller.abrir(m.id),
                      leading: CircleAvatar(
                        backgroundColor: m.abaixoDoMinimo ? cores.errorContainer : null,
                        child: Icon(m.abaixoDoMinimo ? Icons.warning_amber : Icons.inventory_2_outlined,
                            color: m.abaixoDoMinimo ? cores.error : null),
                      ),
                      title: Text(m.nome),
                      subtitle: Text(m.custoUnitario == null
                          ? 'Mínimo: ${fmtQtd(m.estoqueMinimo)} ${m.unidade}'
                          : '${fmtMoeda(m.custoUnitario)} por ${m.unidade} • mínimo ${fmtQtd(m.estoqueMinimo)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${fmtQtd(m.estoqueAtual)} ${m.unidade}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: m.abaixoDoMinimo ? cores.error : null,
                                  )),
                          if (m.abaixoDoMinimo)
                            Text('Estoque baixo', style: TextStyle(color: cores.error, fontSize: 11)),
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
