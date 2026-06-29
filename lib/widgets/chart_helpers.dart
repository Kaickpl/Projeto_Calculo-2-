import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../utils/formatters.dart';

/// Constrói os títulos dos eixos (X = tempo em anos, Y = valor em R$).
FlTitlesData buildTitles({
  required double maxY,
  required double maxX,
  required String leftAxisName,
}) {
  final double xInterval = maxX <= 5 ? 1 : (maxX / 5).ceilToDouble();
  final double yInterval = maxY <= 0 ? 1 : maxY / 4;

  return FlTitlesData(
    show: true,
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles:
        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(
      axisNameWidget: const Text('Tempo (anos)', style: _axisNameStyle),
      axisNameSize: 20,
      sideTitles: SideTitles(
        showTitles: true,
        interval: xInterval,
        reservedSize: 28,
        getTitlesWidget: (value, meta) {
          if (value < 0 || value > maxX + 0.001) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(value.toStringAsFixed(0), style: _labelStyle),
          );
        },
      ),
    ),
    leftTitles: AxisTitles(
      axisNameWidget: Text(leftAxisName, style: _axisNameStyle),
      axisNameSize: 18,
      sideTitles: SideTitles(
        showTitles: true,
        interval: yInterval,
        reservedSize: 46,
        getTitlesWidget: (value, meta) {
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(formatCompacto(value), style: _labelStyle),
          );
        },
      ),
    ),
  );
}

/// Grade discreta e leve.
FlGridData buildGrid(double maxY) {
  return FlGridData(
    show: true,
    drawVerticalLine: true,
    horizontalInterval: maxY <= 0 ? 1 : maxY / 4,
    getDrawingHorizontalLine: (_) =>
        FlLine(color: Colors.grey.shade200, strokeWidth: 1),
    getDrawingVerticalLine: (_) =>
        FlLine(color: Colors.grey.shade200, strokeWidth: 1),
  );
}

/// Borda inferior/esquerda do gráfico.
FlBorderData buildBorder() {
  return FlBorderData(
    show: true,
    border: Border(
      left: BorderSide(color: Colors.grey.shade400),
      bottom: BorderSide(color: Colors.grey.shade400),
    ),
  );
}

/// Item de legenda: linha colorida + rótulo.
class LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;

  const LegendItem({
    super.key,
    required this.color,
    required this.label,
    this.dashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 3,
          decoration: BoxDecoration(
            color: dashed ? null : color,
            border: dashed ? Border.all(color: color, width: 1.5) : null,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }
}

const TextStyle _labelStyle = TextStyle(fontSize: 10, color: Colors.grey);
const TextStyle _axisNameStyle =
    TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey);
