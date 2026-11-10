import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/formatters.dart';
import '../../data/models/ordem_servico_model.dart';
import 'os_detalhe_controller.dart';

class OsDetalheView extends GetView<OsDetalheController> {
  const OsDetalheView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Serviço #${controller.osId}')),
      body: Obx(() {
        final os = controller.os.value;

        if (controller.loading.value && os == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (os == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(controller.erro.value ?? 'Não foi possível carregar o serviço.'),
                const SizedBox(height: 12),
                FilledButton(onPressed: controller.carregar, child: const Text('Tentar novamente')),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.carregar,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    _Cabecalho(os: os),
                    if (controller.emAndamento) const _Cronometro(),
                    _Secao(
                      titulo: 'O que precisa ser feito',
                      child: Text(
                        (os.instrucoes?.trim().isNotEmpty ?? false)
                            ? os.instrucoes!
                            : 'Sem instruções cadastradas.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    if (os.descricao?.trim().isNotEmpty ?? false)
                      _Secao(titulo: 'Descrição', child: Text(os.descricao!)),
                    _Secao(
                      titulo: 'Veículo e cliente',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(os.veiculoTitulo, style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (os.veiculoPlaca?.isNotEmpty ?? false) Text('Placa: ${os.veiculoPlaca}'),
                          if (os.veiculoCor?.isNotEmpty ?? false) Text('Cor: ${os.veiculoCor}'),
                          const SizedBox(height: 8),
                          Text('Cliente: ${os.clienteNome}'),
                        ],
                      ),
                    ),
                    if (os.agendamentos.isNotEmpty)
                      _Secao(
                        titulo: 'Agenda',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: os.agendamentos
                              .map((a) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text('${a.tipoLabel}: ${fmtDataHora(a.dataHora)}'),
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const _Acoes(),
          ],
        );
      }),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.os});
  final OrdemServicoModel os;

  @override
  Widget build(BuildContext context) {
    final cor = statusColor(os.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(os.titulo, style: Theme.of(context).textTheme.titleLarge),
          ),
          Chip(
            label: Text(statusLabel(os.status), style: TextStyle(color: cor)),
            side: BorderSide(color: cor),
            backgroundColor: cor.withOpacity(0.08),
          ),
        ],
      ),
    );
  }
}

class _Cronometro extends GetView<OsDetalheController> {
  const _Cronometro();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pausado = controller.pausado;
      return Card(
        color: pausado ? Colors.amber.shade100 : Theme.of(context).colorScheme.primaryContainer,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(pausado ? 'Em pausa' : 'Trabalhando', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                fmtDuracao(controller.decorrido.value),
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _Secao extends StatelessWidget {
  const _Secao({required this.titulo, required this.child});
  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      );
}

/// Barra de ações no rodapé: muda conforme o estado do serviço.
class _Acoes extends GetView<OsDetalheController> {
  const _Acoes();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ocupado = controller.acting.value;
      Widget? conteudo;

      if (controller.emAndamento) {
        conteudo = Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: ocupado
                    ? null
                    : (controller.pausado ? controller.retomar : _pedirMotivoPausa),
                icon: Icon(controller.pausado ? Icons.play_arrow : Icons.pause),
                label: Text(controller.pausado ? 'Retomar' : 'Pausar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: ocupado ? null : _confirmarFinalizar,
                icon: const Icon(Icons.stop),
                label: const Text('Finalizar'),
              ),
            ),
          ],
        );
      } else if (controller.servicoEncerrado) {
        conteudo = null;
      } else if (!controller.aceito) {
        conteudo = SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: ocupado ? null : controller.aceitar,
            icon: const Icon(Icons.check),
            label: const Text('Aceitar serviço'),
          ),
        );
      } else if (controller.os.value?.status == 'aguardando_entrada') {
        conteudo = const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('Aguardando o veículo dar entrada na loja para iniciar.', textAlign: TextAlign.center),
        );
      } else {
        conteudo = SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: ocupado ? null : controller.iniciar,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar serviço'),
          ),
        );
      }

      if (conteudo == null) return const SizedBox.shrink();

      return SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
          ),
          child: ocupado
              ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
              : conteudo,
        ),
      );
    });
  }

  Future<void> _pedirMotivoPausa() async {
    final ctrl = TextEditingController();
    final motivo = await controller.comRelogioCongelado(() => Get.dialog<String>(
      AlertDialog(
        title: const Text('Pausar serviço'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Motivo (opcional)', hintText: 'Almoço, falta de material...'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Get.back(result: ctrl.text), child: const Text('Pausar')),
        ],
      ),
    ));
    if (motivo != null) controller.pausar(motivo);
  }

  Future<void> _confirmarFinalizar() async {
    final r = await controller.comRelogioCongelado(() => Get.dialog<String>(
      AlertDialog(
        title: const Text('Finalizar'),
        content: const Text('O serviço está pronto ou você só está encerrando o seu turno de trabalho?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          OutlinedButton(onPressed: () => Get.back(result: 'turno'), child: const Text('Só encerrar o turno')),
          FilledButton(onPressed: () => Get.back(result: 'pronto'), child: const Text('Serviço pronto')),
        ],
      ),
    ));
    if (r != null) controller.finalizar(concluirServico: r == 'pronto');
  }
}
