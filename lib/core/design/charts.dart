import 'package:flutter/material.dart';

// 波段/模式图表调色板（与原项目保持一致）
const List<Color> chartPalette = [
  Color(0xFF094CB2), // primary blue
  Color(0xFF6D5E00), // gold
  Color(0xFF4CAF50), // green
  Color(0xFFE53935), // red
  Color(0xFF9C27B0), // purple
  Color(0xFFFF9800), // orange
  Color(0xFF00BCD4), // cyan
  Color(0xFF795548), // brown
  Color(0xFF607D8B), // blue-grey
  Color(0xFF8BC34A), // light green
  Color(0xFFFF5722), // deep orange
  Color(0xFF3F51B5), // indigo
];

Color colorForIndex(int i) => chartPalette[i % chartPalette.length];

// ==================== Donut 环形图 ====================
class DonutChart extends StatelessWidget {
  final List<({String label, int count})> items;
  final String centerTitle;
  final String centerValue;
  final Color centerColor;
  final Color centerVariant;
  final Color trackColor;

  const DonutChart({
    super.key,
    required this.items,
    this.centerTitle = '',
    this.centerValue = '',
    this.centerColor = Colors.white,
    this.centerVariant = Colors.grey,
    this.trackColor = const Color(0x4D808080),
  });

  @override
  Widget build(BuildContext context) {
    final total = items.fold<int>(0, (s, i) => s + i.count);
    if (total <= 0) return const _EmptyHint();
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: _DonutPainter(
            items: items,
            total: total,
            trackColor: trackColor,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (centerTitle.isNotEmpty)
              Text(centerTitle,
                  style: TextStyle(fontSize: 10, color: centerVariant)),
            Text(centerValue,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: centerColor)),
          ],
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<({String label, int count})> items;
  final int total;
  final Color trackColor;

