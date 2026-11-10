import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/api_client.dart';
import '../../../core/formatters.dart';
import '../../../data/models/cliente_model.dart';
import '../../../data/models/funcionario_model.dart';
import '../../../data/models/ordem_servico_model.dart';
import '../../../data/models/veiculo_model.dart';

/// Escolhe data e depois hora. Devolve null se o usuário cancelar.
Future<DateTime?> escolherDataHora(BuildContext context, {DateTime? inicial}) async {
  final agora = DateTime.now();
  final data = await showDatePicker(
    context: context,
    initialDate: inicial ?? agora,
    firstDate: DateTime(agora.year - 1),
    lastDate: DateTime(agora.year + 3),
  );
  if (data == null || !context.mounted) return null;

  final hora = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(inicial ?? agora),
  );
  if (hora == null) return null;

  return DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
}

// ===================== NOVO CLIENTE =====================
Future<ClienteModel?> mostrarDialogNovoCliente(
  Future<ClienteModel> Function(String nome, String telefone, String? obs) onSalvar,
) =>
    Get.dialog<ClienteModel>(_NovoClienteDialog(onSalvar: onSalvar));

Future<ClienteModel?> mostrarDialogEditarCliente(
  ClienteModel existente,
  Future<ClienteModel> Function(String nome, String telefone, String? obs) onSalvar,
) =>
    Get.dialog<ClienteModel>(_NovoClienteDialog(existente: existente, onSalvar: onSalvar));

class _NovoClienteDialog extends StatefulWidget {
  const _NovoClienteDialog({this.existente, required this.onSalvar});
  final ClienteModel? existente;
  final Future<ClienteModel> Function(String nome, String telefone, String? obs) onSalvar;

  @override
  State<_NovoClienteDialog> createState() => _NovoClienteDialogState();
}

class _NovoClienteDialogState extends State<_NovoClienteDialog> {
  late final _nome = TextEditingController(text: widget.existente?.nome);
  late final _tel = TextEditingController(text: widget.existente?.telefone);
  late final _obs = TextEditingController(text: widget.existente?.observacoes);
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _tel.dispose();
    _obs.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_nome.text.trim().isEmpty || _tel.text.trim().isEmpty) {
      setState(() => _erro = 'Informe o nome e o telefone.');
      return;
    }
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      final c = await widget.onSalvar(_nome.text.trim(), _tel.text.trim(), _obs.text.trim());
      Get.back(result: c);
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existente == null ? 'Novo cliente' : 'Editar cliente'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nome,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _tel,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Telefone (WhatsApp)'),
            ),
            TextField(
              controller: _obs,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Observações (opcional)'),
            ),
            if (_erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_erro!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _salvando ? null : () => Get.back(), child: const Text('Cancelar')),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          child: _salvando
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salvar'),
        ),
      ],
    );
  }
}

// ===================== NOVO VEÍCULO =====================
Future<VeiculoModel?> mostrarDialogNovoVeiculo(
  Future<VeiculoModel> Function(Map<String, dynamic> dados) onSalvar,
) =>
    Get.dialog<VeiculoModel>(_NovoVeiculoDialog(onSalvar: onSalvar));

Future<VeiculoModel?> mostrarDialogEditarVeiculo(
  VeiculoModel existente,
  Future<VeiculoModel> Function(Map<String, dynamic> dados) onSalvar,
) =>
    Get.dialog<VeiculoModel>(_NovoVeiculoDialog(existente: existente, onSalvar: onSalvar));

class _NovoVeiculoDialog extends StatefulWidget {
  const _NovoVeiculoDialog({this.existente, required this.onSalvar});
  final VeiculoModel? existente;
  final Future<VeiculoModel> Function(Map<String, dynamic> dados) onSalvar;

  @override
  State<_NovoVeiculoDialog> createState() => _NovoVeiculoDialogState();
}

