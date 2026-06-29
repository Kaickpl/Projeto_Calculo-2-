import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/financiamento_model.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FinanciamentoModel(),
      child: const CalculadoraApp(),
    ),
  );
}

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Financiamento',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
