import '../../core/api_client.dart';
import '../models/apontamento_model.dart';
import '../models/ordem_servico_model.dart';

class OsDetalhe {
  OsDetalhe(this.os, this.apontamentoAberto);
  final OrdemServicoModel os;
  final ApontamentoModel? apontamentoAberto;
}

class FuncionarioRepository {
  FuncionarioRepository(this._api);
  final ApiClient _api;

  Future<List<OrdemServicoModel>> listar() => _api.run((dio) async {
        final r = await dio.get('/minhas-os');
        return (r.data as List)
            .map((e) => OrdemServicoModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      });

  Future<OsDetalhe> detalhe(int osId) => _api.run((dio) async {
        final r = await dio.get('/minhas-os/$osId');
        final data = Map<String, dynamic>.from(r.data as Map);
        final aberto = data['apontamento_aberto'];
        return OsDetalhe(
          OrdemServicoModel.fromJson(Map<String, dynamic>.from(data['os'] as Map)),
          (aberto is Map && aberto['id'] != null)
              ? ApontamentoModel.fromJson(Map<String, dynamic>.from(aberto))
              : null,
        );
      });

  /// Serviço em andamento do funcionário (ou null).
  Future<ApontamentoModel?> atual() => _api.run((dio) async {
        final r = await dio.get('/meu-apontamento');
        // sem serviço em andamento o servidor responde {} (objeto vazio), não null
        final d = r.data;
        return (d is Map && d['id'] != null)
            ? ApontamentoModel.fromJson(Map<String, dynamic>.from(d))
            : null;
      });

  Future<void> aceitar(int osId) => _api.run<void>((dio) async {
        await dio.post('/minhas-os/$osId/aceitar');
      });

  Future<void> iniciar(int osId) => _api.run<void>((dio) async {
        await dio.post('/minhas-os/$osId/iniciar');
      });

  Future<void> pausar(int osId, {String? motivo}) => _api.run<void>((dio) async {
        await dio.post('/minhas-os/$osId/pausar', data: {'motivo': motivo});
      });

  Future<void> retomar(int osId) => _api.run<void>((dio) async {
        await dio.post('/minhas-os/$osId/retomar');
      });

  /// Devolve os segundos trabalhados (calculados pelo servidor).
  Future<int> finalizar(int osId, {required bool concluirServico}) => _api.run((dio) async {
        final r = await dio.post('/minhas-os/$osId/finalizar',
            data: {'concluir_servico': concluirServico});
        return ((r.data as Map)['segundos_trabalhados'] as num).toInt();
      });
}
