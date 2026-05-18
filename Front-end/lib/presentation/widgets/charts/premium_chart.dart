import 'package:flutter/material.dart';

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

    const double paddingEixoY = 40.0;
    const double paddingPontosSide = 10.0;
    final double chartHeight = size.height - paddingEixoY;
    final double chartWidth = size.width - (paddingPontosSide * 2);

    final Paint paintLinha = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double maxData = data.reduce((a, b) => a > b ? a : b);
    if (maxData == 0) maxData = 1.0;
    maxData = maxData * 1.15;

    final List<Offset> points = [];
    final double stepX = chartWidth / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      double x = paddingPontosSide + (i * stepX);
      double y = size.height - ((data[i] / maxData) * chartHeight);
      points.add(Offset(x, y));
    }

    final Paint paintGrid = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    canvas.drawLine(
      const Offset(0, paddingEixoY),
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

    final Path pathPreenchimento = Path();
    pathPreenchimento.moveTo(points.first.dx, size.height);
    pathPreenchimento.lineTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      pathPreenchimento.cubicTo(
        p1.dx + (p2.dx - p1.dx) / 2,
        p1.dy,
        p1.dx + (p2.dx - p1.dx) / 2,
        p2.dy,
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

    final Path pathLinha = Path();
    pathLinha.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      pathLinha.cubicTo(
        p1.dx + (p2.dx - p1.dx) / 2,
        p1.dy,
        p1.dx + (p2.dx - p1.dx) / 2,
        p2.dy,
        p2.dx,
        p2.dy,
      );
    }
    canvas.drawPath(pathLinha, paintLinha);

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

    final Offset pontoDestaque = points[selectedIndex];
    final double valorDestaque = data[selectedIndex];

    canvas.drawLine(
      pontoDestaque,
      Offset(pontoDestaque.dx, size.height),
      Paint()
        ..color = lineColor.withValues(alpha: 0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
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
