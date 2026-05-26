import 'package:flutter/material.dart';
import 'package:test_tcc/core/theme/app_colors.dart';

/// Escala tipográfica. Os componentes usam estes estilos (direta ou via
/// TextTheme do tema) em vez de declarar fontSize/weight soltos.
class AppTypography {
  AppTypography._();

  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );
}
