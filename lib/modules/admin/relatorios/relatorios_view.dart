import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/formatters.dart';
import '../../../core/widgets.dart';
import 'relatorios_controller.dart';

class RelatoriosView extends GetView<RelatoriosController> {
  const RelatoriosView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: controller.abaInicial.clamp(0, 3),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Relatórios'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [Tab(text: 'Equipe'), Tab(text: 'Serviços'), Tab(text: 'Materiais'), Tab(text: 'Leads')],
          ),
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
                if (controller.loading.value && controller.servicos.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.erro.value != null && controller.servicos.value == null) {
                  return ErroTentar(mensagem: controller.erro.value!, onTentar: controller.carregar);
                }
                return const TabBarView(children: [_AbaEquipe(), _AbaServicos(), _AbaMateriais(), _AbaLeads()]);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _lista(Future<void> Function() onRefresh, List<Widget> filhos) => RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: filhos,
      ),
    );

Widget _vazio(String texto) => Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(child: Text(texto, textAlign: TextAlign.center)),
    );

// ===================== EQUIPE =====================
class _AbaEquipe extends GetView<RelatoriosController> {
  const _AbaEquipe();

  @override
  Widget build(BuildContext context) => Obx(() {
        final itens = controller.equipe;
        return _lista(controller.carregar, [
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Horas trabalhadas no mês'),
              trailing: Text('${fmtQtd(controller.totalHoras)} h', style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          if (itens.isEmpty) _vazio('Nenhum funcionário cadastrado.'),
          ...itens.map((f) => Card(
                margin: const EdgeInsets.only(top: 8),
                child: ListTile(
                  onTap: () => controller.abrirFuncionario(f),
                  leading: CircleAvatar(child: Text(f.nome.isEmpty ? '?' : f.nome[0].toUpperCase())),
                  title: Text(f.nome),
                  subtitle: Text('${f.servicos} serviço(s)${f.funcao?.isNotEmpty ?? false ? ' • ${f.funcao}' : ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${fmtQtd(f.horas)} h', style: Theme.of(context).textTheme.titleMedium),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              )),
        ]);
      });
}

// ===================== SERVIÇOS POR DIA =====================
class _AbaServicos extends GetView<RelatoriosController> {
  const _AbaServicos();

  @override
  Widget build(BuildContext context) => Obx(() {
        final r = controller.servicos.value;
        if (r == null) return const SizedBox.shrink();
        final maior = r.dias.fold<int>(1, (m, d) => d.total > m ? d.total : m);

        return _lista(controller.carregar, [
          Card(
            child: ListTile(
              leading: const Icon(Icons.task_alt),
              title: const Text('Serviços concluídos no mês'),
              trailing: Text('${r.total}', style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          if (r.dias.isEmpty) _vazio('Nenhum serviço concluído neste mês.'),
          ...r.dias.map((d) => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    SizedBox(width: 64, child: Text(fmtData(d.dia).substring(0, 5))),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(value: d.total / maior, minHeight: 14),
                      ),
                    ),
                    SizedBox(width: 32, child: Text('${d.total}', textAlign: TextAlign.end)),
                  ],
                ),
              )),
        ]);
      });
}

// ===================== MATERIAIS =====================
class _AbaMateriais extends GetView<RelatoriosController> {
  const _AbaMateriais();

  @override
  Widget build(BuildContext context) => Obx(() {
        final r = controller.materiais.value;
        if (r == null) return const SizedBox.shrink();
        final cores = Theme.of(context).colorScheme;

        return _lista(controller.carregar, [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.output),
                  title: const Text('Consumido no mês'),
                  trailing: Text(fmtMoeda(r.totalConsumido), style: Theme.of(context).textTheme.titleMedium),
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart_outlined),
                  title: const Text('Comprado no mês'),
                  trailing: Text(fmtMoeda(r.totalComprado), style: Theme.of(context).textTheme.titleMedium),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SecaoCard(
            titulo: 'Consumo por material',
            child: r.consumo.isEmpty
                ? const Text('Nenhuma saída de material neste mês.')
                : Column(
                    children: r.consumo
                        .map((c) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              title: Text(c.nome),
                              subtitle: Text('${fmtQtd(c.quantidade)} ${c.unidade}'),
                              trailing: Text(fmtMoeda(c.custo)),
                            ))
                        .toList(),
                  ),
          ),
          if (r.estoqueBaixo.isNotEmpty)
            SecaoCard(
              titulo: 'Estoque baixo',
              child: Column(
                children: r.estoqueBaixo
                    .map((e) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: Icon(Icons.warning_amber, color: cores.error),
                          title: Text(e.nome),
                          subtitle: Text('Mínimo: ${fmtQtd(e.minimo)} ${e.unidade}'),
                          trailing: Text('${fmtQtd(e.atual)} ${e.unidade}',
                              style: TextStyle(color: cores.error, fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
              ),
            ),
        ]);
      });
}

// ===================== LEADS =====================
class _AbaLeads extends GetView<RelatoriosController> {
  const _AbaLeads();

  static const _etapas = {
    'novo': 'Novos',
    'em_atendimento': 'Em atendimento',
    'orcamento': 'Em orçamento',
    'fechado': 'Fechados',
    'perdido': 'Perdidos',
  };

  @override
  Widget build(BuildContext context) => Obx(() {
        final r = controller.leads.value;
        if (r == null) return const SizedBox.shrink();

        return _lista(controller.carregar, [
          SecaoCard(
            titulo: 'Contatos do mês por etapa',
            child: r.porEtapa.isEmpty
                ? const Text('Nenhum contato registrado neste mês.')
                : Column(
                    children: _etapas.entries
                        .where((e) => r.porEtapa.containsKey(e.key))
                        .map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [Text(e.value), Text('${r.porEtapa[e.key]}')],
                              ),
                            ))
                        .toList(),
                  ),
          ),
          SecaoCard(
            titulo: 'Por que os clientes não fecharam (${r.totalPerdidos})',
            child: r.motivos.isEmpty
                ? const Text('Nenhum contato perdido neste mês.')
                : Column(
                    children: r.motivos
                        .map((m) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              title: Text(m.motivo),
                              trailing: Text('${m.total}', style: Theme.of(context).textTheme.titleMedium),
                            ))
                        .toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Os contatos entram aqui quando forem cadastrados (hoje manualmente; com o WhatsApp integrado, automaticamente).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ]);
      });
}
