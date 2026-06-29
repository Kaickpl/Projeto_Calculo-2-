import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/financiamento_model.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class GraficoBarrasEmpilhadas extends StatelessWidget {
  const GraficoBarrasEmpilhadas({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanciamentoModel>(builder: (_, model, __) {
      final r = model.resultado;
      if (r == null) return const SizedBox.shrink();

      final rows = r.parcelas;
      // Mostra no máximo 60 barras para performance
      final step = (rows.length / 60).ceil().clamp(1, 999);
      final filtered = [for (int i = 0; i < rows.length; i += step) rows[i]];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Legenda(sistema: model.sistema),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: filtered.map((p) => p.parcela).reduce((a, b) => a > b ? a : b) * 1.1,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final p = filtered[group.x];
                      return BarTooltipItem(
                        'Parcela ${p.numero}\n'
                        'Juros: ${Formatters.moeda(p.juros)}\n'
                        'Principal: ${Formatters.moeda(p.amortizacao)}',
                        const TextStyle(color: Colors.white, fontSize: 11),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 56,
                      getTitlesWidget: (v, _) => Text(
                        'R\$ ${(v / 1000).toStringAsFixed(0)}k',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF888780)),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx >= filtered.length) return const SizedBox.shrink();
                        final num = filtered[idx].numero;
                        if (num == 1 || num % (filtered.length ~/ 10).clamp(1, 999) == 0) {
                          return Text('$num', style: const TextStyle(fontSize: 10, color: Color(0xFF888780)));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFEEEEEA),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(filtered.length, (i) {
                  final p = filtered[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: p.parcela,
                        width: (300 / filtered.length).clamp(3, 18),
                        rodStackItems: [
                          BarChartRodStackItem(0, p.amortizacao, AppTheme.colorPrincipal),
                          BarChartRodStackItem(p.amortizacao, p.parcela, AppTheme.colorJuros),
                        ],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(2),
                          topRight: Radius.circular(2),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _Legenda extends StatelessWidget {
  final SistemaAmortizacao sistema;
  const _Legenda({required this.sistema});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 16, children: [
      _item(AppTheme.colorPrincipal, 'Principal'),
      _item(AppTheme.colorJuros, 'Juros'),
      if (sistema == SistemaAmortizacao.ambos)
        _item(AppTheme.colorSAC, 'SAC (comparação)'),
    ]);
  }

  Widget _item(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF888780))),
    ],
  );
}
