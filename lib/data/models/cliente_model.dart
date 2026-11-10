import 'ordem_servico_model.dart';
import 'veiculo_model.dart';

class ClienteModel {
  ClienteModel({
    required this.id,
    required this.nome,
    required this.telefone,
    this.observacoes,
    this.veiculos = const [],
    this.ordens = const [],
  });

  final int id;
  final String nome;
  final String telefone;
  final String? observacoes;
  final List<VeiculoModel> veiculos;
  final List<OrdemServicoModel> ordens;

  factory ClienteModel.fromJson(Map<String, dynamic> j) => ClienteModel(
        id: j['id'] as int,
        nome: j['nome'] as String,
        telefone: (j['telefone'] as String?) ?? '',
        observacoes: j['observacoes'] as String?,
        veiculos: ((j['veiculos'] as List?) ?? const [])
            .map((e) => VeiculoModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        ordens: ((j['ordens'] as List?) ?? const [])
            .map((e) => OrdemServicoModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
