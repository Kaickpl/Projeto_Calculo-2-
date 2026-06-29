import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/financiamento_model.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import 'metric_card.dart';

class ResumoMetricas extends StatelessWidget {
  const ResumoMetricas({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanciamentoModel>(builder: (_, model, __) {
      final r = model.resultado;
      if (r == null) return const SizedBox.shrink();

      final eq = r.pontoEquilibrio;
      final parcelaLabel = model.sistema == SistemaAmortizacao.sac
          ? '1ª: ${Formatters.moeda(r.parcelasSAC.first.parcela)}'
          : Formatters.moeda(r.parcelasPrice.first.parcela);

      final parcelaSub = model.sistema == SistemaAmortizacao.ambos
          ? 'SAC 1ª: ${Formatters.moeda(r.parcelasSAC.first.parcela)}'
          : model.sistema == SistemaAmortizacao.sac
              ? 'Última: ${Formatters.moeda(r.parcelasSAC.last.parcela)}'
              : 'fixa mensal';

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: [
          Row(children: [
            Expanded(child: MetricCard(
              label: 'Parcela',
              value: parcelaLabel,
              subtitle: parcelaSub,
              valueColor: AppTheme.colorPrimary,
            )),
            const SizedBox(width: 10),
            Expanded(child: MetricCard(
              label: 'Total de juros',
              value: Formatters.moeda(r.totalJuros),
              subtitle: '${Formatters.pct(r.totalJuros / r.pv * 100)} sobre PV',
              valueColor: AppTheme.colorDanger,
            )),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: MetricCard(
              label: 'Total pago',
              value: Formatters.moeda(r.totalPago),
              subtitle: 'Bem: ${Formatters.moeda(model.valorBem)}',
            )),
            const SizedBox(width: 10),
            Expanded(child: MetricCard(
              label: 'CET anual',
              value: Formatters.pct(r.cetAnual * 100),
              subtitle: eq != null ? 'Equilíbrio: parcela $eq' : '—',
              valueColor: AppTheme.colorSuccess,
            )),
          ]),
        ]),
      );
    });
  }
}
