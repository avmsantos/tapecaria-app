import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/api_client.dart';
import '../../../core/formatters.dart';
import '../../../data/models/financeiro_model.dart';

const _categorias = ['Aluguel', 'Energia', 'Água', 'Internet', 'Ferramentas', 'Material', 'Salários', 'Impostos', 'Outros'];

Widget _botaoSalvar(bool salvando, VoidCallback onTap, String label) => FilledButton(
      onPressed: salvando ? null : onTap,
      child: salvando
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(label),
    );

// ===================== DESPESA =====================
Future<bool?> mostrarDialogDespesa({
  DespesaModel? existente,
  required Future<void> Function(Map<String, dynamic> dados) onSalvar,
}) =>
    Get.dialog<bool>(_DespesaDialog(existente: existente, onSalvar: onSalvar));

class _DespesaDialog extends StatefulWidget {
  const _DespesaDialog({this.existente, required this.onSalvar});
  final DespesaModel? existente;
  final Future<void> Function(Map<String, dynamic> dados) onSalvar;

  @override
  State<_DespesaDialog> createState() => _DespesaDialogState();
}

class _DespesaDialogState extends State<_DespesaDialog> {
  late final _descricao = TextEditingController(text: widget.existente?.descricao);
  late final _valor = TextEditingController(
      text: widget.existente == null ? '' : widget.existente!.valor.toStringAsFixed(2).replaceAll('.', ','));
  late String _categoria = widget.existente?.categoria ?? 'Outros';
  late DateTime _data = widget.existente?.data?.toLocal() ?? DateTime.now();
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _descricao.dispose();
    _valor.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _data = d);
  }

  Future<void> _salvar() async {
    final valor = parseDecimal(_valor.text);
    if (_descricao.text.trim().isEmpty) {
      setState(() => _erro = 'Descreva a despesa.');
      return;
    }
    if (valor == null || valor <= 0) {
      setState(() => _erro = 'Informe um valor maior que zero.');
      return;
    }
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await widget.onSalvar({
        'categoria': _categoria,
        'descricao': _descricao.text.trim(),
        'valor': valor,
        'data': fmtDataIso(_data),
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
    return AlertDialog(
      title: Text(widget.existente == null ? 'Nova despesa' : 'Editar despesa'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _descricao,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Descrição (ex.: Conta de luz)'),
            ),
            TextField(
              controller: _valor,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ '),
            ),
            DropdownButtonFormField<String>(
              value: _categoria,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: {..._categorias, _categoria}.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _categoria = v ?? 'Outros'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _escolherData,
              icon: const Icon(Icons.event),
              label: Text('Data: ${fmtData(_data)}'),
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
        _botaoSalvar(_salvando, _salvar, 'Salvar'),
      ],
    );
  }
}

// ===================== PAGAMENTO DE OS =====================
Future<bool?> mostrarDialogPagamento({
  required double saldo,
  required Future<void> Function(Map<String, dynamic> dados) onSalvar,
}) =>
    Get.dialog<bool>(_PagamentoDialog(saldo: saldo, onSalvar: onSalvar));

class _PagamentoDialog extends StatefulWidget {
  const _PagamentoDialog({required this.saldo, required this.onSalvar});
  final double saldo;
  final Future<void> Function(Map<String, dynamic> dados) onSalvar;

  @override
  State<_PagamentoDialog> createState() => _PagamentoDialogState();
}

class _PagamentoDialogState extends State<_PagamentoDialog> {
  late final _valor = TextEditingController(
      text: widget.saldo > 0 ? widget.saldo.toStringAsFixed(2).replaceAll('.', ',') : '');
  final _obs = TextEditingController();
  String _forma = 'pix';
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _valor.dispose();
    _obs.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final valor = parseDecimal(_valor.text);
    if (valor == null || valor <= 0) {
      setState(() => _erro = 'Informe um valor maior que zero.');
      return;
    }
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await widget.onSalvar({
        'valor': valor,
        'forma': _forma,
        if (_obs.text.trim().isNotEmpty) 'observacao': _obs.text.trim(),
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
    return AlertDialog(
      title: const Text('Registrar pagamento'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.saldo > 0) Text('Falta receber: ${fmtMoeda(widget.saldo)}'),
            TextField(
              controller: _valor,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Valor recebido', prefixText: 'R\$ '),
            ),
            DropdownButtonFormField<String>(
              value: _forma,
              decoration: const InputDecoration(labelText: 'Forma de pagamento'),
              items: formasPagamento.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _forma = v ?? 'pix'),
            ),
            TextField(
              controller: _obs,
              decoration: const InputDecoration(labelText: 'Observação (ex.: entrada, 2ª parcela)'),
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
        _botaoSalvar(_salvando, _salvar, 'Registrar'),
      ],
    );
  }
}
