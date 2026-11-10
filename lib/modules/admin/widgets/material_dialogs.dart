import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/api_client.dart';
import '../../../core/formatters.dart';
import '../../../data/models/material_model.dart';

const _unidades = ['un', 'm', 'm²', 'kg', 'g', 'l', 'ml', 'rolo', 'par'];

/// Cadastro/edição de material. Devolve true se salvou.
Future<bool?> mostrarDialogMaterial({
  MaterialModel? existente,
  required Future<void> Function(Map<String, dynamic> dados) onSalvar,
}) =>
    Get.dialog<bool>(_MaterialDialog(existente: existente, onSalvar: onSalvar));

class _MaterialDialog extends StatefulWidget {
  const _MaterialDialog({required this.existente, required this.onSalvar});
  final MaterialModel? existente;
  final Future<void> Function(Map<String, dynamic> dados) onSalvar;

  @override
  State<_MaterialDialog> createState() => _MaterialDialogState();
}

class _MaterialDialogState extends State<_MaterialDialog> {
  late final _nome = TextEditingController(text: widget.existente?.nome);
  late final _minimo = TextEditingController(
      text: widget.existente == null ? '' : fmtQtd(widget.existente!.estoqueMinimo));
  late final _custo = TextEditingController(
      text: widget.existente?.custoUnitario == null
          ? ''
          : widget.existente!.custoUnitario!.toStringAsFixed(2).replaceAll('.', ','));
  final _inicial = TextEditingController();
  late String _unidade = widget.existente?.unidade ?? 'un';
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _minimo.dispose();
    _custo.dispose();
    _inicial.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_nome.text.trim().isEmpty) {
      setState(() => _erro = 'Informe o nome do material.');
      return;
    }

    double? numero(TextEditingController c, String nome) {
      if (c.text.trim().isEmpty) return null;
      final v = parseDecimal(c.text);
      if (v == null || v < 0) _erro = 'Valor inválido em "$nome".';
      return v;
    }

    _erro = null;
    final minimo = numero(_minimo, 'Estoque mínimo');
    final custo = numero(_custo, 'Custo unitário');
    final inicial = numero(_inicial, 'Estoque inicial');
    if (_erro != null) {
      setState(() {});
      return;
    }

    final dados = <String, dynamic>{
      'nome': _nome.text.trim(),
      'unidade': _unidade,
      'estoque_minimo': minimo ?? 0,
      'custo_unitario': custo ?? 0,
      if (widget.existente == null && inicial != null && inicial > 0) 'estoque_inicial': inicial,
    };

    setState(() => _salvando = true);
    try {
      await widget.onSalvar(dados);
      Get.back(result: true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.existente != null;
    final unidades = {..._unidades, _unidade}.toList();
    const decimal = TextInputType.numberWithOptions(decimal: true);

    return AlertDialog(
      title: Text(editando ? 'Editar material' : 'Novo material'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nome,
              autofocus: !editando,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nome (ex.: Couro preto)'),
            ),
            DropdownButtonFormField<String>(
              value: _unidade,
              decoration: const InputDecoration(labelText: 'Unidade'),
              items: unidades.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (v) => setState(() => _unidade = v ?? 'un'),
            ),
            TextField(
              controller: _custo,
              keyboardType: decimal,
              decoration: const InputDecoration(labelText: 'Custo por unidade', prefixText: 'R\$ '),
            ),
            TextField(
              controller: _minimo,
              keyboardType: decimal,
              decoration: const InputDecoration(
                labelText: 'Estoque mínimo',
                helperText: 'Abaixo disso o material aparece como "estoque baixo"',
              ),
            ),
            if (!editando)
              TextField(
                controller: _inicial,
                keyboardType: decimal,
                decoration: const InputDecoration(labelText: 'Estoque inicial (opcional)'),
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

/// Entrada (compra) ou saída (uso) de estoque. Devolve true se salvou.
Future<bool?> mostrarDialogMovimento({
  required bool entrada,
  required String nomeMaterial,
  required String unidade,
  double? custoSugerido,
  required Future<void> Function(Map<String, dynamic> dados) onSalvar,
}) =>
    Get.dialog<bool>(_MovimentoDialog(
      entrada: entrada,
      nomeMaterial: nomeMaterial,
      unidade: unidade,
      custoSugerido: custoSugerido,
      onSalvar: onSalvar,
    ));

class _MovimentoDialog extends StatefulWidget {
  const _MovimentoDialog({
    required this.entrada,
    required this.nomeMaterial,
    required this.unidade,
    required this.custoSugerido,
    required this.onSalvar,
  });

  final bool entrada;
  final String nomeMaterial;
  final String unidade;
  final double? custoSugerido;
  final Future<void> Function(Map<String, dynamic> dados) onSalvar;

  @override
  State<_MovimentoDialog> createState() => _MovimentoDialogState();
}

class _MovimentoDialogState extends State<_MovimentoDialog> {
  final _qtd = TextEditingController();
  final _os = TextEditingController();
  final _obs = TextEditingController();
  late final _custo = TextEditingController(
      text: widget.custoSugerido == null || widget.custoSugerido == 0
          ? ''
          : widget.custoSugerido!.toStringAsFixed(2).replaceAll('.', ','));
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _qtd.dispose();
    _os.dispose();
    _obs.dispose();
    _custo.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final qtd = parseDecimal(_qtd.text);
    if (qtd == null || qtd <= 0) {
      setState(() => _erro = 'Informe uma quantidade maior que zero.');
      return;
    }

    final dados = <String, dynamic>{'quantidade': qtd};
    if (_obs.text.trim().isNotEmpty) dados['observacao'] = _obs.text.trim();

    if (widget.entrada) {
      if (_custo.text.trim().isNotEmpty) {
        final c = parseDecimal(_custo.text);
        if (c == null || c < 0) {
          setState(() => _erro = 'Custo inválido.');
          return;
        }
        dados['custo_unitario'] = c;
      }
    } else if (_os.text.trim().isNotEmpty) {
      final os = int.tryParse(_os.text.trim());
      if (os == null) {
        setState(() => _erro = 'Número da OS inválido.');
        return;
      }
      dados['os_id'] = os;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await widget.onSalvar(dados);
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
      title: Text(widget.entrada ? 'Entrada de estoque' : 'Saída de estoque'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.nomeMaterial, style: const TextStyle(fontWeight: FontWeight.w600)),
            TextField(
              controller: _qtd,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Quantidade', suffixText: widget.unidade),
            ),
            if (widget.entrada)
              TextField(
                controller: _custo,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Custo por ${widget.unidade}',
                  prefixText: 'R\$ ',
                  helperText: 'Atualiza o custo do material',
                ),
              )
            else
              TextField(
                controller: _os,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nº da OS (opcional)'),
              ),
            TextField(
              controller: _obs,
              decoration: InputDecoration(
                labelText: widget.entrada ? 'Observação (ex.: fornecedor)' : 'Observação (opcional)',
              ),
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
              : Text(widget.entrada ? 'Registrar entrada' : 'Registrar saída'),
        ),
      ],
    );
  }
}
