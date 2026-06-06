import 'package:flutter/material.dart';
import 'package:test_tcc/core/theme/app_colors.dart';
import 'package:test_tcc/domain/entities/carona_resumo.dart';
import 'package:test_tcc/presentation/widgets/status_badge.dart';

/// Pílula de status de uma carona, com cor/ícone por status. Centraliza o
/// mapeamento para o chat, a lista e o detalhe usarem o mesmo visual.
class CaronaStatusBadge extends StatelessWidget {
  final StatusCarona status;

  const CaronaStatusBadge({super.key, required this.status});

  Color get _color => switch (status) {
        StatusCarona.pendente => AppColors.warning,
        StatusCarona.aceita => AppColors.success,
        StatusCarona.concluida => AppColors.primary,
        StatusCarona.cancelada => AppColors.error,
      };

  IconData get _icon => switch (status) {
        StatusCarona.pendente => Icons.schedule,
        StatusCarona.aceita => Icons.check_circle_outline,
        StatusCarona.concluida => Icons.flag_outlined,
        StatusCarona.cancelada => Icons.cancel_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return StatusBadge(label: status.label, color: _color, icon: _icon);
  }
}
