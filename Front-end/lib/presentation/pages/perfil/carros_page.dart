import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_tcc/core/theme/app_colors.dart';
import 'package:test_tcc/core/theme/app_spacing.dart';
import 'package:test_tcc/core/theme/app_typography.dart';
import 'package:test_tcc/domain/entities/carro.dart';
import 'package:test_tcc/presentation/controllers/carro_controller.dart';
import 'package:test_tcc/presentation/pages/perfil/carro_form_page.dart';
import 'package:test_tcc/presentation/widgets/app_card.dart';
import 'package:test_tcc/presentation/widgets/state_views.dart';
import 'package:test_tcc/presentation/widgets/status_badge.dart';

/// Gerência dos carros do usuário: cadastrar, editar, excluir e selecionar o
/// carro ativo (o que é atrelado à carona ao aceitar). Usa o [CarroController]
/// global, então as mudanças refletem na aba de perfil ao voltar.
class CarrosPage extends StatefulWidget {
  const CarrosPage({super.key});

  @override
  State<CarrosPage> createState() => _CarrosPageState();
}

class _CarrosPageState extends State<CarrosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final c = context.read<CarroController>();
      if (!c.carregouUmaVez) c.carregar();
    });
  }

  Future<void> _abrirForm({Carro? carro}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CarroFormPage(carro: carro)),
    );
  }

  Future<void> _ativar(Carro carro) async {
    final c = context.read<CarroController>();
    final ok = await c.ativar(carro.idCarro);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? '${carro.descricao} agora é o carro ativo.'
              : (c.error ?? 'Não foi possível ativar o carro.'),
        ),
      ),
    );
  }

  Future<void> _excluir(Carro carro) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir carro?'),
        content: Text(
          'Remover ${carro.descricao} (${carro.placa})? '
          'Caronas passadas mantêm o histórico.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    final c = context.read<CarroController>();
    final ok = await c.excluir(carro.idCarro);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Carro excluído.' : (c.error ?? 'Não foi possível excluir.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CarroController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Meus carros')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirForm(),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
      body: SafeArea(child: _buildCorpo(controller)),
    );
  }

  Widget _buildCorpo(CarroController controller) {
    if (controller.loading && !controller.carregouUmaVez) {
      return const LoadingView();
    }
    if (controller.error != null && controller.carros.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          ErrorView(message: controller.error!, onRetry: controller.carregar),
        ],
      );
    }
    if (controller.carros.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: const [
          EmptyState(
            icon: Icons.directions_car_outlined,
            title: 'Nenhum carro cadastrado',
            message:
                'Cadastre um carro para poder aceitar caronas como motorista.',
          ),
        ],
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: controller.carregar,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.huge + AppSpacing.xl, // espaço pro FAB
        ),
        itemCount: controller.carros.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, i) {
          final carro = controller.carros[i];
          return _CarroCard(
            carro: carro,
            onAtivar: carro.ativo ? null : () => _ativar(carro),
            onEditar: () => _abrirForm(carro: carro),
            onExcluir: () => _excluir(carro),
          );
        },
      ),
    );
  }
}

class _CarroCard extends StatelessWidget {
  final Carro carro;
  final VoidCallback? onAtivar;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _CarroCard({
    required this.carro,
    required this.onAtivar,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.directions_car, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      carro.descricao,
                      style: AppTypography.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text('${carro.detalhe} • ${carro.placa}',
                        style: AppTypography.caption),
                  ],
                ),
              ),
              if (carro.ativo)
                const StatusBadge(
                  label: 'Ativo',
                  color: AppColors.success,
                  icon: Icons.check_circle_outline,
                ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'ativar') onAtivar?.call();
                  if (v == 'editar') onEditar();
                  if (v == 'excluir') onExcluir();
                },
                itemBuilder: (_) => [
                  if (!carro.ativo)
                    const PopupMenuItem(
                      value: 'ativar',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.check_circle_outline),
                        title: Text('Definir como ativo'),
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'editar',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'excluir',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.delete_outline, color: AppColors.error),
                      title: Text('Excluir'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!carro.ativo) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAtivar,
                icon: const Icon(Icons.radio_button_unchecked, size: 18),
                label: const Text('Tornar este o carro ativo'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
