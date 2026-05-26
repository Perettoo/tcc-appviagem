import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_tcc/core/theme/app_colors.dart';
import 'package:test_tcc/core/theme/app_spacing.dart';
import 'package:test_tcc/core/theme/app_typography.dart';
import 'package:test_tcc/core/utils/formatters.dart';
import 'package:test_tcc/domain/entities/user.dart';
import 'package:test_tcc/presentation/controllers/auth_controller.dart';
import 'package:test_tcc/presentation/widgets/app_card.dart';
import 'package:test_tcc/presentation/widgets/status_badge.dart';

class PerfilTab extends StatelessWidget {
  const PerfilTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primarySoft,
              child: const Icon(Icons.person, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              user?.name ?? 'Usuário',
              style: AppTypography.headline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(user?.email ?? '', style: AppTypography.body),
            const SizedBox(height: AppSpacing.md),
            if (user != null) StatusBadge(label: user.tipo.label),
            const SizedBox(height: AppSpacing.xl),
            if (user != null)
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Tipo de conta',
                      value: user.tipo.label,
                    ),
                    const Divider(height: 1),
                    _InfoRow(
                      icon: Icons.cake_outlined,
                      label: 'Data de nascimento',
                      value: formatData(user.dataNascimento),
                    ),
                    const Divider(height: 1),
                    _InfoRow(
                      icon: Icons.mail_outline,
                      label: 'E-mail',
                      value: user.email,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              onPressed: () => context.read<AuthController>().logout(),
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Sair da conta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 20),
          const SizedBox(width: AppSpacing.md),
          Text(label, style: AppTypography.body),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: AppTypography.label,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
