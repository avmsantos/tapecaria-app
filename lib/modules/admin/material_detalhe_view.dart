import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/formatters.dart';
import '../../core/widgets.dart';
import '../../data/models/material_model.dart';
import 'material_detalhe_controller.dart';

class MaterialDetalheView extends GetView<MaterialDetalheController> {
  const MaterialDetalheView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.material.value?.nome ?? 'Material')),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => v == 'editar' ? controller.editar() : controller.desativar(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'editar', child: Text('Editar')),
              PopupMenuItem(value: 'desativar', child: Text('Desativar')),
            ],
          ),
        ],
      ),
      body: Obx(() {
        final m = controller.material.value;

        if (controller.loading.value && m == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (m == null) {
          return ErroTentar(
            mensagem: controller.erro.value ?? 'Não foi possível carregar o material.',
            onTentar: controller.carregar,
          );
        }

        final cores = Theme.of(context).colorScheme;

        return RefreshIndicator(
          onRefresh: controller.carregar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: m.abaixoDoMinimo ? cores.errorContainer : cores.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('Em estoque', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text('${fmtQtd(m.estoqueAtual)} ${m.unidade}',
                          style: Theme.of(context).textTheme.displaySmall),
                      if (m.abaixoDoMinimo)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('Abaixo do mínimo (${fmtQtd(m.estoqueMinimo)} ${m.unidade})',
                              style: TextStyle(color: cores.error, fontWeight: FontWeight.w600)),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        '${fmtMoeda(m.custoUnitario)} por ${m.unidade}  •  total ${fmtMoeda(m.valorEmEstoque)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: controller.entrada,
                      icon: const Icon(Icons.add),
                      label: const Text('Entrada'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.saida,
                      icon: const Icon(Icons.remove),
                      label: const Text('Saída'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SecaoCard(
                titulo: 'Histórico',
                child: controller.movimentos.isEmpty
                    ? const Text('Nenhuma movimentação ainda.')
                    : Column(children: controller.movimentos.map((mv) => _Movimento(mv: mv, unidade: m.unidade)).toList()),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _Movimento extends StatelessWidget {
  const _Movimento({required this.mv, required this.unidade});
  final MovimentacaoMaterialModel mv;
  final String unidade;

  @override
  Widget build(BuildContext context) {
    final cor = mv.entrada ? Colors.green.shade700 : Colors.red.shade700;
    final detalhe = [
      fmtDataHora(mv.dataHora),
      if (mv.osId != null) 'OS #${mv.osId}',
      if (mv.observacao?.isNotEmpty ?? false) mv.observacao!,
    ].join(' • ');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(mv.entrada ? Icons.arrow_downward : Icons.arrow_upward, color: cor),
      title: Text('${mv.entrada ? '+' : '-'}${fmtQtd(mv.quantidade)} $unidade',
          style: TextStyle(color: cor, fontWeight: FontWeight.w600)),
      subtitle: Text(detalhe),
      trailing: Text(fmtMoeda(mv.total), style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
