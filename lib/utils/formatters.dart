import 'package:intl/intl.dart';

/// Formatação de valores no padrão brasileiro (pt_BR).

final NumberFormat _moeda = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: 'R\$',
  decimalDigits: 2,
);

final NumberFormat _dec2 = NumberFormat('#,##0.00', 'pt_BR');
final NumberFormat _dec3 = NumberFormat('#,##0.000', 'pt_BR');
final NumberFormat _dec4 = NumberFormat('#,##0.0000', 'pt_BR');

/// "R$ 1.234,56"
String formatMoeda(double v) => _moeda.format(v);

/// "1.234,56"
String formatNum(double v) => _dec2.format(v);

/// Decimal com [casas] dígitos (vírgula como separador).
String formatDec(double v, [int casas = 2]) {
  if (casas == 4) return _dec4.format(v);
  if (casas == 3) return _dec3.format(v);
  return _dec2.format(v);
}

/// Versão compacta para rótulos de eixo: "1,2k", "3,4M".
String formatCompacto(double v) {
  final abs = v.abs();
  if (abs >= 1000000) return '${_dec1.format(v / 1000000)}M';
  if (abs >= 1000) return '${_dec1.format(v / 1000)}k';
  return v.toStringAsFixed(0);
}

final NumberFormat _dec1 = NumberFormat('#,##0.0', 'pt_BR');

/// Taxa em percentual: 0.105 -> "10,5%"
String formatPercent(double r) => '${_dec1.format(r * 100)}%';
