import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/formatters.dart';
import '../../core/widgets.dart';
import 'os_nova_controller.dart';
import 'widgets/forms_dialogs.dart';

class OsNovaView extends GetView<OsNovaController> {
  const OsNovaView({super.key});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Nova ordem de serviço')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------- Cliente ----------
          SecaoCard(
            titulo: 'Cliente',
            child: Obx(() {
              final c = controller.cliente.value;
              if (c == null) {
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _escolherCliente(context),
                    icon: const Icon(Icons.person_search),
                    label: const Text('Escolher cliente'),
                  ),
                );
              }
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(c.nome),
                subtitle: Text(c.telefone),
                trailing: TextButton(onPressed: () => _escolherCliente(context), child: const Text('Trocar')),
              );
            }),
          ),

          // ---------- Veículo ----------
          SecaoCard(
            titulo: 'Veículo',
            acao: TextButton.icon(
              onPressed: controller.novoVeiculo,
              icon: const Icon(Icons.add),
              label: const Text('Novo'),
            ),
            child: Obx(() {
              if (controller.cliente.value == null) {
                return const Text('Escolha o cliente para ver os veículos.');
              }
              if (controller.veiculos.isEmpty) {
                return const Text('Este cliente ainda não tem veículo. Toque em "Novo".');
              }
              return DropdownButtonFormField<int>(
                value: controller.veiculo.value?.id,
                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                hint: const Text('Selecione o veículo'),
                items: controller.veiculos
                    .map((v) => DropdownMenuItem(value: v.id, child: Text(v.rotulo)))
                    .toList(),
                onChanged: (id) =>
                    controller.veiculo.value = controller.veiculos.firstWhere((v) => v.id == id),
              );
            }),
          ),

          // ---------- Serviço ----------
          SecaoCard(
            titulo: 'Serviço',
            child: Column(
              children: [
                TextField(
                  controller: controller.tituloCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Título (ex.: Troca de couro do banco)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.instrucoesCtrl,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'O que precisa ser feito',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.valorCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Valor do orçamento', prefixText: 'R\$ '),
                ),
              ],
            ),
          ),

          // ---------- Funcionários ----------
          SecaoCard(
            titulo: 'Funcionários',
            child: Obx(() {
              if (controller.funcionarios.isEmpty) {
                return const Text('Nenhum funcionário ativo cadastrado.');
              }
              return Wrap(
                spacing: 8,
                children: controller.funcionarios
                    .map((f) => FilterChip(
                          label: Text(f.nome),
                          selected: controller.selecionados.contains(f.id),
                          onSelected: (_) => controller.alternarFuncionario(f.id),
                        ))
                    .toList(),
              );
            }),
          ),

          // ---------- Agendamento ----------
          SecaoCard(
            titulo: 'Entrada do veículo (opcional)',
            child: Obx(() {
              final d = controller.entrada.value;
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final nova = await escolherDataHora(context, inicial: d);
                        if (nova != null) controller.entrada.value = nova;
                      },
                      icon: const Icon(Icons.event),
                      label: Text(d == null ? 'Escolher data e hora' : fmtDataHora(d)),
                    ),
                  ),
                  if (d != null)
                    IconButton(
                      tooltip: 'Remover',
                      icon: const Icon(Icons.close),
                      onPressed: () => controller.entrada.value = null,
                    ),
                ],
              );
            }),
          ),

          Obx(() => controller.erro.value == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(controller.erro.value!, style: TextStyle(color: cores.error)),
                )),

          Obx(() => FilledButton(
                onPressed: controller.saving.value ? null : controller.salvar,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: controller.saving.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Criar ordem de serviço'),
                ),
              )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _escolherCliente(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.75,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  autofocus: true,
                  onChanged: (v) => controller.termo.value = v,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nome ou telefone',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Cadastrar novo cliente'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await controller.novoCliente();
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: Obx(() {
                  if (controller.buscando.value && controller.resultados.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.resultados.isEmpty) {
                    return const Center(child: Text('Nenhum cliente encontrado.'));
                  }
                  return ListView.builder(
                    itemCount: controller.resultados.length,
                    itemBuilder: (_, i) {
                      final c = controller.resultados[i];
                      return ListTile(
                        title: Text(c.nome),
                        subtitle: Text(c.telefone),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          controller.selecionarCliente(c);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
