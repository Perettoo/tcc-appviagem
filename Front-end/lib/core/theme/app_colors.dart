import 'package:flutter/material.dart';

/// Paleta única do app — direção "Mobilidade Moderna" (indigo + cyan).
/// Nada de cor solta nas telas: tudo sai daqui.
class AppColors {
  AppColors._();

  // Marca
  static const Color primary = Color(0xFF4F46E5); // indigo-600
  static const Color primaryDark = Color(0xFF4338CA); // indigo-700
  static const Color primarySoft = Color(0xFFEEF2FF); // indigo-50
  static const Color accent = Color(0xFF22D3EE); // cyan-400

  // Superfícies
  static const Color background = Color(0xFFF8FAFC); // slate-50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9); // slate-100

  // Texto
  static const Color textPrimary = Color(0xFF0F172A); // slate-900
  static const Color textSecondary = Color(0xFF475569); // slate-600
  static const Color textMuted = Color(0xFF94A3B8); // slate-400
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Bordas / linhas
  static const Color border = Color(0xFFE2E8F0); // slate-200

  // Estados
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);

  /// Gradiente da marca (heros, cabeçalhos).
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF6366F1)],
  );
}
