import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/financiamento_model.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

// ──────────────────────────────────────────────
//  Curva de saldo devedor
// ──────────────────────────────────────────────
class GraficoSaldoDevedor extends StatelessWidget {
  const GraficoSaldoDevedor({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanciamentoModel>(builder: (_, model, __) {
      final r = model.resultado;
      if (r == null) return const SizedBox.shrink();

      final step = (r.numParcelas / 60).ceil().clamp(1, 999);
      final priceSpots = <FlSpot>[];
      final sacSpots = <FlSpot>[];

      for (int i = 0; i < r.parcelasPrice.length; i += step) {
        priceSpots.add(FlSpot(i.toDouble(), r.parcelasPrice[i].saldoDevedor));
      }
      for (int i = 0; i < r.parcelasSAC.length; i += step) {
        sacSpots.add(FlSpot(i.toDouble(), r.parcelasSAC[i].saldoDevedor));
      }

      final showSAC = model.sistema == SistemaAmortizacao.sac ||
          model.sistema == SistemaAmortizacao.ambos;
      final showPrice = model.sistema == SistemaAmortizacao.price ||
          model.sistema == SistemaAmortizacao.ambos;

      final datasets = <LineChartBarData>[];
      if (showPrice) {
        datasets.add(_linha(priceSpots, AppTheme.colorPrincipal, 'Price'));
      }
      if (showSAC) {
        datasets.add(_linha(sacSpots, AppTheme.colorSAC, 'SAC', dashed: true));
      }

      return SizedBox(
        height: 200,
        child: LineChart(LineChartData(
          lineBarsData: datasets,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (v, _) => Text(
                  'R\$${(v / 1000).toStringAsFixed(0)}k',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF888780)),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (r.numParcelas / 10).ceil().toDouble(),
                getTitlesWidget: (v, _) {
                  return Text(
                    '${v.toInt()}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF888780),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Color(0xFFEEEEEA), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) =>
                LineTooltipItem(
                  'Parcela ${s.x.toInt()}\n${Formatters.moeda(s.y)}',
                  const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ).toList(),
            ),
          ),
        )),
      );
    });
  }

  LineChartBarData _linha(List<FlSpot> spots, Color color, String label,
      {bool dashed = false}) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dashArray: dashed ? [4, 3] : null,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.08),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Pizza custo total
// ──────────────────────────────────────────────
class GraficoPizza extends StatefulWidget {
  const GraficoPizza({super.key});

  @override
  State<GraficoPizza> createState() => _GraficoPizzaState();
}

class _GraficoPizzaState extends State<GraficoPizza> {
  int _tocando = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanciamentoModel>(builder: (_, model, __) {
      final r = model.resultado;
      if (r == null) return const SizedBox.shrink();

      final principal = r.pv;
      final juros = r.totalJuros;
      final total = principal + juros;

      return Column(children: [
        SizedBox(
          height: 180,
          child: PieChart(PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (ev, res) {
                setState(() {
                  _tocando = (res?.touchedSection?.touchedSectionIndex ?? -1);
                });
              },
            ),
            sections: [
              PieChartSectionData(
                value: principal,
                color: AppTheme.colorPrincipal,
                title: '${(principal / total * 100).toStringAsFixed(0)}%',
                radius: _tocando == 0 ? 72 : 62,
                titleStyle: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              PieChartSectionData(
                value: juros,
                color: AppTheme.colorJuros,
                title: '${(juros / total * 100).toStringAsFixed(0)}%',
                radius: _tocando == 1 ? 72 : 62,
                titleStyle: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
            sectionsSpace: 2,
            centerSpaceRadius: 36,
          )),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _legItem(AppTheme.colorPrincipal, 'Principal', Formatters.moeda(principal)),
          const SizedBox(width: 20),
          _legItem(AppTheme.colorJuros, 'Juros', Formatters.moeda(juros)),
        ]),
      ]);
    });
  }

  Widget _legItem(Color color, String label, String value) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 5),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF888780))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    ],
  );
}

// ──────────────────────────────────────────────
//  Curva exponencial (sem pagamentos)
// ──────────────────────────────────────────────
class GraficoExponencial extends StatelessWidget {
  const GraficoExponencial({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanciamentoModel>(builder: (_, model, __) {
      final r = model.resultado;
      if (r == null) return const SizedBox.shrink();

      final exp = r.curvaExponencial;
      final real = [r.pv, ...r.parcelasPrice.map((p) => p.saldoDevedor)];
      final step = (exp.length / 40).ceil().clamp(1, 999);

      final expSpots = <FlSpot>[];
      final realSpots = <FlSpot>[];
      for (int i = 0; i < exp.length; i += step) {
        expSpots.add(FlSpot(i.toDouble(), exp[i]));
        realSpots.add(FlSpot(i.toDouble(), real[i]));
      }

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 16, children: [
          _leg(AppTheme.colorPrincipal, 'Saldo real (Price)'),
          _leg(AppTheme.colorExponencial, 'Sem pagamentos', dashed: true),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: LineChart(LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: expSpots,
                isCurved: true,
                color: AppTheme.colorExponencial,
                barWidth: 2,
                dashArray: [4, 3],
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: AppTheme.colorExponencial.withOpacity(0.07)),
              ),
              LineChartBarData(
                spots: realSpots,
                isCurved: true,
                color: AppTheme.colorPrincipal,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: AppTheme.colorPrincipal.withOpacity(0.07)),
              ),
            ],
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (v, _) => Text(
                  'R\$${(v / 1000).toStringAsFixed(0)}k',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF888780)),
                ),
              )),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: (r.numParcelas / 10).ceil().toDouble(),
                  getTitlesWidget: (v, _) {
                    return Text(
                      '${v.toInt()}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF888780),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: Color(0xFFEEEEEA), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
          )),
        ),
      ]);
    });
  }

  Widget _leg(Color color, String label, {bool dashed = false}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 16, height: 2,
        decoration: BoxDecoration(
          color: dashed ? Colors.transparent : color,
          border: dashed ? Border(bottom: BorderSide(color: color, width: 2)) : null,
        ),
      ),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF888780))),
    ],
  );
}
