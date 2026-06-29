import 'package:flutter/material.dart';

/// Uma linha dentro da caixa de fórmulas.
class FormulaLine {
  final String? label;
  final String formula;
  final bool highlight;

  const FormulaLine(this.formula, {this.label, this.highlight = false});
}

/// Caixa de fórmulas: título + linhas em fonte monospace + texto interpretativo.
class FormulaCard extends StatelessWidget {
  final String title;
  final List<FormulaLine> lines;
  final String? interpretation;
  final Color accentColor;

  const FormulaCard({
    super.key,
    required this.title,
    required this.lines,
    this.interpretation,
    this.accentColor = const Color(0xFF2A78D6),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.functions, color: accentColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...lines.map(_buildLine),
            if (interpretation != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withOpacity(0.20)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline,
                        size: 18, color: accentColor.withOpacity(0.8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        interpretation!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLine(FormulaLine line) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (line.label != null) ...[
            Text(
              line.label!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 2),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: line.highlight
                  ? accentColor.withOpacity(0.10)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              line.formula,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: line.highlight ? 14 : 13,
                fontWeight: line.highlight ? FontWeight.bold : FontWeight.normal,
                color: line.highlight ? accentColor : Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
