import 'package:get/get.dart';

import '../../../core/api_client.dart';
import '../../../core/formatters.dart';
import '../../../data/models/relatorio_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../routes/app_routes.dart';

class RelatoriosController extends GetxController {
  RelatoriosController(this._repo);
  final AdminRepository _repo;

  final mes = primeiroDiaDoMes(DateTime.now()).obs;
  final equipe = <RelFuncionarioModel>[].obs;
  final servicos = Rxn<RelServicosModel>();
  final materiais = Rxn<RelMateriaisModel>();
  final leads = Rxn<RelLeadsModel>();
  final loading = true.obs;
  final erro = RxnString();

  /// Aba inicial (0 equipe, 1 serviços, 2 materiais, 3 leads), vinda dos cartões do painel.
  int get abaInicial {
    final args = Get.arguments;
    return (args is Map && args['aba'] is int) ? args['aba'] as int : 0;
  }

  double get totalHoras => equipe.fold(0.0, (s, f) => s + f.horas);

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  Future<void> carregar() async {
    loading.value = true;
    erro.value = null;
    final de = mes.value;
    final ate = ultimoDiaDoMes(de);
    try {
      equipe.assignAll(await _repo.relFuncionarios(de: de, ate: ate));
      servicos.value = await _repo.relServicosPorDia(de: de, ate: ate);
      materiais.value = await _repo.relMateriais(de: de, ate: ate);
      leads.value = await _repo.relLeads(de: de, ate: ate);
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

  void abrirFuncionario(RelFuncionarioModel f) {
    Get.toNamed(Routes.adminRelFuncionario, arguments: {'id': f.id, 'nome': f.nome, 'mes': mes.value});
  }
}
