import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/juros_model.dart';
import 'screens/home_screen.dart';

/// Cores padrão da aplicação (conforme especificação de design).
const Color kAzul = Color(0xFF2A78D6); // juros simples
const Color kVerde = Color(0xFF1BAF7A); // juros compostos
const Color kAmarelo = Color(0xFFEDA100); // área entre curvas

void main() {
  runApp(const JurosApp());
}

class JurosApp extends StatelessWidget {
  const JurosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<JurosModel>(
      create: (_) => JurosModel(),
      child: MaterialApp(
        title: 'Cálculo 2 — Juros & Cálculo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: kAzul),
          scaffoldBackgroundColor: Colors.grey.shade50,
          appBarTheme: const AppBarTheme(
            backgroundColor: kAzul,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
