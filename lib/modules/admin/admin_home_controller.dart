import 'package:get/get.dart';

import '../../core/api_client.dart';
import '../../data/repositories/admin_repository.dart';

class AdminHomeController extends GetxController {
  AdminHomeController(this._repo);
  final AdminRepository _repo;

  final dados = <String, dynamic>{}.obs;
  final loading = true.obs;
  final erro = RxnString();

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  Future<void> carregar() async {
    loading.value = true;
    erro.value = null;
    try {
      dados.assignAll(await _repo.dashboard());
    } on ApiException catch (e) {
      erro.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  int numero(String chave) => (dados[chave] as num?)?.toInt() ?? 0;

  Map<String, dynamic> get osPorStatus =>
      Map<String, dynamic>.from((dados['os_por_status'] as Map?) ?? const {});
}
