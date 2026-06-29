import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/juros_model.dart';
import '../utils/formatters.dart';

/// Três sliders globais (Capital P, Taxa r, Período T) exibidos no topo.
/// Qualquer mudança aciona notifyListeners() e redesenha todas as abas.
class SliderControls extends StatelessWidget {
  const SliderControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JurosModel>(
      builder: (context, model, _) {
        return Material(
          color: Colors.white,
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SliderRow(
                  label: 'Capital P',
                  valueLabel: formatMoeda(model.capitalP),
                  value: model.capitalP,
                  min: 100,
                  max: 10000,
                  divisions: 99, // passo R$ 100
                  onChanged: (v) => model.capitalP = v,
                ),
                _SliderRow(
                  label: 'Taxa r',
                  valueLabel: formatPercent(model.taxaR),
                  value: model.taxaR * 100,
                  min: 1,
                  max: 30,
                  divisions: 58, // passo 0,5%
                  onChanged: (v) => model.taxaR = v / 100,
                ),
                _SliderRow(
                  label: 'Período T',
                  valueLabel:
                      '${model.periodoT} ${model.periodoT == 1 ? "ano" : "anos"}',
                  value: model.periodoT.toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19, // passo 1 ano
                  onChanged: (v) => model.periodoT = v.round(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              label: valueLabel,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 96,
          child: Text(
            valueLabel,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}
