import 'dart:math';
import 'package:flutter/foundation.dart';

enum SistemaAmortizacao { price, sac, ambos }

class ParcelaInfo {
  final int numero;
  final double parcela;
  final double juros;
  final double amortizacao;
  final double saldoDevedor;

  const ParcelaInfo({
    required this.numero,
    required this.parcela,
    required this.juros,
    required this.amortizacao,
    required this.saldoDevedor,
  });

  bool get isEquilibrio => amortizacao >= juros;
}

class ResultadoFinanciamento {
  final List<ParcelaInfo> parcelasPrice;
  final List<ParcelaInfo> parcelasSAC;
  final double pv;
  final double taxaMensal;
  final int numParcelas;
  final SistemaAmortizacao sistema;

  const ResultadoFinanciamento({
    required this.parcelasPrice,
    required this.parcelasSAC,
    required this.pv,
    required this.taxaMensal,
    required this.numParcelas,
    required this.sistema,
  });

  List<ParcelaInfo> get parcelas =>
      sistema == SistemaAmortizacao.sac ? parcelasSAC : parcelasPrice;

  double get totalPagoPrice =>
      parcelasPrice.fold(0, (s, p) => s + p.parcela);

  double get totalPagoSAC =>
      parcelasSAC.fold(0, (s, p) => s + p.parcela);

  double get totalPago =>
      sistema == SistemaAmortizacao.sac ? totalPagoSAC : totalPagoPrice;

  double get totalJurosPrice =>
      parcelasPrice.fold(0, (s, p) => s + p.juros);

  double get totalJurosSAC =>
      parcelasSAC.fold(0, (s, p) => s + p.juros);

  double get totalJuros =>
      sistema == SistemaAmortizacao.sac ? totalJurosSAC : totalJurosPrice;

  double get cetAnual => pow(1 + taxaMensal, 12) - 1;

  // Ponto de equilíbrio (parcela onde amortização supera juros)
  int? get pontoEquilibrio {
    final list = parcelas;
    for (int i = 0; i < list.length; i++) {
      if (list[i].isEquilibrio) return list[i].numero;
    }
    return null;
  }

  // Integral numérica (regra dos trapézios) dos juros pagos
  double get integralTrapezios {
    final juros = parcelasPrice.map((p) => p.juros).toList();
    double soma = 0;
    for (int k = 0; k < juros.length - 1; k++) {
      soma += (juros[k] + juros[k + 1]) / 2;
    }
    return soma;
  }

  // Dívida sem nenhum pagamento (exponencial)
  List<double> get curvaExponencial =>
      List.generate(numParcelas + 1, (t) => pv * pow(1 + taxaMensal, t));

  double get dividaSemPagamento => pv * pow(1 + taxaMensal, numParcelas);
}

class FinanciamentoModel extends ChangeNotifier {
  double _valorBem = 50000;
  double _entrada = 10000;
  double _taxaMensal = 1.2; // em %
  int _numParcelas = 48;
  SistemaAmortizacao _sistema = SistemaAmortizacao.price;

  ResultadoFinanciamento? _resultado;

  double get valorBem => _valorBem;
  double get entrada => _entrada;
  double get taxaMensal => _taxaMensal;
  int get numParcelas => _numParcelas;
  SistemaAmortizacao get sistema => _sistema;
  ResultadoFinanciamento? get resultado => _resultado;
  double get pv => max(0, _valorBem - _entrada);

  void setValorBem(double v) { _valorBem = v; _calcular(); }
  void setEntrada(double v) { _entrada = v; _calcular(); }
  void setTaxaMensal(double v) { _taxaMensal = v; _calcular(); }
  void setNumParcelas(int v) { _numParcelas = v; _calcular(); }
  void setSistema(SistemaAmortizacao s) { _sistema = s; _calcular(); }

  FinanciamentoModel() {
    _calcular();
  }

  void _calcular() {
    final pv = this.pv;
    final i = _taxaMensal / 100;
    final n = _numParcelas;

    if (pv <= 0 || i <= 0 || n <= 0) {
      _resultado = null;
      notifyListeners();
      return;
    }

    _resultado = ResultadoFinanciamento(
      parcelasPrice: _calcularPrice(pv, i, n),
      parcelasSAC: _calcularSAC(pv, i, n),
      pv: pv,
      taxaMensal: i,
      numParcelas: n,
      sistema: _sistema,
    );

    notifyListeners();
  }

  // 2.1 — Séries Geométricas: fórmula Price
  // PMT = PV × [i × (1+i)^n] / [(1+i)^n − 1]
  List<ParcelaInfo> _calcularPrice(double pv, double i, int n) {
    final fator = pow(1 + i, n);
    final pmt = pv * (i * fator) / (fator - 1);
    double saldo = pv;
    final result = <ParcelaInfo>[];

    for (int t = 1; t <= n; t++) {
      final juros = saldo * i;
      final amort = pmt - juros;
      saldo -= amort;
      result.add(ParcelaInfo(
        numero: t,
        parcela: pmt,
        juros: juros,
        amortizacao: amort,
        saldoDevedor: max(0, saldo),
      ));
    }
    return result;
  }

  // 2.1 — Sistema SAC (amortização constante)
  List<ParcelaInfo> _calcularSAC(double pv, double i, int n) {
    final amort = pv / n;
    double saldo = pv;
    final result = <ParcelaInfo>[];

    for (int t = 1; t <= n; t++) {
      final juros = saldo * i;
      final pmt = amort + juros;
      saldo -= amort;
      result.add(ParcelaInfo(
        numero: t,
        parcela: pmt,
        juros: juros,
        amortizacao: amort,
        saldoDevedor: max(0, saldo),
      ));
    }
    return result;
  }
}
