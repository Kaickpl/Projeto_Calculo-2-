import 'package:flutter/material.dart';

import '../main.dart' show kAzul;
import '../widgets/slider_controls.dart';
import 'derivadas_screen.dart';
import 'graficos_screen.dart';
import 'integrais_screen.dart';

/// Tela principal: AppBar + sliders globais no topo + conteúdo da aba +
/// BottomNavigationBar com 3 abas. Usa IndexedStack para preservar cada aba.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const List<Widget> _screens = [
    GraficosScreen(),
    DerivadasScreen(),
    IntegraisScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cálculo 2 — Juros & Cálculo'),
      ),
      body: Column(
        children: [
          const SliderControls(),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kAzul,
        unselectedItemColor: Colors.grey.shade500,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.area_chart_outlined),
            activeIcon: Icon(Icons.area_chart),
            label: 'Gráficos e Área',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Derivadas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.functions_outlined),
            activeIcon: Icon(Icons.functions),
            label: 'Integrais',
          ),
        ],
      ),
    );
  }
}
