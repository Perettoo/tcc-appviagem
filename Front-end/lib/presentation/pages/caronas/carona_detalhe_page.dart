import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_tcc/core/theme/app_colors.dart';
import 'package:test_tcc/core/theme/app_spacing.dart';
import 'package:test_tcc/core/theme/app_typography.dart';
import 'package:test_tcc/domain/entities/carona_detalhe.dart';
import 'package:test_tcc/presentation/controllers/carona_detalhe_controller.dart';
import 'package:test_tcc/presentation/widgets/app_card.dart';
import 'package:test_tcc/presentation/widgets/carona_status_badge.dart';
import 'package:test_tcc/presentation/widgets/state_views.dart';

/// Detalhe de uma carona: motorista + passageiros + ações (concluir/cancelar).
/// Espera um [CaronaDetalheController] já provido acima na árvore.
class CaronaDetalhePage extends StatefulWidget {
  const CaronaDetalhePage({super.key});

  @override
  State<CaronaDetalhePage> createState() => _CaronaDetalhePageState();
}

class _CaronaDetalhePageState extends State<CaronaDetalhePage> {
  String _data(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year} • $hh:$min';
  }

  Future<void> _concluir(CaronaDetalheController c) async {
    final ok = await _confirmar(
      titulo: 'Concluir carona?',
      mensagem: 'Marcar esta carona como concluída?',
      acao: 'Concluir',
    );
    if (ok != true) return;
    final feito = await c.concluir();
    _feedback(c, feito, 'Carona concluída.');
  }

  Future<void> _cancelar(CaronaDetalheController c) async {
    final ok = await _confirmar(
      titulo: 'Cancelar carona?',
      mensagem: 'Esta ação não pode ser desfeita.',
      acao: 'Cancelar carona',
      destrutivo: true,
    );
    if (ok != true) return;
    final feito = await c.cancelar();
    _feedback(c, feito, 'Carona cancelada.');
  }

  Future<bool?> _confirmar({
    required String titulo,
    required String mensagem,
    required String acao,
    bool destrutivo = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: destrutivo
                ? FilledButton.styleFrom(backgroundColor: AppColors.error)
                : null,
            child: Text(acao),
          ),
        ],
      ),
    );
  }

  void _feedback(CaronaDetalheController c, bool ok, String sucesso) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? sucesso : (c.error ?? 'Não foi possível concluir a ação.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CaronaDetalheController>();
    final detalhe = c.detalhe;

    return Scaffold(
      appBar: AppBar(title: const Text('Carona')),
      body: c.loading
          ? const LoadingView()
          : detalhe == null
              ? ErrorView(
                  message: c.error ?? 'Não foi possível carregar a carona.',
                  onRetry: c.iniciar,
                )
              : Column(
                  children: [
                    Expanded(
                      child: _Conteudo(
                        detalhe: detalhe,
                        dataLabel: _data(detalhe.data),
                      ),
                    ),
                    _AcoesBar(controller: c, onConcluir: _concluir, onCancelar: _cancelar),
                  ],
                ),
    );
  }
}

class _AcoesBar extends StatelessWidget {
  final CaronaDetalheController controller;
  final Future<void> Function(CaronaDetalheController) onConcluir;
  final Future<void> Function(CaronaDetalheController) onCancelar;

  const _AcoesBar({
    required this.controller,
    required this.onConcluir,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final podeConcluir = controller.podeConcluir;
    final podeCancelar = controller.podeCancelar;
    if (!podeConcluir && !podeCancelar) return const SizedBox.shrink();

    final agindo = controller.agindo;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (podeCancelar)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: agindo ? null : () => onCancelar(controller),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            if (podeCancelar && podeConcluir)
              const SizedBox(width: AppSpacing.md),
            if (podeConcluir)
              Expanded(
                child: FilledButton.icon(
                  onPressed: agindo ? null : () => onConcluir(controller),
                  icon: agindo
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Icon(Icons.check, size: 18),
                  label: const Text('Concluir'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  final CaronaDetalhe detalhe;
  final String dataLabel;

  const _Conteudo({required this.detalhe, required this.dataLabel});

  @override
  Widget build(BuildContext context) {
    final passageiros = detalhe.passageiros;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        // Cabeçalho: grupo + status + data.
        Row(
          children: [
            Expanded(
              child: Text(
                detalhe.grupoNome,
                style: AppTypography.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            CaronaStatusBadge(status: detalhe.status),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(dataLabel, style: AppTypography.caption),
        const SizedBox(height: AppSpacing.xl),

        // Motorista.
        Text('Motorista', style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        if (detalhe.motoristaNome != null)
          _PessoaCard(nome: detalhe.motoristaNome!, icone: Icons.drive_eta)
        else
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.hourglass_empty, color: AppColors.warning),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Aguardando um motorista aceitar.',
                    style: AppTypography.body,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.xl),

        // Carro (atrelado no aceite). Só aparece quando há um carro definido.
        if (detalhe.carro != null) ...[
          Text('Carro', style: AppTypography.label),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child:
                      const Icon(Icons.directions_car, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(detalhe.carro!.descricao, style: AppTypography.label),
                      const SizedBox(height: 2),
                      Text('${detalhe.carro!.detalhe} • ${detalhe.carro!.placa}',
                          style: AppTypography.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],

        // Passageiros.
        Text('Passageiros (${passageiros.length})', style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        if (passageiros.isEmpty)
          Text('Nenhum passageiro.', style: AppTypography.caption)
        else
          ...passageiros.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _PessoaCard(nome: p.nome, icone: Icons.person_outline),
            ),
          ),
      ],
    );
  }
}

class _PessoaCard extends StatelessWidget {
  final String nome;
  final IconData icone;

  const _PessoaCard({required this.nome, required this.icone});

  @override
  Widget build(BuildContext context) {
    final inicial =
        nome.trim().isEmpty ? '?' : nome.trim().characters.first.toUpperCase();
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primarySoft,
            child: Text(
              inicial,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              nome,
              style: AppTypography.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(icone, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}
