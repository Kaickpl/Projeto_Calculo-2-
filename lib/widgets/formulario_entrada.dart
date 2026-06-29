import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/financiamento_model.dart';
import '../utils/app_theme.dart';

class FormularioEntrada extends StatefulWidget {
  const FormularioEntrada({super.key});

  @override
  State<FormularioEntrada> createState() => _FormularioEntradaState();
}

class _FormularioEntradaState extends State<FormularioEntrada> {
  late TextEditingController _bemCtrl;
  late TextEditingController _entradaCtrl;
  late TextEditingController _taxaCtrl;
  late TextEditingController _parcelasCtrl;

  @override
  void initState() {
    super.initState();
    final m = context.read<FinanciamentoModel>();
    _bemCtrl = TextEditingController(text: m.valorBem.toStringAsFixed(0));
    _entradaCtrl = TextEditingController(text: m.entrada.toStringAsFixed(0));
    _taxaCtrl = TextEditingController(text: m.taxaMensal.toStringAsFixed(1));
    _parcelasCtrl = TextEditingController(text: m.numParcelas.toString());
  }

  @override
  void dispose() {
    _bemCtrl.dispose();
    _entradaCtrl.dispose();
    _taxaCtrl.dispose();
    _parcelasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.read<FinanciamentoModel>();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dados do Financiamento',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _campo(
                controller: _bemCtrl,
                label: 'Valor do bem (R\$)',
                onChanged: (v) => model.setValorBem(double.tryParse(v) ?? 0),
              )),
              const SizedBox(width: 12),
              Expanded(child: _campo(
                controller: _entradaCtrl,
                label: 'Entrada (R\$)',
                onChanged: (v) => model.setEntrada(double.tryParse(v) ?? 0),
              )),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _campo(
                controller: _taxaCtrl,
                label: 'Juros mensal (%)',
                isDecimal: true,
                onChanged: (v) => model.setTaxaMensal(double.tryParse(v) ?? 0),
              )),
              const SizedBox(width: 12),
              Expanded(child: _campo(
                controller: _parcelasCtrl,
                label: 'Nº de parcelas',
                onChanged: (v) => model.setNumParcelas(int.tryParse(v) ?? 0),
              )),
            ]),
            const SizedBox(height: 14),
            const Text('Sistema de amortização',
              style: TextStyle(fontSize: 12, color: Color(0xFF888780), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Consumer<FinanciamentoModel>(
              builder: (_, m, __) => SegmentedButton<SistemaAmortizacao>(
                segments: const [
                  ButtonSegment(value: SistemaAmortizacao.price, label: Text('Price')),
                  ButtonSegment(value: SistemaAmortizacao.sac, label: Text('SAC')),
                  ButtonSegment(value: SistemaAmortizacao.ambos, label: Text('Comparar')),
                ],
                selected: {m.sistema},
                onSelectionChanged: (s) => m.setSistema(s.first),
                style: ButtonStyle(
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
    bool isDecimal = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      inputFormatters: [
        isDecimal
            ? FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
            : FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: (v) => onChanged(v.replaceAll(',', '.')),
    );
  }
}
