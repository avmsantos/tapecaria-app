import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/formatters.dart';
import '../../core/widgets.dart';
import '../../data/models/ordem_servico_model.dart';
import 'ordens_controller.dart';

class OrdensView extends GetView<OrdensController> {
  const OrdensView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de serviço'),
        actions: [IconButton(tooltip: 'Atualizar', icon: const Icon(Icons.refresh), onPressed: controller.carregar)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.nova,
        icon: const Icon(Icons.add),
        label: const Text('Nova OS'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  children: [
                    _Filtro('Todas', controller.filtro.value == null, () => controller.filtrar(null)),
                    for (final e in statusLabels.entries)
                      _Filtro(e.value, controller.filtro.value == e.key, () => controller.filtrar(e.key)),
                  ],
                )),
          ),
          Expanded(
            child: Obx(() {
              if (controller.loading.value && controller.lista.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.erro.value != null && controller.lista.isEmpty) {
                return ErroTentar(mensagem: controller.erro.value!, onTentar: controller.carregar);
              }
              return RefreshIndicator(
                onRefresh: controller.carregar,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  children: [
                    if (controller.lista.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(child: Text('Nenhuma ordem de serviço encontrada.')),
                      ),
                    ...controller.lista.map((os) => _OsCard(os: os, onTap: () => controller.abrir(os.id))),
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

class _Filtro extends StatelessWidget {
  const _Filtro(this.label, this.selecionado, this.onTap);
  final String label;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(label: Text(label), selected: selecionado, onSelected: (_) => onTap()),
      );
}

class _OsCard extends StatelessWidget {
  const _OsCard({required this.os, required this.onTap});
  final OrdemServicoModel os;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final detalhe = [os.clienteNome, if (os.veiculoTitulo.isNotEmpty) os.veiculoTitulo].join(' • ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('#${os.id}  ${os.titulo}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  StatusChip(os.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(detalhe),
              if (os.funcionariosNomes.isNotEmpty)
                Text('Equipe: ${os.funcionariosNomes}', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(fmtMoeda(os.valorFinal ?? os.valorOrcado), style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
