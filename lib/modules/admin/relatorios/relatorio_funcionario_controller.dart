import 'package:get/get.dart';

import '../../../core/api_client.dart';
import '../../../core/formatters.dart';
import '../../../data/models/relatorio_model.dart';
import '../../../data/repositories/admin_repository.dart';

class RelatorioFuncionarioController extends GetxController {
  RelatorioFuncionarioController(this._repo);
  final AdminRepository _repo;

  late final Map<String, dynamic> _args = Map<String, dynamic>.from(Get.arguments as Map);
  late final int funcionarioId = _args['id'] as int;
  late final String nome = _args['nome'] as String;
  late final mes = primeiroDiaDoMes((_args['mes'] as DateTime?) ?? DateTime.now()).obs;

  final detalhe = Rxn<RelFuncionarioDetalheModel>();
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
      detalhe.value = await _repo.relFuncionarioDetalhe(
        funcionarioId,
        de: mes.value,
        ate: ultimoDiaDoMes(mes.value),
      );
    } on ApiException catch (e) {
      erro.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  void mesAnterior() {
    mes.value = DateTime(mes.value.year, mes.value.month - 1, 1);
    carregar();
  }

  void proximoMes() {
    mes.value = DateTime(mes.value.year, mes.value.month + 1, 1);
    carregar();
  }
}