class _NovoVeiculoDialogState extends State<_NovoVeiculoDialog> {
  late final _marca = TextEditingController(text: widget.existente?.marca);
  late final _modelo = TextEditingController(text: widget.existente?.modelo);
  late final _placa = TextEditingController(text: widget.existente?.placa);
  late final _cor = TextEditingController(text: widget.existente?.cor);
  late final _ano = TextEditingController(text: widget.existente?.ano?.toString());
  late String _tipo = widget.existente?.tipo ?? 'moto';
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _marca.dispose();
    _modelo.dispose();
    _placa.dispose();
    _cor.dispose();
    _ano.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_modelo.text.trim().isEmpty) {
      setState(() => _erro = 'Informe o modelo.');
      return;
    }
    final editando = widget.existente != null;
    final dados = <String, dynamic>{'tipo': _tipo, 'modelo': _modelo.text.trim()};
    // ao editar, campo vazio é enviado como null para poder limpar o valor antigo
    void opcional(String chave, String valor) {
      if (valor.isNotEmpty) {
        dados[chave] = valor;
      } else if (editando) {
        dados[chave] = null;
      }
    }

    opcional('marca', _marca.text.trim());
    opcional('placa', _placa.text.trim().toUpperCase());
    opcional('cor', _cor.text.trim());
    final ano = int.tryParse(_ano.text.trim());
    if (ano != null) {
      dados['ano'] = ano;
    } else if (editando) {
      dados['ano'] = null;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      final v = await widget.onSalvar(dados);
      Get.back(result: v);
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existente == null ? 'Novo veículo' : 'Editar veículo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'moto', label: Text('Moto'), icon: Icon(Icons.two_wheeler)),
                ButtonSegment(value: 'carro', label: Text('Carro'), icon: Icon(Icons.directions_car)),
              ],
              selected: {_tipo},
              onSelectionChanged: (s) => setState(() => _tipo = s.first),
            ),
            TextField(
              controller: _marca,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Marca'),
            ),
            TextField(
              controller: _modelo,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Modelo'),
            ),
            TextField(
              controller: _placa,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Placa (opcional)'),
            ),
            TextField(
              controller: _cor,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Cor (opcional)'),
            ),
            TextField(
              controller: _ano,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Ano (opcional)'),
            ),
            if (_erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_erro!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _salvando ? null : () => Get.back(), child: const Text('Cancelar')),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          child: _salvando
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salvar'),
        ),
      ],
    );
  }
}

// ===================== AGENDAR =====================
/// Devolve true se o agendamento foi salvo.
Future<bool?> mostrarDialogAgendar(Future<void> Function(String tipo, DateTime quando) onSalvar) =>
    Get.dialog<bool>(_AgendarDialog(onSalvar: onSalvar));

class _AgendarDialog extends StatefulWidget {
  const _AgendarDialog({required this.onSalvar});
  final Future<void> Function(String tipo, DateTime quando) onSalvar;

  @override
  State<_AgendarDialog> createState() => _AgendarDialogState();
}

class _AgendarDialogState extends State<_AgendarDialog> {
  String _tipo = 'entrada';
  DateTime? _quando;
  bool _salvando = false;
  String? _erro;

  Future<void> _escolher() async {
    final d = await escolherDataHora(context, inicial: _quando);
    if (d != null) setState(() => _quando = d);
  }

  Future<void> _salvar() async {
    if (_quando == null) {
      setState(() => _erro = 'Escolha a data e a hora.');
      return;
    }
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await widget.onSalvar(_tipo, _quando!);
      Get.back(result: true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo agendamento'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: _tipo,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: const [
              DropdownMenuItem(value: 'entrada', child: Text('Entrada do veículo')),
              DropdownMenuItem(value: 'entrega', child: Text('Entrega')),
              DropdownMenuItem(value: 'retorno', child: Text('Retorno')),
            ],
            onChanged: (v) => setState(() => _tipo = v ?? 'entrada'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _escolher,
            icon: const Icon(Icons.event),
            label: Text(_quando == null ? 'Escolher data e hora' : fmtDataHora(_quando)),
          ),
          if (_erro != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_erro!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: _salvando ? null : () => Get.back(), child: const Text('Cancelar')),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          child: _salvando
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Agendar'),
        ),
      ],
    );
  }
}

// ===================== ESCOLHER FUNCIONÁRIOS =====================
/// Devolve a nova lista de ids, ou null se cancelar.
Future<List<int>?> mostrarDialogFuncionarios(List<FuncionarioModel> todos, Set<int> atuais) =>
    Get.dialog<List<int>>(_FuncionariosDialog(todos: todos, atuais: atuais));

class _FuncionariosDialog extends StatefulWidget {
  const _FuncionariosDialog({required this.todos, required this.atuais});
  final List<FuncionarioModel> todos;
  final Set<int> atuais;

  @override
  State<_FuncionariosDialog> createState() => _FuncionariosDialogState();
}

class _FuncionariosDialogState extends State<_FuncionariosDialog> {
  late final Set<int> _sel = {...widget.atuais};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Funcionários da OS'),
      content: widget.todos.isEmpty
          ? const Text('Nenhum funcionário ativo cadastrado.')
          : SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                children: widget.todos
                    .map((f) => FilterChip(
                          label: Text(f.nome),
                          selected: _sel.contains(f.id),
                          onSelected: (v) => setState(() => v ? _sel.add(f.id) : _sel.remove(f.id)),
                        ))
                    .toList(),
              ),
            ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Get.back(result: _sel.toList()), child: const Text('Salvar')),
      ],
    );
  }
}