  _DonutPainter(
      {required this.items, required this.total, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.shortestSide;
    final strokeW = w * 0.18;
    final diameter = w - strokeW;
    final topLeft = Offset((size.width - diameter) / 2, (size.height - diameter) / 2);
    final arcSize = Size(diameter, diameter);
    final arcRect = Rect.fromLTWH(topLeft.dx, topLeft.dy, arcSize.width, arcSize.height);

    // 背景环
    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW;
    canvas.drawArc(arcRect, -1.5708, 6.2832, false, bgPaint);

    // 各扇形
    double startAngle = -1.5708; // -90°
    for (var i = 0; i < items.length; i++) {
      final sweep = (items[i].count / total) * 2 * 3.14159265;
      if (sweep > 0) {
        final paint = Paint()
          ..color = colorForIndex(i)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.butt;
        canvas.drawArc(arcRect, startAngle, sweep - 0.01, false, paint);
      }
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.items != items || old.total != total;
}

// ==================== Horizontal 横向条形图 ====================
class HorizontalBarList extends StatelessWidget {
  final List<({String label, int count})> items;
  final int total;
  final Color textColor;
  final Color textVariant;
  final Color trackColor;

  const HorizontalBarList({
    super.key,
    required this.items,
    required this.total,
    this.textColor = Colors.white,
    this.textVariant = Colors.grey,
    this.trackColor = const Color(0x33FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty || total <= 0) return const _EmptyHint();
    return Column(
      children: items.asMap().entries.map((e) {
        final i = e.key;
        final item = e.value;
        final pct = item.count / total;
        final color = colorForIndex(i);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(item.label,
                        style: TextStyle(fontSize: 12, color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Text('${item.count}',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          color: textColor)),
                  const SizedBox(width: 8),
                  SizedBox(
                      width: 40,
                      child: Text('${(pct * 100).toInt()}%',
                          style: TextStyle(
                              fontSize: 11, color: textVariant))),
                ],
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: trackColor,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ==================== 24小时热度条 ====================
class HourHeatStrip extends StatelessWidget {
  final List<({int hour, int count})> hours;
  final Color baseColor;
  final Color textColor;
  final Color textVariant;
  final Color emptyColor;

  const HourHeatStrip({
    super.key,
    required this.hours,
    required this.baseColor,
    this.textColor = Colors.white,
    this.textVariant = Colors.grey,
    this.emptyColor = const Color(0x40FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    if (hours.isEmpty) return const _EmptyHint();
    final maxV = hours.fold<int>(0, (m, h) => h.count > m ? h.count : m);
    final safeMax = maxV < 1 ? 1 : maxV;

    return Column(
      children: [
        Row(
          children: hours.map((h) {
            final ratio = h.count / safeMax;
            final bgColor = h.count == 0
                ? emptyColor
                : baseColor.withValues(alpha: (0.18 + 0.82 * ratio).clamp(0.0, 1.0));
            return Expanded(
              child: Container(
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(2)),
                alignment: Alignment.center,
                child: h.count > 0
                    ? Text(
                        h.count > 99 ? '99+' : '${h.count}',
                        style: TextStyle(
                            fontSize: 8,
                            color: ratio > 0.55 ? Colors.black : textColor),
                        maxLines: 1,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [0, 4, 8, 12, 16, 20]
              .map((h) => Text('$h',
                  style: TextStyle(fontSize: 9, color: textVariant)))
              .toList(),
        ),
      ],
    );
  }
}

// ==================== Trend Bar Chart 趋势柱状图 ====================
class TrendBarChart extends StatelessWidget {
  final List<({String key, String label, int value})> points;
  final Color barColor;
  final Color axisColor;

  const TrendBarChart({
    super.key,
    required this.points,
    required this.barColor,
    this.axisColor = const Color(0x40FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const _EmptyHint();
    final maxV = points.fold<int>(0, (m, p) => p.value > m ? p.value : m);
    final safeMax = maxV < 1 ? 1 : maxV;

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: CustomPaint(
            size: Size.infinite,
            painter: _TrendBarPainter(
                points: points, maxV: safeMax, barColor: barColor, axisColor: axisColor),
          ),
        ),
        _rowLabels(points),
      ],
    );
  }
}

class _TrendBarPainter extends CustomPainter {
  final List<({String key, String label, int value})> points;
  final int maxV;
  final Color barColor;
  final Color axisColor;

  _TrendBarPainter(
      {required this.points,
      required this.maxV,
      required this.barColor,
      required this.axisColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const leftPad = 28.0;
    const bottomPad = 28.0;
    const topPad = 8.0;
    const rightPad = 8.0;
    final plotW = (w - leftPad - rightPad).clamp(1, w);
    final plotH = (h - topPad - bottomPad).clamp(1, h);

    // Y轴基线
    canvas.drawLine(
        Offset(leftPad, h - bottomPad),
        Offset(w - rightPad, h - bottomPad),
        Paint()..color = axisColor..strokeWidth = 1.5);

    // 水平网格线
    for (var i = 0; i <= 4; i++) {
      final y = topPad + plotH * i / 4;
      canvas.drawLine(Offset(leftPad, y), Offset(w - rightPad, y),
          Paint()..color = axisColor.withValues(alpha: 0.4)..strokeWidth = 0.8);
    }

    final n = points.length;
    final slot = plotW / n;
    var barW = slot * 0.6;
    if (n > 60)
      barW = 4;
    else if (n > 30) barW = 8;
    barW = barW.clamp(0, 18);

    for (var i = 0; i < n; i++) {
      final barH = (points[i].value / maxV) * plotH;
      final cx = leftPad + slot * i + slot / 2;
      final left = cx - barW / 2;
      final top = (h - bottomPad) - barH;
      canvas.drawRRect(
          RRect.fromRectAndCorners(
              Rect.fromLTWH(left, top, barW, barH.clamp(1, 999)),
              topLeft: const Radius.circular(2),
              topRight: const Radius.circular(2)),
          Paint()..color = barColor);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendBarPainter old) => old.points != points;
}

// ==================== Trend Line Chart 趋势折线图 ====================
class TrendLineChart extends StatelessWidget {
  final List<({String key, String label, int value})> points;
  final Color lineColor;
  final Color fillColor;
  final Color axisColor;

  const TrendLineChart({
    super.key,
    required this.points,
    required this.lineColor,
    this.fillColor = const Color(0x2E094CB2),
    this.axisColor = const Color(0x40FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const _EmptyHint();
    final maxV = points.fold<int>(0, (m, p) => p.value > m ? p.value : m);
    final safeMax = maxV < 1 ? 1 : maxV;

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: CustomPaint(
            size: Size.infinite,
            painter: _TrendLinePainter(
                points: points,
                maxV: safeMax,
                lineColor: lineColor,
                fillColor: fillColor,
                axisColor: axisColor),
          ),
        ),
        _rowLabels(points),
      ],
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  final List<({String key, String label, int value})> points;
  final int maxV;
  final Color lineColor;
  final Color fillColor;
  final Color axisColor;

  _TrendLinePainter(
      {required this.points,
      required this.maxV,
      required this.lineColor,
      required this.fillColor,
      required this.axisColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const leftPad = 28.0;
    const bottomPad = 28.0;
    const topPad = 8.0;
    const rightPad = 8.0;
    final plotW = (w - leftPad - rightPad).clamp(1, w);
    final plotH = (h - topPad - bottomPad).clamp(1, h);

    // 基线 + 网格
    canvas.drawLine(
        Offset(leftPad, h - bottomPad),
        Offset(w - rightPad, h - bottomPad),
        Paint()..color = axisColor..strokeWidth = 1.5);
    for (var i = 0; i <= 3; i++) {
      final y = topPad + plotH * i / 3;
      canvas.drawLine(Offset(leftPad, y), Offset(w - rightPad, y),
          Paint()..color = axisColor.withValues(alpha: 0.4)..strokeWidth = 0.8);
    }

    final n = points.length;
    final step = n > 1 ? plotW / (n - 1) : 0.0;

    // 构建路径
    final linePath = Path();
    final fillPath = Path();
    for (var i = 0; i < n; i++) {
      final x = leftPad + step * i;
      final y = (h - bottomPad) - (points[i].value / maxV) * plotH;
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, h - bottomPad);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(leftPad + step * (n - 1), h - bottomPad);
    fillPath.close();

    canvas.drawPath(fillPath, Paint()..color = fillColor);
    canvas.drawPath(linePath, Paint()..color = lineColor..strokeWidth = 2.5..style = PaintingStyle.stroke);

    // 数据点
    for (var i = 0; i < points.length; i++) {
      final x = leftPad + step * i;
      final y = (h - bottomPad) - (points[i].value / maxV) * plotH;
      canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendLinePainter old) => old.points != points;
}

// ==================== Row Labels (X轴标签) ====================
Widget _rowLabels(List<({String key, String label, int value})> points) {
  final total = points.length;
  if (total == 0) return const SizedBox.shrink();
  var stride = 1;
  if (total > 60) stride = 10;
  else if (total > 30) stride = 5;
  else if (total > 20) stride = 2;
  else if (total > 8) stride = 2;

  final showIndices = <int>{};
  for (var i = 0; i < total; i++) {
    if (i % stride == 0 || i == total - 1) showIndices.add(i);
  }
  final indices = showIndices.toList()..sort();

  return Padding(
    padding: const EdgeInsets.only(left: 28, right: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: indices
          .map((i) => Text(points[i].label,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
              maxLines: 1))
          .toList(),
    ),
  );
}

// ==================== Empty Hint ====================
class _EmptyHint extends StatelessWidget {
  const _EmptyHint();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: const Text('暂无数据',
          style: TextStyle(fontSize: 12, color: Colors.grey)),
    );
  }
}
