import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/formatters.dart';
import '../../../core/widgets.dart';
import 'financeiro_controller.dart';

class FinanceiroView extends GetView<FinanceiroController> {
  const FinanceiroView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Financeiro'),
          bottom: const TabBar(tabs: [Tab(text: 'Resumo'), Tab(text: 'Despesas')]),
        ),
        body: Column(
          children: [
            Obx(() => SeletorMes(
                  mes: controller.mes.value,
                  onAnterior: controller.mesAnterior,
                  onProximo: controller.proximoMes,
                )),
            Expanded(
              child: Obx(() {
                if (controller.loading.value && controller.resumo.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.erro.value != null && controller.resumo.value == null) {
                  return ErroTentar(mensagem: controller.erro.value!, onTentar: controller.carregar);
                }
                return const TabBarView(children: [_AbaResumo(), _AbaDespesas()]);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _AbaResumo extends GetView<FinanceiroController> {
  const _AbaResumo();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final r = controller.resumo.value;
      if (r == null) return const SizedBox.shrink();
      final verde = Colors.green.shade700;
      final vermelho = Colors.red.shade700;

      return RefreshIndicator(
        onRefresh: controller.carregar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: (r.resultado >= 0 ? verde : vermelho).withOpacity(0.10),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Resultado do mês', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(fmtMoeda(r.resultado),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(color: r.resultado >= 0 ? verde : vermelho, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Receita − despesas', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _Linha('Receita (pagamentos recebidos)', r.receita, Icons.south_west, verde),
            _Linha('Despesas lançadas', r.despesas, Icons.north_east, vermelho),
            _Linha('A receber (OS em aberto)', r.aReceber, Icons.hourglass_bottom, Colors.indigo),
            const SizedBox(height: 16),
            Text('Custos do período (informativo)', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            _Linha('Material consumido', r.materialConsumido, Icons.inventory_2_outlined, Colors.brown),
            _Linha('Mão de obra estimada', r.maoDeObraEstimada, Icons.engineering, Colors.brown),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Material e mão de obra não entram no resultado acima: a mão de obra usa as horas '
                'trabalhadas × valor da hora de cada funcionário, e o material sai do estoque.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Linha extends StatelessWidget {
  const _Linha(this.titulo, this.valor, this.icone, this.cor);
  final String titulo;
  final double valor;
  final IconData icone;
  final Color cor;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(icone, color: cor),
          title: Text(titulo),
          trailing: Text(fmtMoeda(valor), style: Theme.of(context).textTheme.titleMedium),
        ),
      );
}

class _AbaDespesas extends GetView<FinanceiroController> {
  const _AbaDespesas();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final itens = controller.despesas;
      return RefreshIndicator(
        onRefresh: controller.carregar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Total: ${fmtMoeda(controller.totalDespesas)}',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                FilledButton.tonalIcon(
                  onPressed: controller.novaDespesa,
                  icon: const Icon(Icons.add),
                  label: const Text('Nova despesa'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (itens.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: Text('Nenhuma despesa neste mês.')),
              ),
            ...itens.map((d) => Card(
                  margin: const EdgeInsets.only(top: 8),
                  child: ListTile(
                    title: Text(d.descricao),
                    subtitle: Text('${d.categoria} • ${fmtData(d.data)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(fmtMoeda(d.valor), style: Theme.of(context).textTheme.titleSmall),
                        PopupMenuButton<String>(
                          onSelected: (a) => a == 'editar' ? controller.editarDespesa(d) : controller.excluirDespesa(d),
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'editar', child: Text('Editar')),
                            PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      );
    });
  }
}
