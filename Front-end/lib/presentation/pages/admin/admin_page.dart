import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_tcc/core/theme/app_colors.dart';
import 'package:test_tcc/core/theme/app_spacing.dart';
import 'package:test_tcc/core/theme/app_typography.dart';
import 'package:test_tcc/presentation/controllers/auth_controller.dart';
import 'package:test_tcc/presentation/widgets/app_card.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Admin'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () => context.read<AuthController>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primarySoft,
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Administrador', style: AppTypography.label),
                        const SizedBox(height: 2),
                        Text(user?.email ?? '', style: AppTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Gestão', style: AppTypography.title),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.construction_outlined, color: AppColors.textMuted),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Ferramentas de gestão (ex.: usuários e grupos) serão '
                    'habilitadas quando os endpoints administrativos do '
                    'backend existirem.',
                    style: AppTypography.body,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
