import 'package:flutter/material.dart';
import 'package:test_tcc/user.dart';

class TelaGrafico extends StatefulWidget {
  final User? user;
  const TelaGrafico({super.key, this.user});

  @override
  State<TelaGrafico> createState() => _TelaGraficoState();
}

class _TelaGraficoState extends State<TelaGrafico> {
  static const Color verdePrincipal = Color(0xFF2E7D73);
  static const Color fundoLeve = Color(0xFFF5F7F9);

  // Período padrão: Diário
  String _selectedPeriod = 'Diário';

  int? _pontoTocadoIndex;

  // Dados simulados para o gráfico
  final Map<String, List<double>> _dadosGraficos = {
    'Diário': [12.50, 25.00, 12.50, 37.50, 25.00, 0.0],
    'Semanal': [50.0, 75.0, 62.50, 100.0, 80.0, 0.0],
    'Mensal': [200.0, 350.0, 280.0, 410.0, 390.0, 450.0],
  };

  // Eixo X dinâmico: Dias, Semanas e Meses
  final Map<String, List<String>> _labelsGraficos = {
    'Diário': ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'],
    'Semanal': ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4', 'Sem 5', 'Sem 6'],
    'Mensal': ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
  };

  // Lógica para detectar qual ponto está a ser tocado
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
      setState(() {
        _pontoTocadoIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dadosAtuais = _dadosGraficos[_selectedPeriod] ?? [0, 0, 0, 0, 0, 0];
    final labelsAtuais =
        _labelsGraficos[_selectedPeriod] ?? ['', '', '', '', '', ''];

    // Define o ponto ativo (último por padrão ou o que o utilizador tocar)
    final int indexAtivo = _pontoTocadoIndex ?? (dadosAtuais.length - 1);

    return Scaffold(
      backgroundColor: fundoLeve,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- CABEÇALHO ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: const BoxDecoration(
                color: verdePrincipal,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Estatísticas",
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

            // --- SELETOR DE PERÍODO (Dia, Semana, Mês) ---
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

            // --- CARD DO GRÁFICO ---
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
                                color: verdePrincipal,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: verdePrincipal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Interativo",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: verdePrincipal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // ÁREA DO GRÁFICO COM GESTOS
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
                                    lineColor: verdePrincipal,
                                    selectedIndex: indexAtivo,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 15),

                        // RÓTULOS DO EIXO X
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
                                      ? verdePrincipal
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

            // --- SALDOS PENDENTES ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Saldos Pendentes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDebtCard("Gustavo (Motorista)", "R\$ 12,50"),
                  _buildDebtCard("Carlos", "R\$ 8,50"),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para criar os botões de período
  Widget _buildPeriodButton(String label, String period) {
    bool isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
          _pontoTocadoIndex = null; // Reseta o destaque ao trocar de aba
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? verdePrincipal : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? verdePrincipal : Colors.grey[300]!,
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

  // Helper para os cartões de dívida
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
                  backgroundColor: verdePrincipal.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, color: verdePrincipal),
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
                      "Tu deves",
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

// =========================================================================
// MOTOR DE DESENHO DO GRÁFICO (CUSTOM PAINTER)
// =========================================================================
class PremiumChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final int selectedIndex;

  PremiumChartPainter({
    required this.data,
    required this.lineColor,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double paddingEixoY = 40.0;
    final double paddingPontosSide = 10.0;
    final double chartHeight = size.height - paddingEixoY;
    final double chartWidth = size.width - (paddingPontosSide * 2);

    final Paint paintLinha = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double maxData = data.reduce((a, b) => a > b ? a : b);
    if (maxData == 0) maxData = 1.0;
    maxData = maxData * 1.15; // Margem de segurança no topo

    final List<Offset> points = [];
    final double stepX = chartWidth / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      double x = paddingPontosSide + (i * stepX);
      double y = size.height - ((data[i] / maxData) * chartHeight);
      points.add(Offset(x, y));
    }

    // Grid Horizontal
    final Paint paintGrid = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, paddingEixoY),
      Offset(size.width, paddingEixoY),
      paintGrid,
    );
    canvas.drawLine(
      Offset(0, paddingEixoY + (chartHeight / 2)),
      Offset(size.width, paddingEixoY + (chartHeight / 2)),
      paintGrid,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paintGrid,
    );

    // Degradê Curvo
    final Path pathPreenchimento = Path();
    pathPreenchimento.moveTo(points.first.dx, size.height);
    pathPreenchimento.lineTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final ctrl1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final ctrl2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      pathPreenchimento.cubicTo(
        ctrl1.dx,
        ctrl1.dy,
        ctrl2.dx,
        ctrl2.dy,
        p2.dx,
        p2.dy,
      );
    }
    pathPreenchimento.lineTo(points.last.dx, size.height);
    pathPreenchimento.close();

    Paint paintFill = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.3),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTRB(0, paddingEixoY, size.width, size.height));
    canvas.drawPath(pathPreenchimento, paintFill);

    // Linha Principal Curva
    final Path pathLinha = Path();
    pathLinha.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final ctrl1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final ctrl2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      pathLinha.cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, p2.dx, p2.dy);
    }
    canvas.drawPath(pathLinha, paintLinha);

    // Pontos Pequenos (Inativos)
    for (int i = 0; i < points.length; i++) {
      if (i != selectedIndex) {
        canvas.drawCircle(
          points[i],
          4,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          points[i],
          4,
          Paint()
            ..color = lineColor
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );
      }
    }

    // PONTO ATIVO E TOOLTIP
    final Offset pontoDestaque = points[selectedIndex];
    final double valorDestaque = data[selectedIndex];

    // Linha vertical guia
    canvas.drawLine(
      pontoDestaque,
      Offset(pontoDestaque.dx, size.height),
      Paint()
        ..color = lineColor.withValues(alpha: 0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    // Bolinha Destaque
    canvas.drawCircle(
      pontoDestaque,
      10,
      Paint()
        ..color = Colors.black12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      pontoDestaque,
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      pontoDestaque,
      5,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill,
    );

    // Formatação de Moeda
    String valStr = valorDestaque.toStringAsFixed(2);
    List<String> partes = valStr.split('.');
    String inteiros = partes[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    String textoFinal = 'R\$ $inteiros,${partes[1]}';

    final textPainter = TextPainter(
      text: TextSpan(
        text: textoFinal,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Caixinha do Tooltip
    final double rectW = textPainter.width + 16;
    final double rectH = textPainter.height + 10;
    double rectT = pontoDestaque.dy - rectH - 15;
    double rectL = pontoDestaque.dx - (rectW / 2);

    if (rectL < 0) rectL = 0;
    if (rectL + rectW > size.width) rectL = size.width - rectW;

    final RRect tooltipRect = RRect.fromLTRBR(
      rectL,
      rectT,
      rectL + rectW,
      rectT + rectH,
      const Radius.circular(8),
    );
    canvas.drawRRect(
      tooltipRect.shift(const Offset(0, 2)),
      Paint()
        ..color = Colors.black12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawRRect(
      tooltipRect,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill,
    );
    textPainter.paint(canvas, Offset(rectL + 8, rectT + 5));
  }

  @override
  bool shouldRepaint(PremiumChartPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.selectedIndex != selectedIndex;
}
