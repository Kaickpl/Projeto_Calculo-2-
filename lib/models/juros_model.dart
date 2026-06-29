import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Modelo de estado global compartilhado entre as três abas.
///
/// Fórmulas:
///   Juros Simples:    M_s(t) = P * (1 + r * t)
///   Juros Compostos:  M_c(t) = P * e^(r * t)   (regime contínuo)
class JurosModel extends ChangeNotifier {
  double _capitalP = 1000; // R$
  double _taxaR = 0.10; // 10% ao ano (regime decimal)
  int _periodoT = 5; // anos

  // ───────────────────────────── getters ─────────────────────────────
  double get capitalP => _capitalP;
  double get taxaR => _taxaR;
  int get periodoT => _periodoT;

  // ───────────────────────────── setters ─────────────────────────────
  set capitalP(double value) {
    _capitalP = value;
    notifyListeners();
  }

  set taxaR(double value) {
    _taxaR = value;
    notifyListeners();
  }

  set periodoT(int value) {
    _periodoT = value;
    notifyListeners();
  }

  // ─────────────────────────── montantes M(t) ───────────────────────────

  /// M_s(t) = P * (1 + r * t)
  double montanteSimples(double t) => _capitalP * (1 + _taxaR * t);

  /// M_c(t) = P * e^(r * t)
  double montanteComposto(double t) => _capitalP * math.exp(_taxaR * t);

  // ─────────────────────────── derivadas M'(t) ───────────────────────────

  /// M_s'(t) = P * r  (constante — crescimento linear)
  double derivadaSimples() => _capitalP * _taxaR;

  /// M_c'(t) = P * r * e^(r * t)  (crescente — juros sobre juros)
  double derivadaComposta(double t) =>
      _capitalP * _taxaR * math.exp(_taxaR * t);

  // ─────────────────── integrais definidas de 0 a T ───────────────────

  /// ∫₀ᵀ M_s dt = P*T + P*r*T²/2
  double integralSimples() {
    final t = _periodoT.toDouble();
    return _capitalP * t + _capitalP * _taxaR * t * t / 2;
  }

  /// ∫₀ᵀ M_c dt = P * (e^(r*T) - 1) / r
  double integralComposta() {
    final t = _periodoT.toDouble();
    return _capitalP * (math.exp(_taxaR * t) - 1) / _taxaR;
  }

  // ──────────────── montante médio (valor médio da função) ────────────────

  /// M̄_s = (1/T) * ∫₀ᵀ M_s(t) dt
  double mediaSimples() => integralSimples() / _periodoT;

  /// M̄_c = (1/T) * ∫₀ᵀ M_c(t) dt
  double mediaComposta() => integralComposta() / _periodoT;

  // ─────────────────────── área entre as curvas ───────────────────────

  /// A = P * [(e^(r*T) - 1)/r - T - r*T²/2]
  double areaEntreCurvas() {
    final t = _periodoT.toDouble();
    return _capitalP *
        ((math.exp(_taxaR * t) - 1) / _taxaR - t - _taxaR * t * t / 2);
  }

  // ───────────────────── geração de pontos p/ gráficos ─────────────────────

  /// Gera [n]+1 pontos uniformes de 0 a T aplicando [fn].
  /// Cada ponto é (t, valor). Usado pelos gráficos (200 pontos por padrão).
  List<MapEntry<double, double>> pontos(double Function(double t) fn,
      {int n = 200}) {
    final t = _periodoT.toDouble();
    return List<MapEntry<double, double>>.generate(
      n + 1,
      (i) {
        final x = t * i / n;
        return MapEntry(x, fn(x));
      },
    );
  }
}
