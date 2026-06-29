import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart' show kAzul, kVerde;
import '../models/juros_model.dart';
import '../utils/formatters.dart';
import '../widgets/chart_helpers.dart';
import '../widgets/formula_card.dart';
import '../widgets/metric_card.dart';

/// Aba 3 — Integrais (montante acumulado) e valor médio.
class IntegraisScreen extends StatelessWidget {
  const IntegraisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JurosModel>(
      builder: (context, model, _) {
        final double t = model.periodoT.toDouble();

        final simples = model
            .pontos(model.montanteSimples)
            .map((p) => FlSpot(p.key, p.value))
            .toList();
        final composto = model
            .pontos(model.montanteComposto)
            .map((p) => FlSpot(p.key, p.value))
            .toList();

        final double intS = model.integralSimples();
        final double intC = model.integralComposta();
        final double medS = model.mediaSimples();
        final double medC = model.mediaComposta();

        final double maxY = model.montanteComposto(t) * 1.1;

        final p = model.capitalP;
        final r = model.taxaR;
        final rTexto = formatDec(r, 3);
        final pTexto = p.toStringAsFixed(0);
        final tTexto = model.periodoT.toString();

        // ─────── etapas intermediárias do cálculo ───────
        final double termoLinear = p * t; // P·T
        final double termoQuadratico = p * r * t * t / 2; // P·r·T²/2
        final double expoente = r * t; // r·T
        final double expValor = math.exp(expoente); // e^(r·T)

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Montante acumulado (área sob a curva)',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                'A área sob cada curva é a integral de 0 a T.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),

              // ─────────────── gráfico ───────────────
              Card(
                elevation: 2,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                  child: SizedBox(
                    height: 280,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: t,
                        minY: 0,
                        maxY: maxY,
                        titlesData: buildTitles(
                          maxY: maxY,
                          maxX: t,
                          leftAxisName: 'Montante (R\$)',
                        ),
                        gridData: buildGrid(maxY),
                        borderData: buildBorder(),
                        lineBarsData: [
                          // Composto desenhado primeiro (área verde ao fundo).
                          LineChartBarData(
                            spots: composto,
                            isCurved: false,
                            color: kVerde,
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: kVerde.withOpacity(0.18),
                            ),
                          ),
                          // Simples por cima (área azul translúcida).
                          LineChartBarData(
                            spots: simples,
                            isCurved: false,
                            color: kAzul,
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: kAzul.withOpacity(0.22),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(enabled: false),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  LegendItem(color: kAzul, label: 'Área sob M_s(t)'),
                  LegendItem(color: kVerde, label: 'Área sob M_c(t)'),
                ],
              ),
              const SizedBox(height: 16),

              // ─────────────── cards ───────────────
              MetricGrid(
                cards: [
                  MetricCard(
                    title: '∫₀ᵀ M_s(t) dt',
                    value: formatMoeda(intS),
                    color: kAzul,
                    subtitle: 'acumulado simples',
                  ),
                  MetricCard(
                    title: '∫₀ᵀ M_c(t) dt',
                    value: formatMoeda(intC),
                    color: kVerde,
                    subtitle: 'acumulado composto',
                  ),
                  MetricCard(
                    title: 'Montante médio simples',
                    value: formatMoeda(medS),
                    color: kAzul,
                    subtitle: 'M̄_s = (1/T)·∫ M_s',
                  ),
                  MetricCard(
                    title: 'Montante médio composto',
                    value: formatMoeda(medC),
                    color: kVerde,
                    subtitle: 'M̄_c = (1/T)·∫ M_c',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─────────────── caixa de fórmulas ───────────────
              FormulaCard(
                title: 'Integral — juros simples',
                accentColor: kAzul,
                lines: [
                  const FormulaLine(
                    '∫₀ᵀ P·(1 + r·t) dt',
                    label: 'Definição',
                  ),
                  const FormulaLine(
                    '= P·[ t + r·t²/2 ]₀ᵀ = P·T + P·r·T²/2',
                    label: 'Resolvendo a integral',
                  ),
                  FormulaLine(
                    '= $pTexto·$tTexto + $pTexto·$rTexto·$tTexto²/2',
                    label: 'Substituindo P, r e T',
                  ),
                  FormulaLine(
                    '= ${formatMoeda(termoLinear)} + ${formatMoeda(termoQuadratico)}',
                    label: 'Calculando cada termo',
                  ),
                  FormulaLine(
                    '= ${formatMoeda(intS)}',
                    label: 'Resultado',
                    highlight: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FormulaCard(
                title: 'Integral — juros compostos',
                accentColor: kVerde,
                lines: [
                  const FormulaLine(
                    '∫₀ᵀ P·e^(r·t) dt',
                    label: 'Definição',
                  ),
                  const FormulaLine(
                    '= (P/r)·e^(r·t) |₀ᵀ = P·(e^(r·T) − 1)/r',
                    label: 'Resolvendo a integral',
                  ),
                  FormulaLine(
                    '= $pTexto·(e^($rTexto·$tTexto) − 1)/$rTexto',
                    label: 'Substituindo P, r e T',
                  ),
                  FormulaLine(
                    'e^($rTexto·$tTexto) ≈ ${formatDec(expValor, 4)}',
                    label: 'Calculando a exponencial',
                  ),
                  FormulaLine(
                    '= $pTexto·(${formatDec(expValor, 4)} − 1)/$rTexto '
                        '= ${formatMoeda(intC)}',
                    label: 'Resultado',
                    highlight: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FormulaCard(
                title: 'Valor médio de uma função',
                accentColor: kAzul,
                lines: [
                  const FormulaLine(
                    'M̄ = (1/T)·∫₀ᵀ M(t) dt',
                    label: 'Definição',
                  ),
                  FormulaLine(
                    'M̄_s = (1/$tTexto)·${formatMoeda(intS)}',
                    label: 'Substituindo (regime simples)',
                  ),
                  FormulaLine(
                    'M̄_s = ${formatMoeda(medS)}',
                    label: 'Resultado (simples)',
                    highlight: true,
                  ),
                  FormulaLine(
                    'M̄_c = (1/$tTexto)·${formatMoeda(intC)}',
                    label: 'Substituindo (regime composto)',
                  ),
                  FormulaLine(
                    'M̄_c = ${formatMoeda(medC)}',
                    label: 'Resultado (composto)',
                    highlight: true,
                  ),
                ],
                interpretation:
                'A integral representa o montante total acumulado ao longo '
                    'do período; dividida por T, dá o saldo médio mantido. '
                    'É o valor constante que, integrado de 0 a T, produziria a '
                    'mesma área que a função real.',
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
