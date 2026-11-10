import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

import '../../../core/formatters.dart';
import '../../../core/widgets.dart';
import '../../auth/auth_controller.dart';
import 'admin_home_controller.dart';
import '../shell/admin_shell_controller.dart';

class AdminHomeView extends GetView<AdminHomeController> {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final shell = Get.find<AdminShellController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel'),
        actions: [
          IconButton(tooltip: 'Atualizar', icon: const Icon(Icons.refresh), onPressed: controller.carregar),
          IconButton(tooltip: 'Sair', icon: const Icon(Icons.logout), onPressed: auth.logout),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value && controller.dados.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.erro.value != null && controller.dados.isEmpty) {
          return ErroTentar(mensagem: controller.erro.value!, onTentar: controller.carregar);
        }

        final status = controller.osPorStatus;

        return RefreshIndicator(
          onRefresh: controller.carregar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _Kpi('Serviços hoje', controller.numero('servicos_concluidos_hoje'), Icons.today,
                      onTap: () => Get.toNamed(Routes.adminRelatorios, arguments: {'aba': 1})),
                  _Kpi('Serviços no mês', controller.numero('servicos_concluidos_mes'), Icons.calendar_month,
                      onTap: () => Get.toNamed(Routes.adminRelatorios, arguments: {'aba': 1})),
                  _Kpi('Agendamentos hoje', controller.numero('agendamentos_hoje'), Icons.event,
                      onTap: () => shell.ir(1)),
                  _Kpi('Veículos na loja', controller.numero('veiculos_na_loja'), Icons.two_wheeler,
                      onTap: () => shell.ir(2)),
                  _Kpi('Leads perdidos (mês)', controller.numero('leads_perdidos_mes'), Icons.person_off,
                      onTap: () => Get.toNamed(Routes.adminRelatorios, arguments: {'aba': 3})),
                  _Kpi('Estoque baixo', controller.numero('materiais_estoque_baixo'), Icons.inventory_2,
                      onTap: () => Get.toNamed(Routes.adminMateriais, arguments: {'somente_baixo': true})),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ordens de serviço por status', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      if (status.isEmpty) const Text('Nenhuma OS cadastrada.'),
                      ...status.entries.map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [Text(statusLabel(e.key)), Text('${e.value}')],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi(this.titulo, this.valor, this.icone, {this.onTap});

  final String titulo;
  final int valor;
  final IconData icone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icone, color: Theme.of(context).colorScheme.primary),
                    if (onTap != null) const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
                Text('$valor', style: Theme.of(context).textTheme.headlineMedium),
                Text(titulo, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      );
}
