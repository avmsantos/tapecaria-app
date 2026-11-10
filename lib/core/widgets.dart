import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'formatters.dart';

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    final cor = statusColor(status);
    return Chip(
      label: Text(statusLabel(status), style: TextStyle(color: cor, fontSize: 12)),
      side: BorderSide(color: cor),
      backgroundColor: cor.withOpacity(0.08),
      visualDensity: VisualDensity.compact,
    );
  }
}

class SecaoCard extends StatelessWidget {
  const SecaoCard({super.key, required this.titulo, required this.child, this.acao});

  final String titulo;
  final Widget child;
  final Widget? acao;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(titulo, style: Theme.of(context).textTheme.labelLarge)),
                  if (acao != null) acao!,
                ],
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      );
}

class ErroTentar extends StatelessWidget {
  const ErroTentar({super.key, required this.mensagem, required this.onTentar});

  final String mensagem;
  final VoidCallback onTentar;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(mensagem, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onTentar, child: const Text('Tentar novamente')),
            ],
          ),
        ),
      );
}

/// Diálogo de confirmação. Devolve true se o usuário confirmar.
Future<bool> confirmar(String titulo, String mensagem, {String confirmarLabel = 'Confirmar'}) async {
  final r = await Get.dialog<bool>(
    AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Get.back(result: true), child: Text(confirmarLabel)),
      ],
    ),
  );
  return r == true;
}

/// Navegação de mês (‹ Novembro de 2026 ›). Não deixa avançar além do mês atual.
class SeletorMes extends StatelessWidget {
  const SeletorMes({super.key, required this.mes, required this.onAnterior, required this.onProximo});

  final DateTime mes;
  final VoidCallback onAnterior;
  final VoidCallback onProximo;

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();
    final noMesAtual = mes.year == agora.year && mes.month == agora.month;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: onAnterior, icon: const Icon(Icons.chevron_left)),
        SizedBox(
          width: 190,
          child: Text(fmtMes(mes), textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
        ),
        IconButton(onPressed: noMesAtual ? null : onProximo, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }
}
