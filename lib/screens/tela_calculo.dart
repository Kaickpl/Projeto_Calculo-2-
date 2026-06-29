import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/financiamento_model.dart';
import '../utils/formatters.dart';

/// Uma etapa dentro de um bloco de cálculo.
/// Etapas normais são numeradas automaticamente; a etapa [destaque]
/// é o resultado final daquele bloco e aparece destacada com "▶".
class _Etapa {
  final String texto;
  final bool destaque;

  const _Etapa(this.texto) : destaque = false;
  const _Etapa.resultado(this.texto) : destaque = true;
}

class TelaCalculo extends StatelessWidget {
  const TelaCalculo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanciamentoModel>(builder: (_, model, __) {
      final r = model.resultado;
      if (r == null) {
        return const Center(child: Text('Preencha os dados para ver os cálculos.'));
      }
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _infoBox(
            'Passo a passo de cada fórmula de Cálculo 2 aplicada ao financiamento, '
                'usando os valores atuais dos parâmetros inseridos.',
          ),
          _bloco(
            icone: Icons.functions,
            titulo: '2.1 — Séries geométricas (Price)',
            formula: 'PMT = PV × [i × (1+i)ⁿ] / [(1+i)ⁿ − 1]',
            etapas: _etapasPrice(r),
          ),
          _bloco(
            icone: Icons.trending_up,
            titulo: '2.2 — Juros compostos (sem pagamentos)',
            formula: 'M(t) = PV × (1 + i)ᵗ',
            etapas: _etapasJurosCompostos(r),
          ),
          _bloco(
            icone: Icons.area_chart,
            titulo: '2.3 — Integral definida (trapézios)',
            formula: '∫₀ⁿ J(t) dt ≈ Σ [J(t) + J(t+1)] / 2',
            etapas: _etapasIntegral(r),
          ),
          _bloco(
            icone: Icons.show_chart,
            titulo: '2.4 — Derivada do saldo devedor',
            formula: 'dS/dt = −PMT + S(t) × i = −Amortização(t)',
            etapas: _etapasDerivada(r),
          ),
          _bloco(
            icone: Icons.percent,
            titulo: 'CET — Custo Efetivo Total',
            formula: 'CET = (1 + i)¹² − 1',
            etapas: _etapasCET(r),
          ),
          const SizedBox(height: 16),
        ],
      );
    });
  }

  // 2.1 — PMT = PV × [i × (1+i)ⁿ] / [(1+i)ⁿ − 1]
  List<_Etapa> _etapasPrice(ResultadoFinanciamento r) {
    final pv = r.pv;
    final i = r.taxaMensal;
    final n = r.numParcelas;
    final fator = pow(1 + i, n).toDouble();
    final numerador = i * fator;
    final denominador = fator - 1;
    final pmt = r.parcelasPrice.first.parcela;

    return [
      _Etapa('PV = ${Formatters.moeda(pv)}  |  i = ${i.toStringAsFixed(4)} (${Formatters.pct(i * 100)} a.m.)  |  n = $n'),
      _Etapa('(1+i)ⁿ = (1 + ${i.toStringAsFixed(4)})^$n = ${fator.toStringAsFixed(6)}'),
      _Etapa('Numerador: i × (1+i)ⁿ = ${i.toStringAsFixed(4)} × ${fator.toStringAsFixed(6)} = ${numerador.toStringAsFixed(6)}'),
      _Etapa('Denominador: (1+i)ⁿ − 1 = ${fator.toStringAsFixed(6)} − 1 = ${denominador.toStringAsFixed(6)}'),
      _Etapa('PMT = PV × numerador / denominador = ${Formatters.moeda(pv)} × ${numerador.toStringAsFixed(6)} / ${denominador.toStringAsFixed(6)}'),
      _Etapa.resultado('PMT = ${Formatters.moeda(pmt)}'),
    ];
  }

  // 2.2 — M(t) = PV × (1+i)^t
  List<_Etapa> _etapasJurosCompostos(ResultadoFinanciamento r) {
    final pv = r.pv;
    final i = r.taxaMensal;
    final n = r.numParcelas;
    final fator = pow(1 + i, n).toDouble();
    final montante = pv * fator;
    final totalJuros = r.totalJuros;
    final economia = montante - pv - totalJuros;

    return [
      _Etapa('PV = ${Formatters.moeda(pv)}  |  1 + i = ${(1 + i).toStringAsFixed(4)}'),
      _Etapa('(1+i)ⁿ = ${fator.toStringAsFixed(6)} (mesmo fator do bloco 2.1)'),
      _Etapa('M($n) = PV × (1+i)ⁿ = ${Formatters.moeda(pv)} × ${fator.toStringAsFixed(6)}'),
      _Etapa.resultado('M($n) = ${Formatters.moeda(montante)}'),
      _Etapa('Total de juros pagos financiando = ${Formatters.moeda(totalJuros)}'),
      _Etapa('Economia = M($n) − PV − juros pagos = ${Formatters.moeda(montante)} − ${Formatters.moeda(pv)} − ${Formatters.moeda(totalJuros)}'),
      _Etapa.resultado('Economia ao pagar em vez de não pagar nada = ${Formatters.moeda(economia)}'),
    ];
  }

  // 2.3 — integral por trapézios dos juros mensais
  List<_Etapa> _etapasIntegral(ResultadoFinanciamento r) {
    final juros = r.parcelasPrice.map((p) => p.juros).toList();
    final j1 = juros[0];
    final j2 = juros.length > 1 ? juros[1] : juros[0];
    final primeiroTrapezio = (j1 + j2) / 2;
    final integral = r.integralTrapezios;
    final totalJuros = r.totalJuros;
    final erro = (integral - totalJuros).abs();

    return [
      _Etapa('J(1) = ${Formatters.moeda(j1)}  |  J(2) = ${Formatters.moeda(j2)}  |  ...  |  J(${juros.length}) = ${Formatters.moeda(juros.last)}'),
      _Etapa('Regra dos trapézios: somar [J(t) + J(t+1)] / 2 para cada intervalo'),
      _Etapa('1º trapézio: [J(1) + J(2)] / 2 = [${Formatters.moeda(j1)} + ${Formatters.moeda(j2)}] / 2 = ${Formatters.moeda(primeiroTrapezio)}'),
      _Etapa('Soma de todos os trapézios ≈ ${Formatters.moeda(integral)}'),
      _Etapa('Soma direta dos juros (Σ J(t)) = ${Formatters.moeda(totalJuros)}'),
      _Etapa.resultado('Erro numérico = |${Formatters.moeda(integral)} − ${Formatters.moeda(totalJuros)}| = ${Formatters.moeda(erro)}'),
    ];
  }

  // 2.4 — dS/dt = -PMT + S(t)*i = -Amortização(t)
  List<_Etapa> _etapasDerivada(ResultadoFinanciamento r) {
    final n = r.numParcelas;
    final amort1 = r.parcelasPrice.first.amortizacao;
    final amortN = r.parcelasPrice.last.amortizacao;
    final razao = amortN / amort1;
    final eq = r.pontoEquilibrio;

    return [
      _Etapa('S(t) é o saldo devedor no mês t; dS/dt mede a variação do saldo a cada mês'),
      _Etapa('dS/dt = −PMT + S(t) × i = −(PMT − S(t) × i) = −Amortização(t)'),
      _Etapa('Parcela 1: dS/dt = −${Formatters.moeda(amort1)}  →  saldo cai ${Formatters.moeda(amort1)}/mês'),
      _Etapa('Parcela $n: dS/dt = −${Formatters.moeda(amortN)}  →  saldo cai ${Formatters.moeda(amortN)}/mês'),
      _Etapa('Razão entre as taxas: ${Formatters.moeda(amortN)} / ${Formatters.moeda(amort1)} = ${razao.toStringAsFixed(2)}'),
      if (eq != null) _Etapa('Ponto de equilíbrio (amortização supera juros): parcela $eq'),
      _Etapa.resultado('A amortização acelera ${razao.toStringAsFixed(1)}× ao longo do contrato'),
    ];
  }

  // CET = (1+i)^12 - 1
  List<_Etapa> _etapasCET(ResultadoFinanciamento r) {
    final i = r.taxaMensal;
    final fatorAnual = r.cetAnual + 1;
    final cet = r.cetAnual * 100;

    return [
      _Etapa('i mensal = ${i.toStringAsFixed(4)} (${Formatters.pct(i * 100)} a.m.)'),
      _Etapa('1 + i = ${(1 + i).toStringAsFixed(4)}'),
      _Etapa('(1+i)¹² = ${(1 + i).toStringAsFixed(4)}^12 = ${fatorAnual.toStringAsFixed(6)}'),
      _Etapa('CET = (1+i)¹² − 1 = ${fatorAnual.toStringAsFixed(6)} − 1'),
      _Etapa.resultado('CET = ${Formatters.pct(cet)} ao ano'),
    ];
  }

  Widget _infoBox(String texto) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFE6F1FB),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(texto, style: const TextStyle(fontSize: 13, color: Color(0xFF185FA5), height: 1.5)),
  );

  Widget _bloco({
    required IconData icone,
    required String titulo,
    required String formula,
    required List<_Etapa> etapas,
  }) {
    var numeroPasso = 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icone, size: 18, color: const Color(0xFF185FA5)),
            const SizedBox(width: 8),
            Expanded(child: Text(titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 10),
          // fórmula
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              formula,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFF1A1A1A)),
            ),
          ),
          const SizedBox(height: 10),
          // passo a passo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE8E8E4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: etapas.map((e) {
                final rotulo = e.destaque ? '▶' : '${++numeroPasso}.';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 22,
                        child: Text(rotulo, style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: e.destaque ? const Color(0xFF185FA5) : const Color(0xFF888780),
                        )),
                      ),
                      Expanded(
                        child: Text(e.texto, style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: e.destaque ? const Color(0xFF185FA5) : const Color(0xFF444441),
                          fontWeight: e.destaque ? FontWeight.w600 : FontWeight.w400,
                        )),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}
