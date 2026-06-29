import 'package:intl/intl.dart';

class Formatters {
  static final _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final _pct = NumberFormat('0.00', 'pt_BR');
  static final _num = NumberFormat('#,##0.00', 'pt_BR');

  static String moeda(double v) => _currency.format(v);
  static String pct(double v) => '${_pct.format(v)}%';
  static String numero(double v) => _num.format(v);
}
