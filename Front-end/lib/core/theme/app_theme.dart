import 'package:flutter/material.dart';
import 'package:test_tcc/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        primaryColor: AppColors.verdePrincipal,
        scaffoldBackgroundColor: AppColors.fundoLeve,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.verdePrincipal,
          primary: AppColors.verdePrincipal,
        ),
        useMaterial3: true,
      );
}
