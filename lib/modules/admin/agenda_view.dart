import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/formatters.dart';
import '../../core/widgets.dart';
import '../../data/models/agenda_item_model.dart';
import 'agenda_controller.dart';

class AgendaView extends GetView<AgendaController> {
  const AgendaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [IconButton(tooltip: 'Atualizar', icon: const Icon(Icons.refresh), onPressed: controller.carregar)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Obx(() => SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 7, label: Text('7 dias')),
                    ButtonSegment(value: 30, label: Text('30 dias')),
                    ButtonSegment(value: 90, label: Text('90 dias')),
                  ],
                  selected: {controller.dias.value},
                  onSelectionChanged: (s) => controller.mudarDias(s.first),
                )),
          ),
          Expanded(
            child: Obx(() {
              if (controller.loading.value && controller.itens.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.erro.value != null && controller.itens.isEmpty) {
                return ErroTentar(mensagem: controller.erro.value!, onTentar: controller.carregar);
              }

              final grupos = controller.porDia.entries.toList();

              return RefreshIndicator(
                onRefresh: controller.carregar,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    if (grupos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(child: Text('Nenhum agendamento neste período.')),
                      ),
                    for (final g in grupos) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(fmtDiaSemana(g.key), style: Theme.of(context).textTheme.titleSmall),
                      ),
                      ...g.value.map((i) => _AgendaCard(item: i, onTap: () => controller.abrir(i))),
                    ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AgendaCard extends StatelessWidget {
  const _AgendaCard({required this.item, required this.onTap});

  final AgendaItemModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inativo = item.status == 'cancelado' || item.status == 'realizado';
    final detalhe = [item.clienteNome, if (item.veiculoTitulo.isNotEmpty) item.veiculoTitulo].join(' • ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: inativo ? Theme.of(context).colorScheme.surfaceContainerHighest : null,
      child: ListTile(
        onTap: onTap,
        leading: Text(
          fmtHora(item.dataHora),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        title: Text('${item.tipoLabel} — ${item.osTitulo}'),
        subtitle: Text(detalhe),
        trailing: inativo
            ? Text(item.status == 'realizado' ? 'Realizado' : 'Cancelado',
                style: Theme.of(context).textTheme.bodySmall)
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
