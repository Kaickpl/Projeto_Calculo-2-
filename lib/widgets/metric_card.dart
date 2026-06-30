import 'package:flutter/material.dart';

/// Card de métrica: ponto colorido + título + valor (fonte monospace) + legenda.
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final String? subtitle;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    this.subtitle,
  });

@override
Widget build(BuildContext context) {
  return Card(
    elevation: 2,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,       // ← não expande além do necessário
        mainAxisAlignment: MainAxisAlignment.start, // ← era .center, causava o 1px
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ← FittedBox removido: ele pedia altura inconsistente ao IntrinsicHeight
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    ),
  );
}}
/// Organiza uma lista de cards em linhas de 2 colunas com alturas iguais.
class MetricGrid extends StatelessWidget {
  final List<Widget> cards;
  const MetricGrid({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < cards.length; i += 2) {
      final left = cards[i];
      final hasRight = i + 1 < cards.length;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: left),
              const SizedBox(width: 12),
              Expanded(
                child: hasRight ? cards[i + 1] : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
      if (i + 2 < cards.length) rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }
}
