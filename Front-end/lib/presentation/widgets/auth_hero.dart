import 'package:flutter/material.dart';
import 'package:test_tcc/core/theme/app_colors.dart';
import 'package:test_tcc/core/theme/app_spacing.dart';

/// Cabeçalho com gradiente da marca usado nas telas de login/cadastro.
class AuthHero extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showBack;

  const AuthHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showBack)
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
