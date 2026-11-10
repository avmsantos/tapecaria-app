import 'package:get/get.dart';

import '../../core/api_client.dart';
import '../auth/auth_controller.dart';

class SplashController extends GetxController {
  SplashController(this._auth);
  final AuthController _auth;

  final erro = RxnString();

  @override
  void onReady() {
    super.onReady();
    iniciar();
  }

  Future<void> iniciar() async {
    erro.value = null;
    try {
      final rota = await _auth.descobrirRotaInicial();
      Get.offAllNamed(rota);
    } on ApiException catch (e) {
      erro.value = e.message;
    }
  }
}
