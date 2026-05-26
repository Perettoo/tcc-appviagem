import 'package:flutter/material.dart';
import 'package:test_tcc/core/theme/app_colors.dart';
import 'package:test_tcc/core/theme/app_spacing.dart';
import 'package:test_tcc/core/theme/app_typography.dart';

/// Spinner centralizado padrão.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

/// Estado de erro com mensagem e ação de tentar novamente.
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 44, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text(message, textAlign: TextAlign.center, style: AppTypography.body),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

/// Estado vazio com ícone, título, mensagem e ação opcional.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          Text(message, textAlign: TextAlign.center, style: AppTypography.body),
          if (actionLabel != null) ...[
            const SizedBox(height: AppSpacing.lg),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
