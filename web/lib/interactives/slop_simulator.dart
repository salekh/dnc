import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class SlopSimulator extends StatefulWidget {
  const SlopSimulator({super.key});

  @override
  State<SlopSimulator> createState() => _SlopSimulatorState();
}

class _SlopSimulatorState extends State<SlopSimulator> with SingleTickerProviderStateMixin {
  double _specQuality = 0.90; // 0.0 to 1.0
  double _manualCode = 0.10; // 0.0 to 1.0
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate system metrics based on inputs
    final alignment = (_specQuality * (1.0 - _manualCode)).clamp(0.0, 1.0);
    final technicalSlop = (_manualCode * 1.2 * (1.5 - _specQuality)).clamp(0.0, 1.0);
    final cognitiveDebt = (technicalSlop * 1.5 + (1.0 - _specQuality) * 0.5).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.elevated, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SPEC VS. CODE ALIGNMENT",
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "System Decay Simulator",
                    style: AppTypography.subheading.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
              _buildStatusBadge(alignment),
            ],
          ),
          const SizedBox(height: 24),

          // Central Visualization
          Expanded(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _AlignmentPainter(
                    alignment: alignment,
                    slop: technicalSlop,
                    pulse: _pulseController.value,
                  ),
                  child: Container(),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Metrics Panel
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  "Intent Alignment",
                  "${(alignment * 100).toInt()}%",
                  alignment > 0.7
                      ? Colors.green
                      : alignment > 0.4
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  "Technical Slop",
                  "${(technicalSlop * 100).toInt()}%",
                  technicalSlop < 0.3
                      ? Colors.green
                      : technicalSlop < 0.6
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  "Cognitive Debt",
                  "${(cognitiveDebt * 100).toInt()}%",
                  cognitiveDebt < 0.3
                      ? Colors.green
                      : cognitiveDebt < 0.6
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sliders
          _buildSlider(
            title: "Specification Precision / Quality",
            value: _specQuality,
            activeColor: AppColors.accentPrimary,
            onChanged: (val) {
              setState(() {
                _specQuality = val;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildSlider(
            title: "Manual Code Bypass (Spec-less Edits)",
            value: _manualCode,
            activeColor: Colors.amber,
            onChanged: (val) {
              setState(() {
                _manualCode = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(double alignment) {
    String label = "UNKNOWN";
    Color color = Colors.grey;

    if (alignment > 0.8) {
      label = "SSOT COMPLIANT";
      color = Colors.green;
    } else if (alignment > 0.5) {
      label = "MINOR DRIFT";
      color = Colors.orange;
    } else {
      label = "CRITICAL DECAY";
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surface, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String title,
    required double value,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
            ),
            Text(
              "${(value * 100).toInt()}%",
              style: AppTypography.caption.copyWith(
                color: activeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor,
            inactiveTrackColor: AppColors.elevated,
            thumbColor: activeColor,
            overlayColor: activeColor.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _AlignmentPainter extends CustomPainter {
  final double alignment;
  final double slop;
  final double pulse;

  _AlignmentPainter({
    required this.alignment,
    required this.slop,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final leftNode = Offset(size.width * 0.2, size.height / 2);
    final rightNode = Offset(size.width * 0.8, size.height / 2);

    // Draw grid background
    final gridPaint = Paint()
      ..color = AppColors.elevated.withOpacity(0.2)
      ..strokeWidth = 1.0;

    const int gridLines = 8;
    for (int i = 0; i <= gridLines; i++) {
      final x = size.width * (i / gridLines);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      final y = size.height * (i / gridLines);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw base connection (Spec execution link)
    final linePaint = Paint()
      ..strokeWidth = 3.0 + (pulse * 1.5)
      ..style = PaintingStyle.stroke;

    if (alignment > 0.0) {
      final path = Path();
      path.moveTo(leftNode.dx, leftNode.dy);
      final ctrl1 = Offset(size.width * 0.45, size.height / 2 - (10 - alignment * 10));
      final ctrl2 = Offset(size.width * 0.55, size.height / 2 - (10 - alignment * 10));
      path.cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, rightNode.dx, rightNode.dy);

      linePaint.color = Color.lerp(Colors.orange, AppColors.accentPrimary, alignment.clamp(0.0, 1.0))!
          .withOpacity(alignment.clamp(0.2, 1.0));
      canvas.drawPath(path, linePaint);
    }

    // If slop > 0, draw chaotic spaghetti lines
    if (slop > 0.0) {
      final random = math.Random(42);
      final slopCount = (slop * 15).toInt() + 1;
      
      for (int i = 0; i < slopCount; i++) {
        final path = Path();
        path.moveTo(leftNode.dx, leftNode.dy);

        final displacementX = (random.nextDouble() - 0.5) * size.width * 0.3 * slop;
        final displacementY = (random.nextDouble() - 0.5) * size.height * 0.6 * slop;

        final ctrl1 = Offset(
          size.width * 0.45 + displacementX,
          size.height / 2 + displacementY + (math.sin(pulse * math.pi * 2 + i) * 12 * slop),
        );
        final ctrl2 = Offset(
          size.width * 0.55 - displacementX,
          size.height / 2 - displacementY + (math.cos(pulse * math.pi * 2 - i) * 12 * slop),
        );

        path.cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, rightNode.dx, rightNode.dy);

        final spaghettiPaint = Paint()
          ..strokeWidth = 1.0 + (random.nextDouble() * 2.0 * slop)
          ..style = PaintingStyle.stroke
          ..color = Colors.red.withOpacity(0.3 + (slop * 0.5));

        canvas.drawPath(path, spaghettiPaint);
      }
    }

    // Draw nodes
    final nodePaintLeft = Paint()
      ..color = AppColors.accentPrimary
      ..style = PaintingStyle.fill;
      
    final nodePaintRight = Paint()
      ..color = Color.lerp(Colors.red, Colors.green, alignment)!
      ..style = PaintingStyle.fill;

    // Glowing rings around nodes
    canvas.drawCircle(leftNode, 14.0 + (pulse * 3.0), Paint()..color = AppColors.accentPrimary.withOpacity(0.2));
    canvas.drawCircle(rightNode, 14.0 + (pulse * 3.0), Paint()..color = nodePaintRight.color.withOpacity(0.2));

    canvas.drawCircle(leftNode, 9.0, nodePaintLeft);
    canvas.drawCircle(rightNode, 9.0, nodePaintRight);

    // Text labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Left Node
    textPainter.text = const TextSpan(
      text: "SPECIFICATION",
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 1.0,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(leftNode.dx - textPainter.width / 2, leftNode.dy - 28));

    // Right Node
    textPainter.text = const TextSpan(
      text: "GENERATED CODE",
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 1.0,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(rightNode.dx - textPainter.width / 2, rightNode.dy - 28));
  }

  @override
  bool shouldRepaint(covariant _AlignmentPainter oldDelegate) {
    return oldDelegate.alignment != alignment || oldDelegate.slop != slop || oldDelegate.pulse != pulse;
  }
}
