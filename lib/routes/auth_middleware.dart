import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../modules/auth/auth_controller.dart';
import 'app_routes.dart';

/// Impede abrir uma tela interna sem usuário carregado (ex.: recarregar o navegador
/// numa URL como /#/funcionario). Nesse caso volta para a splash, que valida o token.
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final logado = Get.isRegistered<AuthController>() && Get.find<AuthController>().user.value != null;
    return logado ? null : const RouteSettings(name: Routes.splash);
  }
}
