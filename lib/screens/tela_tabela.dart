import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/financiamento_model.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class TelaTabelaParcelas extends StatelessWidget {
  const TelaTabelaParcelas({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanciamentoModel>(builder: (_, model, __) {
      final r = model.resultado;
      if (r == null) {
        return const Center(child: Text('Preencha os dados para ver a tabela.'));
      }

      final rows = r.parcelas;
      final showAmbos = model.sistema == SistemaAmortizacao.ambos;
      final rowsSAC = r.parcelasSAC;

      return Column(children: [
        // cabeçalho fixo
        Container(
          color: const Color(0xFFF5F5F3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            _th('#', 30),
            _th('Parcela', 90),
            _th('Amort.', 80),
            _th('Juros', 80),
            _th('Saldo', 90),
            if (showAmbos) _th('SAC', 80),
          ]),
        ),
        const Divider(height: 1),
        // linhas
        Expanded(
          child: ListView.builder(
            itemCount: rows.length,
            itemBuilder: (_, i) {
              final p = rows[i];
              final eq = p.isEquilibrio;
              return Container(
                color: eq ? const Color(0xFFF0F7E8) : (i.isEven ? Colors.white : const Color(0xFFFAFAF8)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  child: Row(children: [
                    _td('${p.numero}', 30, bold: eq),
                    _td(Formatters.moeda(p.parcela), 90, color: AppTheme.colorPrimary),
                    _td(Formatters.moeda(p.amortizacao), 80),
                    _td(Formatters.moeda(p.juros), 80, color: AppTheme.colorDanger),
                    _td(Formatters.moeda(p.saldoDevedor), 90),
                    if (showAmbos)
                      _td(Formatters.moeda(rowsSAC[i].parcela), 80, color: AppTheme.colorSAC),
                    if (eq) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3DE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('equil.', style: TextStyle(fontSize: 10, color: AppTheme.colorSuccess, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ]),
                ),
              );
            },
          ),
        ),
        // rodapé totais
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF1F1ED),
            border: Border(top: BorderSide(color: Color(0xFFE8E8E4))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            _td('Tot.', 30, bold: true),
            _td(Formatters.moeda(r.totalPago), 90, bold: true, color: AppTheme.colorPrimary),
            _td(Formatters.moeda(r.pv), 80, bold: true),
            _td(Formatters.moeda(r.totalJuros), 80, bold: true, color: AppTheme.colorDanger),
            const Expanded(child: SizedBox()),
            if (showAmbos)
              _td(Formatters.moeda(r.totalPagoSAC), 80, bold: true, color: AppTheme.colorSAC),
          ]),
        ),
      ]);
    });
  }

  Widget _th(String label, double width) => SizedBox(
    width: width,
    child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF888780))),
  );

  Widget _td(String value, double width, {bool bold = false, Color? color}) => SizedBox(
    width: width,
    child: Text(
      value,
      style: TextStyle(
        fontSize: 12,
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: color ?? const Color(0xFF1A1A1A),
      ),
      overflow: TextOverflow.ellipsis,
    ),
  );
}
