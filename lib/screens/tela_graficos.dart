import 'package:flutter/material.dart';
import '../widgets/grafico_barras.dart';
import '../widgets/graficos_linha.dart';

class TelaGraficos extends StatelessWidget {
  const TelaGraficos({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _secao(
          titulo: 'Principal vs Juros por parcela',
          child: const GraficoBarrasEmpilhadas(),
        ),
        const SizedBox(height: 20),
        _secao(
          titulo: 'Saldo devedor ao longo do tempo',
          child: const GraficoSaldoDevedor(),
        ),
        const SizedBox(height: 20),
        _secao(
          titulo: 'Composição do custo total',
          child: const GraficoPizza(),
        ),
        const SizedBox(height: 20),
        _secao(
          titulo: 'Juros compostos: com vs sem pagamento',
          subtitulo: 'Linha tracejada: o que a dívida se tornaria sem nenhum pagamento',
          child: const GraficoExponencial(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _secao({required String titulo, required Widget child, String? subtitulo}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          if (subtitulo != null) ...[
            const SizedBox(height: 4),
            Text(subtitulo, style: const TextStyle(fontSize: 11, color: Color(0xFF888780))),
          ],
          const SizedBox(height: 14),
          child,
        ]),
      ),
    );
  }
}
