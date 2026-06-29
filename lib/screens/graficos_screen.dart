import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart' show kAzul, kVerde, kAmarelo;
import '../models/juros_model.dart';
import '../utils/formatters.dart';
import '../widgets/chart_helpers.dart';
import '../widgets/formula_card.dart';
import '../widgets/metric_card.dart';

/// Aba 1 — Gráficos e Área entre curvas.
class GraficosScreen extends StatelessWidget {
  const GraficosScreen({super.key});

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

        final double msT = model.montanteSimples(t);
        final double mcT = model.montanteComposto(t);
        final double diff = mcT - msT;
        final double area = model.areaEntreCurvas();
        final double maxY = mcT * 1.1;

        // Strings de fórmula com os parâmetros atuais substituídos.
        final p = model.capitalP;
        final r = model.taxaR;
        final rTexto = formatDec(r, 3);
        final pTexto = p.toStringAsFixed(0);
        final tTexto = model.periodoT.toString();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Montante ao longo do tempo',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                'A faixa amarela é a área entre os dois regimes.',
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
                          LineChartBarData(
                            spots: simples,
                            isCurved: false,
                            color: kAzul,
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: composto,
                            isCurved: false,
                            color: kVerde,
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                        betweenBarsData: [
                          BetweenBarsData(
                            fromIndex: 0,
                            toIndex: 1,
                            color: kAmarelo.withOpacity(0.35),
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
                  LegendItem(color: kAzul, label: 'Simples  M_s(t)'),
                  LegendItem(color: kVerde, label: 'Compostos  M_c(t)'),
                  LegendItem(color: kAmarelo, label: 'Área entre curvas'),
                ],
              ),
              const SizedBox(height: 16),

              // ─────────────── 4 cards ───────────────
              MetricGrid(
                cards: [
                  MetricCard(
                    title: 'Montante simples em T',
                    value: formatMoeda(msT),
                    color: kAzul,
                    subtitle: 'M_s($tTexto)',
                  ),
                  MetricCard(
                    title: 'Montante composto em T',
                    value: formatMoeda(mcT),
                    color: kVerde,
                    subtitle: 'M_c($tTexto)',
                  ),
                  MetricCard(
                    title: 'Diferença final',
                    value: formatMoeda(diff),
                    color: kAmarelo,
                    subtitle: 'M_c(T) − M_s(T)',
                  ),
                  MetricCard(
                    title: 'Área entre as curvas',
                    value: formatMoeda(area),
                    color: kAmarelo,
                    subtitle: 'integral analítica',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─────────────── caixa de fórmula ───────────────
              FormulaCard(
                title: 'Área entre as curvas',
                accentColor: kAmarelo,
                lines: [
                  const FormulaLine(
                    'A = ∫₀ᵀ [ P·e^(r·t) − P·(1 + r·t) ] dt',
                    label: 'Definição (integral da diferença)',
                  ),
                  const FormulaLine(
                    'A = P·[ (e^(r·T) − 1)/r − T − r·T²/2 ]',
                    label: 'Resolução analítica',
                  ),
                  FormulaLine(
                    'A = $pTexto·[ (e^($rTexto·$tTexto) − 1)/$rTexto '
                    '− $tTexto − $rTexto·$tTexto²/2 ]',
                    label: 'Substituindo os parâmetros atuais',
                  ),
                  FormulaLine(
                    'A = ${formatMoeda(area)}',
                    label: 'Valor numérico',
                    highlight: true,
                  ),
                ],
                interpretation:
                    'Geometricamente, a área é a região amarela entre as duas '
                    'curvas. Ela mede quanto o regime composto rende a mais que '
                    'o simples, somado e acumulado ao longo de todo o período T '
                    '— não apenas no instante final, mas a cada momento.',
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
