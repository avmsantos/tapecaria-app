import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateTime? parseDate(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString());

String fmtDataHora(DateTime? d) =>
    d == null ? '-' : DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(d.toLocal());

String fmtData(DateTime? d) =>
    d == null ? '-' : DateFormat('dd/MM/yyyy', 'pt_BR').format(d.toLocal());

String _dois(int n) => n.toString().padLeft(2, '0');

/// 01:05:09
String fmtDuracao(Duration d) =>
    '${_dois(d.inHours)}:${_dois(d.inMinutes.remainder(60))}:${_dois(d.inSeconds.remainder(60))}';

/// 1h 05min  |  12min 30s  |  45s
String fmtHorasMin(int segundos) {
  final h = segundos ~/ 3600;
  final m = (segundos % 3600) ~/ 60;
  final s = segundos % 60;
  if (h > 0) return '${h}h ${_dois(m)}min';
  if (m > 0) return '${m}min ${_dois(s)}s';
  return '${s}s';
}

const Map<String, String> statusLabels = {
  'aguardando_entrada': 'Aguardando entrada',
  'aguardando_servico': 'Na loja • aguardando serviço',
  'em_andamento': 'Em andamento',
  'pronto': 'Pronto',
  'entregue': 'Entregue',
  'cancelado': 'Cancelado',
};

String statusLabel(String s) => statusLabels[s] ?? s;

Color statusColor(String s) {
  switch (s) {
    case 'em_andamento':
      return Colors.orange.shade700;
    case 'pronto':
      return Colors.green.shade700;
    case 'entregue':
      return Colors.blueGrey;
    case 'cancelado':
      return Colors.red.shade700;
    case 'aguardando_servico':
      return Colors.teal.shade700;
    default:
      return Colors.indigo;
  }
}

String fmtMoeda(num? v) =>
    v == null ? '-' : NumberFormat.currency(locale: 'pt_BR', symbol: r'R$').format(v);

String fmtHora(DateTime? d) =>
    d == null ? '-' : DateFormat('HH:mm', 'pt_BR').format(d.toLocal());

/// "quinta-feira, 12 de novembro" (primeira letra maiúscula)
String fmtDiaSemana(DateTime d) {
  final t = DateFormat("EEEE, dd 'de' MMMM", 'pt_BR').format(d.toLocal());
  return t.isEmpty ? t : t[0].toUpperCase() + t.substring(1);
}

/// Envia a data/hora com o fuso explícito (ex.: 2026-11-12T09:00:00-03:00),
/// para o servidor gravar exatamente o horário escolhido.
String isoComOffset(DateTime d) {
  final l = d.toLocal();
  final off = l.timeZoneOffset;
  String p(int n) => n.toString().padLeft(2, '0');
  final sinal = off.isNegative ? '-' : '+';
  final h = off.inHours.abs();
  final m = off.inMinutes.abs().remainder(60);
  return '${l.year.toString().padLeft(4, '0')}-${p(l.month)}-${p(l.day)}'
      'T${p(l.hour)}:${p(l.minute)}:${p(l.second)}$sinal${p(h)}:${p(m)}';
}

String fmtDataIso(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

/// Aceita "12,5", "12.5" e "1.234,56". Devolve null se não for número.
double? parseDecimal(String texto) {
  var s = texto.trim().replaceAll(RegExp(r'[^0-9,.\-]'), '');
  if (s.isEmpty) return null;
  if (s.contains(',') && s.contains('.')) {
    s = s.replaceAll('.', '').replaceAll(',', '.');
  } else if (s.contains(',')) {
    s = s.replaceAll(',', '.');
  }
  return double.tryParse(s);
}

/// Quantidade com até 3 casas (12,5 / 20 / 0,25)
String fmtQtd(num? v) =>
    v == null ? '-' : NumberFormat('#,##0.###', 'pt_BR').format(v);

/// "Novembro de 2026"
String fmtMes(DateTime d) {
  final t = DateFormat("MMMM 'de' yyyy", 'pt_BR').format(d);
  return t.isEmpty ? t : t[0].toUpperCase() + t.substring(1);
}

DateTime primeiroDiaDoMes(DateTime d) => DateTime(d.year, d.month, 1);
DateTime ultimoDiaDoMes(DateTime d) => DateTime(d.year, d.month + 1, 0);

double numero(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;
