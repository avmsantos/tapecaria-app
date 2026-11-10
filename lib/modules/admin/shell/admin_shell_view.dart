import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../painel/admin_home_view.dart';
import 'admin_shell_controller.dart';
import '../agenda/agenda_view.dart';
import '../clientes/clientes_view.dart';
import 'mais_view.dart';
import '../ordens/ordens_view.dart';

class AdminShellView extends GetView<AdminShellController> {
  const AdminShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.index.value,
            children: const [AdminHomeView(), AgendaView(), OrdensView(), ClientesView(), MaisView()],
          )),
      bottomNavigationBar: Obx(() => NavigationBar(
            selectedIndex: controller.index.value,
            onDestinationSelected: controller.ir,
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Painel'),
              NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: 'Agenda'),
              NavigationDestination(
                  icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Ordens'),
              NavigationDestination(
                  icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Clientes'),
              NavigationDestination(
                  icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz), label: 'Mais'),
            ],
          )),
    );
  }
}
