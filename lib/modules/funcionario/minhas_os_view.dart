import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/formatters.dart';
import '../../data/models/ordem_servico_model.dart';
import '../auth/auth_controller.dart';
import 'minhas_os_controller.dart';

class MinhasOsView extends GetView<MinhasOsController> {
  const MinhasOsView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Olá, ${auth.user.value?.nome.split(' ').first ?? ''}')),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: auth.logout,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value && controller.lista.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.erro.value != null && controller.lista.isEmpty) {
          return _Erro(mensagem: controller.erro.value!, onTentar: controller.carregar);
        }

        final atual = controller.atual.value;

        return RefreshIndicator(
          onRefresh: controller.carregar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (atual != null)
                Card(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: const Text('Serviço em andamento'),
                    subtitle: Text(atual.osTitulo ?? 'OS #${atual.osId}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => controller.abrir(atual.osId),
                  ),
                ),
              if (controller.lista.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: Text('Nenhum serviço para você no momento.')),
                ),
              if (controller.meus.isNotEmpty) const _Titulo('Seus serviços'),
              ...controller.meus.map((os) => _OsCard(os: os, onTap: () => controller.abrir(os.id))),
              if (controller.disponiveis.isNotEmpty) const _Titulo('Disponíveis para pegar'),
              ...controller.disponiveis.map((os) => _OsCard(os: os, onTap: () => controller.abrir(os.id))),
            ],
          ),
        );
      }),
    );
  }
}

class _OsCard extends StatelessWidget {
  const _OsCard({required this.os, required this.onTap});

  final OrdemServicoModel os;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final agendamento = os.proximoAgendamento;
    final cor = statusColor(os.status);
    final placa = (os.veiculoPlaca != null && os.veiculoPlaca!.isNotEmpty) ? ' • ${os.veiculoPlaca}' : '';

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
                    child: Text(os.titulo,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  Chip(
                    label: Text(statusLabel(os.status), style: TextStyle(color: cor, fontSize: 12)),
                    side: BorderSide(color: cor),
                    backgroundColor: cor.withOpacity(0.08),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${os.veiculoTitulo}$placa'),
              Text('Cliente: ${os.clienteNome}'),
              if (agendamento != null) ...[
                const SizedBox(height: 4),
                Text('${agendamento.tipoLabel}: ${fmtDataHora(agendamento.dataHora)}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(os.livre ? Icons.inbox : (os.aceito ? Icons.check_circle : Icons.fiber_new),
                      size: 18,
                      color: os.livre ? Colors.orange : (os.aceito ? Colors.green : Colors.indigo)),
                  const SizedBox(width: 6),
                  Text(
                      os.livre
                          ? 'Disponível — aceite para pegar este serviço'
                          : (os.aceito ? 'Você aceitou' : 'Novo — aguardando seu aceite'),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Erro extends StatelessWidget {
  const _Erro({required this.mensagem, required this.onTentar});

  final String mensagem;
  final VoidCallback onTentar;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(mensagem, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onTentar, child: const Text('Tentar novamente')),
            ],
          ),
        ),
      );
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(texto, style: Theme.of(context).textTheme.titleSmall),
      );
}
