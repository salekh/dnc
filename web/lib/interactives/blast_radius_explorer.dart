import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class BlastRadiusExplorer extends StatefulWidget {
  const BlastRadiusExplorer({super.key});

  @override
  State<BlastRadiusExplorer> createState() => _BlastRadiusExplorerState();
}

class _BlastRadiusExplorerState extends State<BlastRadiusExplorer> with SingleTickerProviderStateMixin {
  double _strictness = 0.30; // 0.0 to 1.0
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.elevated, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CONTAINMENT SANDBOX EXPLORER",
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Blast Radius Containment Boundaries",
                    style: AppTypography.subheading.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _strictness > 0.7
                      ? Colors.green.withOpacity(0.15)
                      : _strictness > 0.4
                          ? Colors.orange.withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _strictness > 0.7 ? "SAFE CONTAINMENT" : _strictness > 0.4 ? "RISK OF SPILLOVER" : "UNCONTAINED SYSTEM",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _strictness > 0.7 ? Colors.green : _strictness > 0.4 ? Colors.orange : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Node Graph Board
          Expanded(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _BlastRadiusPainter(
                    strictness: _strictness,
                    pulse: _pulseController.value,
                  ),
                  child: Container(),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Slider Controls
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Sandbox Isolation Strictness", style: AppTypography.caption),
                  Text(
                    "${(_strictness * 100).toInt()}% Isolation",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.accentPrimary,
                  thumbColor: AppColors.accentPrimary,
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _strictness,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (val) {
                    setState(() {
                      _strictness = val;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlastRadiusPainter extends CustomPainter {
  final double strictness;
  final double pulse;

  _BlastRadiusPainter({required this.strictness, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    // Component positions
    final mainAgent = Offset(size.width * 0.5, size.height * 0.5);
    final databaseNode = Offset(size.width * 0.25, size.height * 0.35);
    final filesystemNode = Offset(size.width * 0.75, size.height * 0.35);
    final cloudDeployNode = Offset(size.width * 0.5, size.height * 0.8);

    // Draw connection paths
    final connPaint = Paint()
      ..color = AppColors.textSecondary.withOpacity(0.3)
      ..strokeWidth = 1.5;

    canvas.drawLine(mainAgent, databaseNode, connPaint);
    canvas.drawLine(mainAgent, filesystemNode, connPaint);
    canvas.drawLine(mainAgent, cloudDeployNode, connPaint);

    // Draw Blast Radii
    // As strictness increases, blast radius (danger circle) shrinks.
    final dangerRadius = (1.0 - strictness) * 90.0 + 10.0;
    final safetyRadius = strictness * 60.0 + 15.0;

    final dangerPaint = Paint()
      ..color = Colors.red.withOpacity(0.12 + (pulse * 0.05))
      ..style = PaintingStyle.fill;
    final dangerBorderPaint = Paint()
      ..color = Colors.redAccent.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final safetyPaint = Paint()
      ..color = Colors.green.withOpacity(0.10)
      ..style = PaintingStyle.fill;
    final safetyBorderPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw agent blast boundaries
    if (strictness < 0.95) {
      canvas.drawCircle(mainAgent, dangerRadius + (pulse * 5.0), dangerPaint);
      canvas.drawCircle(mainAgent, dangerRadius + (pulse * 5.0), dangerBorderPaint);
    }

    if (strictness > 0.05) {
      canvas.drawCircle(mainAgent, safetyRadius, safetyPaint);
      canvas.drawCircle(mainAgent, safetyRadius, safetyBorderPaint);
    }

    // Draw nodes
    canvas.drawCircle(mainAgent, 12, Paint()..color = AppColors.accentPrimary);
    canvas.drawCircle(databaseNode, 9, Paint()..color = Colors.amber);
    canvas.drawCircle(filesystemNode, 9, Paint()..color = Colors.indigoAccent);
    canvas.drawCircle(cloudDeployNode, 9, Paint()..color = Colors.teal);

    // Node labels
    final tp = TextPainter(textDirection: TextDirection.ltr);

    _drawText(canvas, tp, "AGENT CAPSULE", mainAgent + const Offset(0, 16));
    _drawText(canvas, tp, "PROD DATABASE", databaseNode - const Offset(0, 20));
    _drawText(canvas, tp, "ROOT FILESYSTEM", filesystemNode - const Offset(0, 20));
    _drawText(canvas, tp, "CLOUD SERVICE", cloudDeployNode + const Offset(0, 16));
  }

  void _drawText(Canvas canvas, TextPainter tp, String text, Offset position) {
    tp.text = TextSpan(
      text: text,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 0.8,
      ),
    );
    tp.layout();
    tp.paint(canvas, Offset(position.dx - tp.width / 2, position.dy));
  }

  @override
  bool shouldRepaint(covariant _BlastRadiusPainter oldDelegate) {
    return oldDelegate.strictness != strictness || oldDelegate.pulse != pulse;
  }
}
