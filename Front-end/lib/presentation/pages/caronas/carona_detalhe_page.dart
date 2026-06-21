import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_tcc/core/theme/app_colors.dart';
import 'package:test_tcc/core/theme/app_spacing.dart';
import 'package:test_tcc/core/theme/app_typography.dart';
import 'package:test_tcc/domain/entities/carona_detalhe.dart';
import 'package:test_tcc/domain/entities/carona_resumo.dart';
import 'package:test_tcc/presentation/controllers/carona_detalhe_controller.dart';
import 'package:test_tcc/presentation/widgets/app_card.dart';
import 'package:test_tcc/presentation/widgets/carona_status_badge.dart';
import 'package:test_tcc/presentation/widgets/state_views.dart';
import 'package:test_tcc/presentation/widgets/status_badge.dart';

/// Detalhe de uma carona: motorista + carro + passageiros. O motorista aprova/
/// recusa pedidos e conclui/cancela; o passageiro pede vaga / cancela o pedido.
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

  Future<void> _pedir(CaronaDetalheController c) async {
    final ok = await c.pedir();
    _feedback(c, ok, 'Pedido enviado. Aguarde o motorista aprovar.');
  }

  Future<void> _cancelarPedido(CaronaDetalheController c) async {
    final ok = await c.cancelarPedido();
    _feedback(c, ok, 'Pedido cancelado.');
  }

  Future<void> _decidir(
    CaronaDetalheController c,
    PassageiroCarona p,
    bool aprovar,
  ) async {
    final ok = await c.decidir(idPassageiro: p.idUsuario, aprovar: aprovar);
    if (!mounted || ok) return;
    // Em caso de falha (ex.: carona lotada) mostra o motivo do backend.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(c.error ?? 'Não foi possível decidir o pedido.')),
    );
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
        content:
            Text(ok ? sucesso : (c.error ?? 'Não foi possível concluir a ação.')),
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
                      child: RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: c.iniciar,
                        child: _Conteudo(
                          controller: c,
                          detalhe: detalhe,
                          dataLabel: _data(detalhe.data),
                          onDecidir: (p, aprovar) => _decidir(c, p, aprovar),
                        ),
                      ),
                    ),
                    _AcoesBar(
                      controller: c,
                      onPedir: () => _pedir(c),
                      onCancelarPedido: () => _cancelarPedido(c),
                      onConcluir: () => _concluir(c),
                      onCancelar: () => _cancelar(c),
                    ),
                  ],
                ),
    );
  }
}

class _AcoesBar extends StatelessWidget {
  final CaronaDetalheController controller;
  final VoidCallback onPedir;
  final VoidCallback onCancelarPedido;
  final VoidCallback onConcluir;
  final VoidCallback onCancelar;

  const _AcoesBar({
    required this.controller,
    required this.onPedir,
    required this.onCancelarPedido,
    required this.onConcluir,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final podePedir = controller.podePedir;
    final podeCancelarPedido = controller.podeCancelarPedido;
    final podeConcluir = controller.podeConcluir;
    final podeCancelar = controller.podeCancelar;
    if (!podePedir && !podeCancelarPedido && !podeConcluir && !podeCancelar) {
      return const SizedBox.shrink();
    }

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
            if (podePedir)
              Expanded(
                child: FilledButton.icon(
                  onPressed: agindo ? null : onPedir,
                  icon: const Icon(Icons.front_hand_outlined, size: 18),
                  label: const Text('Pedir carona'),
                ),
              ),
            if (podeCancelarPedido)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: agindo ? null : onCancelarPedido,
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Cancelar meu pedido'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            if (podeCancelar)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: agindo ? null : onCancelar,
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            if (podeCancelar && podeConcluir) const SizedBox(width: AppSpacing.md),
            if (podeConcluir)
              Expanded(
                child: FilledButton.icon(
                  onPressed: agindo ? null : onConcluir,
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
  final CaronaDetalheController controller;
  final CaronaDetalhe detalhe;
  final String dataLabel;
  final void Function(PassageiroCarona, bool aprovar) onDecidir;

  const _Conteudo({
    required this.controller,
    required this.detalhe,
    required this.dataLabel,
    required this.onDecidir,
  });

  @override
  Widget build(BuildContext context) {
    final passageiros = detalhe.passageiros;
    final souMotorista = controller.souMotorista;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        // Cabeçalho: grupo + status + data + destino.
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
        if (detalhe.destino != null && detalhe.destino!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.place_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(detalhe.destino!, style: AppTypography.label),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.xl),

        // Motorista.
        Text('Motorista', style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        _PessoaCard(
          nome: detalhe.motoristaNome ?? 'Motorista',
          icone: Icons.drive_eta,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Carro (atrelado no anúncio).
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

        // Passageiros + vagas.
        Row(
          children: [
            Expanded(
              child: Text('Passageiros', style: AppTypography.label),
            ),
            if (detalhe.lugares != null)
              Text('${detalhe.ocupadas} de ${detalhe.lugares} vagas',
                  style: AppTypography.caption),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (passageiros.isEmpty)
          Text('Nenhum pedido ainda.', style: AppTypography.caption)
        else
          ...passageiros.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _PassageiroCard(
                passageiro: p,
                podeDecidir: souMotorista &&
                    detalhe.status == StatusCarona.aberta &&
                    p.status == StatusPassageiro.pendente,
                decidindo: controller.estaDecidindo(p.idUsuario),
                onAprovar: () => onDecidir(p, true),
                onRecusar: () => onDecidir(p, false),
              ),
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

/// Linha de um passageiro: nome + status do pedido. Para o motorista, mostra
/// os botões Aprovar/Recusar quando o pedido está pendente.
class _PassageiroCard extends StatelessWidget {
  final PassageiroCarona passageiro;
  final bool podeDecidir;
  final bool decidindo;
  final VoidCallback onAprovar;
  final VoidCallback onRecusar;

  const _PassageiroCard({
    required this.passageiro,
    required this.podeDecidir,
    required this.decidindo,
    required this.onAprovar,
    required this.onRecusar,
  });

  ({Color cor, IconData icone}) get _visual => switch (passageiro.status) {
        StatusPassageiro.pendente => (
            cor: AppColors.warning,
            icone: Icons.schedule
          ),
        StatusPassageiro.aprovado => (
            cor: AppColors.success,
            icone: Icons.check_circle_outline
          ),
        StatusPassageiro.recusado => (
            cor: AppColors.error,
            icone: Icons.cancel_outlined
          ),
      };

  @override
  Widget build(BuildContext context) {
    final inicial = passageiro.nome.trim().isEmpty
        ? '?'
        : passageiro.nome.trim().characters.first.toUpperCase();
    final v = _visual;

    return AppCard(
      child: Column(
        children: [
          Row(
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
                  passageiro.nome,
                  style: AppTypography.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(
                label: passageiro.status.label,
                color: v.cor,
                icon: v.icone,
              ),
            ],
          ),
          if (podeDecidir) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: decidindo ? null : onRecusar,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Recusar'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: decidindo ? null : onAprovar,
                    child: decidindo
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : const Text('Aprovar'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
