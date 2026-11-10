import 'package:get/get.dart';

import '../../../core/api_client.dart';
import '../../../data/models/agenda_item_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../routes/app_routes.dart';

class AgendaController extends GetxController {
  AgendaController(this._repo);
  final AdminRepository _repo;

  final itens = <AgendaItemModel>[].obs;
  final loading = true.obs;
  final erro = RxnString();
  final dias = 30.obs; // quantos dias à frente mostrar

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  Future<void> carregar() async {
    loading.value = true;
    erro.value = null;
    try {
      final hoje = DateTime.now();
      final de = DateTime(hoje.year, hoje.month, hoje.day);
      itens.assignAll(await _repo.agenda(de: de, ate: de.add(Duration(days: dias.value))));
    } on ApiException catch (e) {
      erro.value = e.message;
    } finally {
      loading.value = false;
    }
  }

  void mudarDias(int d) {
    dias.value = d;
    carregar();
  }

  /// Agendamentos agrupados por dia (já ordenados).
  Map<DateTime, List<AgendaItemModel>> get porDia {
    final mapa = <DateTime, List<AgendaItemModel>>{};
    for (final i in itens) {
      final d = i.dataHora?.toLocal();
      if (d == null) continue;
      mapa.putIfAbsent(DateTime(d.year, d.month, d.day), () => []).add(i);
    }
    final chaves = mapa.keys.toList()..sort();
    return {for (final k in chaves) k: mapa[k]!};
  }

  Future<void> abrir(AgendaItemModel item) async {
    await Get.toNamed(Routes.adminOsDetalhe, arguments: item.osId);
    carregar();
  }
}
