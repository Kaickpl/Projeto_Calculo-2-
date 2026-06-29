import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart' show kAzul, kVerde;
import '../models/juros_model.dart';
import '../utils/formatters.dart';
import '../widgets/chart_helpers.dart';
import '../widgets/formula_card.dart';
import '../widgets/metric_card.dart';

/// Aba 2 — Derivadas das funções de montante.
class DerivadasScreen extends StatelessWidget {
  const DerivadasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JurosModel>(
      builder: (context, model, _) {
        final double t = model.periodoT.toDouble();

        final double dSimples = model.derivadaSimples(); // P*r constante
        final double dCompostaT = model.derivadaComposta(t);
        final double razao =
            dSimples == 0 ? 0 : dCompostaT / dSimples; // = e^(rT)

        final retaSimples = <FlSpot>[
          FlSpot(0, dSimples),
          FlSpot(t, dSimples),
        ];
        final curvaComposta = model
            .pontos(model.derivadaComposta)
            .map((p) => FlSpot(p.key, p.value))
            .toList();

        final double maxY = dCompostaT * 1.1;

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
              Text('Taxa de variação do montante',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                'A derivada mostra a velocidade de crescimento em R\$/ano.',
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
                          leftAxisName: "M'(t)  (R\$/ano)",
                        ),
                        gridData: buildGrid(maxY),
                        borderData: buildBorder(),
                        lineBarsData: [
                          // M_s'(t) = Pr — reta horizontal azul tracejada
                          LineChartBarData(
                            spots: retaSimples,
                            isCurved: false,
                            color: kAzul,
                            barWidth: 2.5,
                            dashArray: const [8, 5],
                            dotData: const FlDotData(show: false),
                          ),
                          // M_c'(t) = Pr·e^(rt) — curva verde sólida
                          LineChartBarData(
                            spots: curvaComposta,
                            isCurved: false,
                            color: kVerde,
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
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
                  LegendItem(
                      color: kAzul, label: "M_s'(t) = P·r", dashed: true),
                  LegendItem(color: kVerde, label: "M_c'(t) = P·r·e^(rt)"),
                ],
              ),
              const SizedBox(height: 16),

              // ─────────────── cards ───────────────
              MetricGrid(
                cards: [
                  MetricCard(
                    title: "M_s'(t) — constante",
                    value: '${formatMoeda(dSimples)}/ano',
                    color: kAzul,
                    subtitle: 'P·r (mesma a cada instante)',
                  ),
                  MetricCard(
                    title: "M_c'(T) — no instante T",
                    value: '${formatMoeda(dCompostaT)}/ano',
                    color: kVerde,
                    subtitle: 'P·r·e^(r·$tTexto)',
                  ),
                  MetricCard(
                    title: 'Quantas vezes maior',
                    value: '${formatDec(razao, 2)}×',
                    color: kVerde,
                    subtitle: "M_c'(T) ÷ M_s'(t) = e^(r·T)",
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─────────────── caixa de fórmulas ───────────────
              FormulaCard(
                title: 'Derivada — juros simples',
                accentColor: kAzul,
                lines: [
                  const FormulaLine(
                    "M_s(t) = P·(1 + r·t)   ⇒   M_s'(t) = P·r",
                    label: 'Regra: derivada de função afim',
                  ),
                  FormulaLine(
                    "M_s'(t) = $pTexto·$rTexto = ${formatMoeda(dSimples)}/ano",
                    label: 'Com os parâmetros atuais',
                    highlight: true,
                  ),
                ],
                interpretation:
                    'Crescimento linear: a mesma taxa sempre. A derivada é '
                    'constante, então o montante aumenta a um ritmo fixo, '
                    'independente do tempo já decorrido.',
              ),
              const SizedBox(height: 12),
              FormulaCard(
                title: 'Derivada — juros compostos',
                accentColor: kVerde,
                lines: [
                  const FormulaLine(
                    "M_c(t) = P·e^(r·t)   ⇒   M_c'(t) = P·r·e^(r·t)",
                    label: 'Regra da cadeia em e^(r·t)',
                  ),
                  const FormulaLine(
                    'd/dt e^(r·t) = r·e^(r·t)   (derivada interna = r)',
                    label: 'Detalhe da regra da cadeia',
                  ),
                  FormulaLine(
                    "M_c'($tTexto) = $pTexto·$rTexto·e^($rTexto·$tTexto) "
                    '= ${formatMoeda(dCompostaT)}/ano',
                    label: 'Com os parâmetros atuais',
                    highlight: true,
                  ),
                ],
                interpretation:
                    'Juros sobre juros: a derivada cresce junto com o montante. '
                    'Como M_c\'(t) é proporcional ao próprio M_c(t), quanto '
                    'maior o saldo, mais rápido ele cresce — crescimento '
                    'exponencial.',
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