// ===================== EDITAR OS =====================
Future<bool?> mostrarDialogEditarOs({
  required OrdemServicoModel os,
  required List<VeiculoModel> veiculos,
  required Future<void> Function(Map<String, dynamic> dados) onSalvar,
}) =>
    Get.dialog<bool>(_EditarOsDialog(os: os, veiculos: veiculos, onSalvar: onSalvar));

class _EditarOsDialog extends StatefulWidget {
  const _EditarOsDialog({required this.os, required this.veiculos, required this.onSalvar});
  final OrdemServicoModel os;
  final List<VeiculoModel> veiculos;
  final Future<void> Function(Map<String, dynamic> dados) onSalvar;

  @override
  State<_EditarOsDialog> createState() => _EditarOsDialogState();
}

class _EditarOsDialogState extends State<_EditarOsDialog> {
  late final _titulo = TextEditingController(text: widget.os.titulo);
  late final _instrucoes = TextEditingController(text: widget.os.instrucoes);
  late final _orcado = TextEditingController(text: _fmt(widget.os.valorOrcado));
  late final _final = TextEditingController(text: _fmt(widget.os.valorFinal));
  late int? _veiculoId = widget.veiculos.any((v) => v.id == widget.os.veiculoId) ? widget.os.veiculoId : null;
  bool _salvando = false;
  String? _erro;

  static String _fmt(double? v) => v == null ? '' : v.toStringAsFixed(2).replaceAll('.', ',');

  @override
  void dispose() {
    _titulo.dispose();
    _instrucoes.dispose();
    _orcado.dispose();
    _final.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_titulo.text.trim().isEmpty) {
      setState(() => _erro = 'Informe o título do serviço.');
      return;
    }
    final orcado = _orcado.text.trim().isEmpty ? 0.0 : parseDecimal(_orcado.text);
    final valorFinal = _final.text.trim().isEmpty ? null : parseDecimal(_final.text);
    if (orcado == null || (_final.text.trim().isNotEmpty && valorFinal == null)) {
      setState(() => _erro = 'Valor inválido.');
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await widget.onSalvar({
        'titulo': _titulo.text.trim(),
        'instrucoes': _instrucoes.text.trim().isEmpty ? null : _instrucoes.text.trim(),
        'valor_orcado': orcado,
        'valor_final': valorFinal,
        if (_veiculoId != null) 'veiculo_id': _veiculoId,
      });
      Get.back(result: true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const decimal = TextInputType.numberWithOptions(decimal: true);
    return AlertDialog(
      title: Text('Editar OS #${widget.os.id}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titulo,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _instrucoes,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'O que precisa ser feito'),
            ),
            TextField(
              controller: _orcado,
              keyboardType: decimal,
              decoration: const InputDecoration(labelText: 'Valor do orçamento', prefixText: 'R\$ '),
            ),
            TextField(
              controller: _final,
              keyboardType: decimal,
              decoration: const InputDecoration(
                labelText: 'Valor final (se mudou)',
                prefixText: 'R\$ ',
                helperText: 'Se preencher, passa a valer no lugar do orçamento',
              ),
            ),
            if (widget.veiculos.length > 1)
              DropdownButtonFormField<int>(
                value: _veiculoId,
                decoration: const InputDecoration(labelText: 'Veículo'),
                items: widget.veiculos.map((v) => DropdownMenuItem(value: v.id, child: Text(v.rotulo))).toList(),
                onChanged: (v) => setState(() => _veiculoId = v),
              ),
            if (_erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_erro!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _salvando ? null : () => Get.back(), child: const Text('Cancelar')),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          child: _salvando
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salvar'),
        ),
      ],
    );
  }
}

// ===================== MOTIVO (ESTORNOS) =====================
/// Pede o motivo de um estorno. Devolve o texto, ou null se cancelar.
Future<String?> pedirMotivo({
  required String titulo,
  required String mensagem,
  String confirmarLabel = 'Estornar',
}) =>
    Get.dialog<String>(_MotivoDialog(titulo: titulo, mensagem: mensagem, confirmarLabel: confirmarLabel));

class _MotivoDialog extends StatefulWidget {
  const _MotivoDialog({required this.titulo, required this.mensagem, required this.confirmarLabel});
  final String titulo;
  final String mensagem;
  final String confirmarLabel;

  @override
  State<_MotivoDialog> createState() => _MotivoDialogState();
}

class _MotivoDialogState extends State<_MotivoDialog> {
  final _motivo = TextEditingController();
  String? _erro;

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (_motivo.text.trim().isEmpty) {
      setState(() => _erro = 'Informe o motivo.');
      return;
    }
    Get.back(result: _motivo.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.mensagem),
          const SizedBox(height: 12),
          TextField(
            controller: _motivo,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: 'Motivo', errorText: _erro),
            onSubmitted: (_) => _confirmar(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        FilledButton(onPressed: _confirmar, child: Text(widget.confirmarLabel)),
      ],
    );
  }
}
