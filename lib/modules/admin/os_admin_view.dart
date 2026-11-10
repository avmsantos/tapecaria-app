import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/formatters.dart';
import '../../core/widgets.dart';
import '../../data/models/ordem_servico_model.dart';
import 'os_admin_controller.dart';

class OsAdminView extends GetView<OsAdminController> {
  const OsAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OS #${controller.osId}'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Alterar status',
            icon: const Icon(Icons.swap_horiz),
            onSelected: controller.mudarStatus,
            itemBuilder: (_) => statusLabels.entries
                .map((e) => PopupMenuItem(value: e.key, child: Text('Marcar como ${e.value.toLowerCase()}')))
                .toList(),
          ),
        ],
      ),
      body: Obx(() {
        final os = controller.os.value;

        if (controller.loading.value && os == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (os == null) {
          return ErroTentar(
            mensagem: controller.erro.value ?? 'Não foi possível carregar a OS.',
            onTentar: controller.carregar,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.carregar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(child: Text(os.titulo, style: Theme.of(context).textTheme.titleLarge)),
                  StatusChip(os.status),
                ],
              ),
              const SizedBox(height: 4),
              Text('Orçamento: ${fmtMoeda(os.valorOrcado)}'),
              const SizedBox(height: 16),
              _clienteVeiculo(os),
              _veiculoNaLoja(context),
              SecaoCard(
                titulo: 'O que precisa ser feito',
                child: Text((os.instrucoes?.trim().isNotEmpty ?? false) ? os.instrucoes! : 'Sem instruções.'),
              ),
              _equipe(os),
              _agenda(context, os),
              _tempo(context, os),
            ],
          ),
        );
      }),
    );
  }

  Widget _clienteVeiculo(OrdemServicoModel os) => SecaoCard(
        titulo: 'Cliente e veículo',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(os.clienteNome, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (os.clienteTelefone?.isNotEmpty ?? false) Text(os.clienteTelefone!),
            const SizedBox(height: 8),
            Text(os.veiculoTitulo),
            if (os.veiculoPlaca?.isNotEmpty ?? false) Text('Placa: ${os.veiculoPlaca}'),
            if (os.veiculoCor?.isNotEmpty ?? false) Text('Cor: ${os.veiculoCor}'),
          ],
        ),
      );

  Widget _veiculoNaLoja(BuildContext context) => Obx(() {
        final naLoja = controller.veiculoNaLoja;
        final ocupado = controller.acting.value;
        return SecaoCard(
          titulo: 'Localização do veículo',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(naLoja ? Icons.store : Icons.exit_to_app, size: 20),
                  const SizedBox(width: 8),
                  Text(naLoja
                      ? 'Na loja'
                      : (controller.ultimoMovimento.value == 'saida'
                          ? 'Já saiu (entregue ao cliente)'
                          : 'Ainda não deu entrada')),
                ],
              ),
              const SizedBox(height: 12),
              if (naLoja)
                OutlinedButton.icon(
                  onPressed: ocupado ? null : () => _pedirQuemRetirou(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Registrar saída'),
                )
              else if (controller.ultimoMovimento.value == null)
                FilledButton.icon(
                  onPressed: ocupado ? null : controller.registrarEntrada,
                  icon: const Icon(Icons.login),
                  label: const Text('Registrar entrada'),
                ),
            ],
          ),
        );
      });

  Widget _equipe(OrdemServicoModel os) => SecaoCard(
        titulo: 'Funcionários',
        acao: TextButton(onPressed: controller.alterarFuncionarios, child: const Text('Alterar')),
        child: os.funcionarios.isEmpty
            ? const Text('Nenhum funcionário designado.')
            : Column(
                children: os.funcionarios
                    .map((f) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: const Icon(Icons.engineering),
                          title: Text(f.nome),
                          subtitle: Text(f.aceitoEm == null ? 'Ainda não aceitou' : 'Aceitou em ${fmtDataHora(f.aceitoEm)}'),
                        ))
                    .toList(),
              ),
      );

  Widget _agenda(BuildContext context, OrdemServicoModel os) => SecaoCard(
        titulo: 'Agenda',
        acao: TextButton.icon(
          onPressed: controller.agendar,
          icon: const Icon(Icons.add),
          label: const Text('Agendar'),
        ),
        child: os.agendamentos.isEmpty
            ? const Text('Nenhum agendamento.')
            : Column(
                children: os.agendamentos.map((a) {
                  final encerrado = a.status == 'realizado' || a.status == 'cancelado';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(a.tipoLabel),
                    subtitle: Text(
                      '${fmtDataHora(a.dataHora)}${a.status == 'agendado' ? '' : ' • ${a.status}'}',
                    ),
                    trailing: encerrado
                        ? null
                        : PopupMenuButton<String>(
                            onSelected: (s) => controller.marcarAgendamento(a.id, s),
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'realizado', child: Text('Marcar como realizado')),
                              PopupMenuItem(value: 'cancelado', child: Text('Cancelar')),
                            ],
                          ),
                  );
                }).toList(),
              ),
      );

  Widget _tempo(BuildContext context, OrdemServicoModel os) => SecaoCard(
        titulo: 'Tempo de trabalho',
        child: os.apontamentos.isEmpty
            ? const Text('Nenhum turno registrado ainda.')
            : Column(
                children: os.apontamentos
                    .map((a) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: const Icon(Icons.timer_outlined),
                          title: Text(a.funcionarioNome),
                          subtitle: Text(a.fim == null
                              ? 'Iniciou em ${fmtDataHora(a.inicio)} • em andamento'
                              : '${fmtDataHora(a.inicio)} até ${fmtHora(a.fim)}'),
                        ))
                    .toList(),
              ),
      );

  Future<void> _pedirQuemRetirou() async {
    final ctrl = TextEditingController();
    final nome = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Saída do veículo'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Quem está retirando?'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Get.back(result: ctrl.text.trim()), child: const Text('Registrar')),
        ],
      ),
    );
    if (nome != null && nome.isNotEmpty) controller.registrarSaida(nome);
  }
}
