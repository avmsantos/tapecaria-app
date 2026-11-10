import 'package:get/get.dart';

import '../modules/admin/clientes/cliente_detalhe_binding.dart';
import '../modules/admin/clientes/cliente_detalhe_view.dart';
import '../modules/admin/financeiro/financeiro_binding.dart';
import '../modules/admin/financeiro/financeiro_view.dart';
import '../modules/admin/funcionarios/funcionarios_binding.dart';
import '../modules/admin/funcionarios/funcionarios_view.dart';
import '../modules/admin/materiais/materiais_binding.dart';
import '../modules/admin/materiais/materiais_view.dart';
import '../modules/admin/materiais/material_detalhe_binding.dart';
import '../modules/admin/materiais/material_detalhe_view.dart';
import '../modules/admin/ordens/os_admin_binding.dart';
import '../modules/admin/ordens/os_admin_view.dart';
import '../modules/admin/ordens/os_nova_binding.dart';
import '../modules/admin/ordens/os_nova_view.dart';
import '../modules/admin/relatorios/relatorio_funcionario_binding.dart';
import '../modules/admin/relatorios/relatorio_funcionario_view.dart';
import '../modules/admin/relatorios/relatorios_binding.dart';
import '../modules/admin/relatorios/relatorios_view.dart';
import '../modules/admin/shell/admin_shell_binding.dart';
import '../modules/admin/shell/admin_shell_view.dart';
import '../modules/auth/login_binding.dart';
import '../modules/auth/login_view.dart';
import '../modules/auth/trocar_senha_binding.dart';
import '../modules/auth/trocar_senha_view.dart';
import '../modules/funcionario/minhas_os_binding.dart';
import '../modules/funcionario/minhas_os_view.dart';
import '../modules/funcionario/os_detalhe_binding.dart';
import '../modules/funcionario/os_detalhe_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import 'app_routes.dart';
import 'auth_middleware.dart';

/// Todas as telas do app. Cada uma tem o seu Binding (dependências) e,
/// quando exige login, o AuthMiddleware.
class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.trocarSenha,
      page: () => const TrocarSenhaView(),
      binding: TrocarSenhaBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.funcionario,
      page: () => const MinhasOsView(),
      binding: MinhasOsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.funcionarioOs,
      page: () => const OsDetalheView(),
      binding: OsDetalheBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.admin,
      page: () => const AdminShellView(),
      binding: AdminShellBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.adminOsNova,
      page: () => const OsNovaView(),
      binding: OsNovaBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.adminOsDetalhe,
      page: () => const OsAdminView(),
      binding: OsAdminBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.adminCliente,
      page: () => const ClienteDetalheView(),
      binding: ClienteDetalheBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.adminFuncionarios,
      page: () => const FuncionariosView(),
      binding: FuncionariosBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.adminMateriais,
      page: () => const MateriaisView(),
      binding: MateriaisBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.adminMaterial,
      page: () => const MaterialDetalheView(),
      binding: MaterialDetalheBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.adminFinanceiro,
      page: () => const FinanceiroView(),
      binding: FinanceiroBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.adminRelatorios,
      page: () => const RelatoriosView(),
      binding: RelatoriosBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.adminRelFuncionario,
      page: () => const RelatorioFuncionarioView(),
      binding: RelatorioFuncionarioBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
