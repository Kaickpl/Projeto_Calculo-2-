import 'package:flutter/material.dart';
import '../widgets/formulario_entrada.dart';
import '../widgets/resumo_metricas.dart';
import 'tela_graficos.dart';
import 'tela_tabela.dart';
import 'tela_calculo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Calculadora de Financiamento',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Projeto Cálculo 2',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888780),
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Gráficos'),
              Tab(text: 'Parcelas'),
              Tab(text: 'Cálculos'),
            ],
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 13,
            ),
          ),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  children: const [
                    FormularioEntrada(),
                    ResumoMetricas(),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ];
          },
          body: const TabBarView(
            children: [
              TelaGraficos(),
              TelaTabelaParcelas(),
              TelaCalculo(),
            ],
          ),
        ),
      ),
    );
  }
}