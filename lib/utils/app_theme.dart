import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const colorPrimary = Color(0xFF185FA5);
  static const colorDanger  = Color(0xFFA32D2D);
  static const colorSuccess = Color(0xFF3B6D11);
  static const colorAmber   = Color(0xFF854F0B);
  static const colorPrincipal = Color(0xFF378ADD);
  static const colorJuros     = Color(0xFFE24B4A);
  static const colorSAC       = Color(0xFF639922);
  static const colorExponencial = Color(0xFFD4537E);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: colorPrimary,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1A1A1A),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F3),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDDD8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDDD8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: colorPrimary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF888780)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE8E8E4)),
      ),
    ),
  );
}
