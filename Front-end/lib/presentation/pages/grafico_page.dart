import 'package:flutter/material.dart';
import 'package:test_tcc/core/theme/app_colors.dart';
import 'package:test_tcc/domain/entities/user.dart';
import 'package:test_tcc/presentation/widgets/charts/premium_chart.dart';

class GraficoPage extends StatefulWidget {
  final User? user;
  const GraficoPage({super.key, this.user});

  @override
  State<GraficoPage> createState() => _GraficoPageState();
}

class _GraficoPageState extends State<GraficoPage> {
  String _selectedPeriod = 'Diário';
  int? _pontoTocadoIndex;

  final Map<String, List<double>> _dadosGraficos = const {
    'Diário': [12.50, 25.00, 12.50, 37.50, 25.00, 0.0],
    'Semanal': [50.0, 75.0, 62.50, 100.0, 80.0, 0.0],
    'Mensal': [200.0, 350.0, 280.0, 410.0, 390.0, 450.0],
  };

  final Map<String, List<String>> _labelsGraficos = const {
    'Diário': ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'],
    'Semanal': ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4', 'Sem 5', 'Sem 6'],
    'Mensal': ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
  };

  void _atualizarPontoTocado(
    double posicaoX,
    double larguraTotal,
    int quantidadePontos,
  ) {
    const double paddingLaterais = 10.0;
    final double larguraUtil = larguraTotal - (paddingLaterais * 2);
    final double espacamento = larguraUtil / (quantidadePontos - 1);
    int index = ((posicaoX - paddingLaterais) / espacamento).round();
    index = index.clamp(0, quantidadePontos - 1);
    if (_pontoTocadoIndex != index) {
      setState(() => _pontoTocadoIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dadosAtuais = _dadosGraficos[_selectedPeriod] ?? [0, 0, 0, 0, 0, 0];
    final labelsAtuais =
        _labelsGraficos[_selectedPeriod] ?? ['', '', '', '', '', ''];
    final int indexAtivo = _pontoTocadoIndex ?? (dadosAtuais.length - 1);

    return Scaffold(
      backgroundColor: AppColors.fundoLeve,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: const BoxDecoration(
                color: AppColors.verdePrincipal,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estatísticas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 28,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _buildPeriodButton('Dia', 'Diário')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildPeriodButton('Semana', 'Semanal')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildPeriodButton('Mês', 'Mensal')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  width: double.infinity,
                  height: 340,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getGraphTitle(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.verdePrincipal,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.verdePrincipal
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Interativo',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.verdePrincipal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return GestureDetector(
                                onTapDown: (details) => _atualizarPontoTocado(
                                  details.localPosition.dx,
                                  constraints.maxWidth,
                                  dadosAtuais.length,
                                ),
                                onPanUpdate: (details) => _atualizarPontoTocado(
                                  details.localPosition.dx,
                                  constraints.maxWidth,
                                  dadosAtuais.length,
                                ),
                                child: CustomPaint(
                                  size: Size(
                                    constraints.maxWidth,
                                    constraints.maxHeight,
                                  ),
                                  painter: PremiumChartPainter(
                                    data: dadosAtuais,
                                    lineColor: AppColors.verdePrincipal,
                                    selectedIndex: indexAtivo,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: labelsAtuais.map((label) {
                              bool estaAtivo =
                                  labelsAtuais.indexOf(label) == indexAtivo;
                              return Text(
                                label,
                                style: TextStyle(
                                  color: estaAtivo
                                      ? AppColors.verdePrincipal
                                      : Colors.grey,
                                  fontSize: 12,
                                  fontWeight: estaAtivo
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldos Pendentes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDebtCard('Gustavo (Motorista)', 'R\$ 12,50'),
                  _buildDebtCard('Carlos', 'R\$ 8,50'),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    bool isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
          _pontoTocadoIndex = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.verdePrincipal : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.verdePrincipal : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildDebtCard(String person, String amount) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      AppColors.verdePrincipal.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.verdePrincipal,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      'Tu deves',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGraphTitle() {
    switch (_selectedPeriod) {
      case 'Diário':
        return 'Gasto Diário';
      case 'Semanal':
        return 'Gasto Semanal';
      case 'Mensal':
        return 'Gasto Mensal';
      default:
        return 'Gasto';
    }
  }
}
