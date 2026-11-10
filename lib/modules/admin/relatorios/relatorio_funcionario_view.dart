import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/formatters.dart';
import '../../../core/widgets.dart';
import 'relatorio_funcionario_controller.dart';

class RelatorioFuncionarioView extends GetView<RelatorioFuncionarioController> {
  const RelatorioFuncionarioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(controller.nome)),
      body: Column(
        children: [
          Obx(() => SeletorMes(
                mes: controller.mes.value,
                onAnterior: controller.mesAnterior,
                onProximo: controller.proximoMes,
              )),
          Expanded(
            child: Obx(() {
              final d = controller.detalhe.value;
              if (controller.loading.value && d == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (d == null) {
                return ErroTentar(
                  mensagem: controller.erro.value ?? 'Não foi possível carregar o relatório.',
                  onTentar: controller.carregar,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.carregar,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text('Total de horas no mês', style: Theme.of(context).textTheme.labelLarge),
                            const SizedBox(height: 4),
                            Text('${fmtQtd(d.totalHoras)} h', style: Theme.of(context).textTheme.displaySmall),
                            Text('${d.turnos.length} turno(s) de trabalho',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SecaoCard(
                      titulo: 'Horas por semana',
                      child: d.semanas.isEmpty
                          ? const Text('Sem horas registradas.')
                          : Column(
                              children: d.semanas
                                  .map((s) => ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        title: Text('Semana de ${fmtData(s.semana)}'),
                                        subtitle: Text('${s.servicos} serviço(s)'),
                                        trailing: Text('${fmtQtd(s.horas)} h',
                                            style: Theme.of(context).textTheme.titleSmall),
                                      ))
                                  .toList(),
                            ),
                    ),
                    SecaoCard(
                      titulo: 'Serviços feitos',
                      child: d.turnos.isEmpty
                          ? const Text('Nenhum serviço neste mês.')
                          : Column(
                              children: d.turnos
                                  .map((t) => ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        title: Text('#${t.osId}  ${t.titulo}'),
                                        subtitle: Text('${fmtDataHora(t.inicio)} até ${fmtHora(t.fim)}'),
                                        trailing: Text('${fmtQtd(t.horas)} h'),
                                      ))
                                  .toList(),
                            ),
                    ),
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
