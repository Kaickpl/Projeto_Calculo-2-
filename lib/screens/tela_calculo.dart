import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/financiamento_model.dart';
import '../utils/formatters.dart';

class TelaCalculo extends StatelessWidget {
  const TelaCalculo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanciamentoModel>(builder: (_, model, __) {
      final r = model.resultado;
      if (r == null) {
        return const Center(child: Text('Preencha os dados para ver os cálculos.'));
      }

      final pv = r.pv;
      final i = r.taxaMensal;
      final n = r.numParcelas;
      final fator = pow(1 + i, n);
      final pmt = r.parcelasPrice.first.parcela;
      final cet = r.cetAnual * 100;
      final integral = r.integralTrapezios;
      final totalJuros = r.totalJuros;
      final eq = r.pontoEquilibrio;
      final amort1 = r.parcelasPrice.first.amortizacao;
      final amortN = r.parcelasPrice.last.amortizacao;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _infoBox(
            'Os cálculos de Cálculo 2 aplicados diretamente no financiamento, '
            'com os valores atuais dos parâmetros inseridos.',
          ),
          _bloco(
            icone: Icons.functions,
            titulo: '2.1 — Séries geométricas (Price)',
            formula: 'PMT = PV × [i × (1+i)ⁿ] / [(1+i)ⁿ − 1]',
            linhas: [
              'PV = ${Formatters.moeda(pv)}',
              'i = ${Formatters.pct(i * 100)} ao mês',
              'n = $n parcelas',
              '(1+i)ⁿ = ${fator.toStringAsFixed(6)}',
              '▶  PMT = ${Formatters.moeda(pmt)}',
            ],
          ),
          _bloco(
            icone: Icons.trending_up,
            titulo: '2.2 — Juros compostos (sem pagamentos)',
            formula: 'M(t) = PV × (1 + i)ᵗ',
            linhas: [
              'Após $n meses sem pagar:',
              'M($n) = ${Formatters.moeda(pv)} × (1 + ${Formatters.pct(i * 100)})^$n',
              '▶  M($n) = ${Formatters.moeda(pv * fator)}',
              'Economia ao pagar: ${Formatters.moeda(pv * fator - pv - totalJuros)}',
            ],
          ),
          _bloco(
            icone: Icons.area_chart,
            titulo: '2.3 — Integral definida (trapézios)',
            formula: '∫₀ⁿ J(t) dt ≈ Σ [J(t) + J(t+1)] / 2',
            linhas: [
              'Integral numérica ≈ ${Formatters.moeda(integral)}',
              'Soma direta        = ${Formatters.moeda(totalJuros)}',
              'Erro numérico      ≈ ${Formatters.moeda((integral - totalJuros).abs())}',
            ],
          ),
          _bloco(
            icone: Icons.show_chart,
            titulo: '2.4 — Derivada do saldo devedor',
            formula: 'dS/dt = −PMT + S(t) × i',
            linhas: [
              'Variação na parcela  1: −${Formatters.moeda(amort1)}/mês',
              'Variação na parcela $n: −${Formatters.moeda(amortN)}/mês',
              'A amortização acelera ${(amortN / amort1).toStringAsFixed(1)}× ao longo do contrato.',
            ],
          ),
          _bloco(
            icone: Icons.percent,
            titulo: 'CET — Custo Efetivo Total',
            formula: 'CET = (1 + i_mensal)¹² − 1',
            linhas: [
              'CET = (1 + ${i.toStringAsFixed(4)})¹² − 1',
              '▶  CET = ${Formatters.pct(cet)} ao ano',
              if (eq != null) 'Ponto de equilíbrio: parcela $eq',
            ],
          ),
          const SizedBox(height: 16),
        ],
      );
    });
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
    required List<String> linhas,
  }) {
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
          // resultados
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
              children: linhas.map((l) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(l, style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: l.startsWith('▶') ? const Color(0xFF185FA5) : const Color(0xFF444441),
                  fontWeight: l.startsWith('▶') ? FontWeight.w600 : FontWeight.w400,
                )),
              )).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}
