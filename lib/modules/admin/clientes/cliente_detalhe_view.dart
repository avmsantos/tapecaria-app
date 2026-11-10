import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/formatters.dart';
import '../../../core/widgets.dart';
import 'cliente_detalhe_controller.dart';

class ClienteDetalheView extends GetView<ClienteDetalheController> {
  const ClienteDetalheView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cliente'),
        actions: [
          IconButton(tooltip: 'Editar cliente', icon: const Icon(Icons.edit), onPressed: controller.editarCliente),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.novaOs,
        icon: const Icon(Icons.add),
        label: const Text('Nova OS'),
      ),
      body: Obx(() {
        final c = controller.cliente.value;

        if (controller.loading.value && c == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c == null) {
          return ErroTentar(
            mensagem: controller.erro.value ?? 'Não foi possível carregar o cliente.',
            onTentar: controller.carregar,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.carregar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              SecaoCard(
                titulo: 'Dados',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.nome, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(c.telefone),
                    if (c.observacoes?.trim().isNotEmpty ?? false) ...[
                      const SizedBox(height: 8),
                      Text(c.observacoes!),
                    ],
                  ],
                ),
              ),
              SecaoCard(
                titulo: 'Veículos',
                acao: TextButton.icon(
                  onPressed: controller.novoVeiculo,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                ),
                child: c.veiculos.isEmpty
                    ? const Text('Nenhum veículo cadastrado.')
                    : Column(
                        children: c.veiculos
                            .map((v) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(v.tipo == 'moto' ? Icons.two_wheeler : Icons.directions_car),
                                  title: Text(v.titulo),
                                  trailing: IconButton(
                                    tooltip: 'Editar veículo',
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => controller.editarVeiculo(v),
                                  ),
                                  subtitle: Text([
                                    if (v.placa?.isNotEmpty ?? false) v.placa!,
                                    if (v.cor?.isNotEmpty ?? false) v.cor!,
                                    if (v.ano != null) '${v.ano}',
                                  ].join(' • ')),
                                ))
                            .toList(),
                      ),
              ),
              SecaoCard(
                titulo: 'Últimas ordens de serviço',
                child: c.ordens.isEmpty
                    ? const Text('Nenhuma OS para este cliente.')
                    : Column(
                        children: c.ordens
                            .map((o) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('#${o.id}  ${o.titulo}'),
                                  subtitle: Text(fmtMoeda(o.valorFinal ?? o.valorOrcado)),
                                  trailing: StatusChip(o.status),
                                  onTap: () => controller.abrirOs(o.id),
                                ))
                            .toList(),
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
