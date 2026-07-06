import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class SnrOscilloscope extends StatefulWidget {
  const SnrOscilloscope({super.key});

  @override
  State<SnrOscilloscope> createState() => _SnrOscilloscopeState();
}

class _SnrOscilloscopeState extends State<SnrOscilloscope> with SingleTickerProviderStateMixin {
  double _snrScore = 80.0; // 0% to 100%
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
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
                    "SPEC SIGNAL-TO-NOISE RATIO",
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Specification Clarity Oscilloscope",
                    style: AppTypography.subheading.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _snrScore > 70
                      ? Colors.green.withOpacity(0.15)
                      : _snrScore > 40
                          ? Colors.orange.withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _snrScore > 70 ? "HIGH FIDELITY" : _snrScore > 40 ? "DRIFTING" : "COGNITIVE NOISE",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _snrScore > 70 ? Colors.green : _snrScore > 40 ? Colors.orange : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Wave Viewer Box
          Expanded(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _OscilloscopePainter(
                    snr: _snrScore / 100.0,
                    phase: _waveController.value,
                  ),
                  child: Container(),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Slider control
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Clarity (Signal Ratio)", style: AppTypography.caption),
                  Text(
                    "${_snrScore.toInt()} dB SNR",
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
                  value: _snrScore,
                  min: 5.0,
                  max: 100.0,
                  onChanged: (val) {
                    setState(() {
                      _snrScore = val;
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

class _OscilloscopePainter extends CustomPainter {
  final double snr; // 0.0 to 1.0
  final double phase; // 0.0 to 1.0

  _OscilloscopePainter({required this.snr, required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background grid
    final gridPaint = Paint()
      ..color = AppColors.elevated.withOpacity(0.4)
      ..strokeWidth = 1.0;

    final centerY = size.height / 2;

    // Draw horizontal grid lines
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    // Draw vertical grid lines
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw center line
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      Paint()
        ..color = AppColors.textSecondary.withOpacity(0.3)
        ..strokeWidth = 1.5,
    );

    // Draw signal wave
    final wavePath = Path();
    final random = math.Random(1234);

    for (double x = 0; x < size.width; x++) {
      // Base Clean Sine Wave
      final waveAngle = (x / size.width) * 4 * math.pi + (phase * 2 * math.pi);
      double signalY = math.sin(waveAngle) * (size.height * 0.25);

      // Noise Component (Square / random distortion)
      final noiseAngle = (x / size.width) * 24 * math.pi + (phase * 8 * math.pi);
      // High noise produces square/noisy peaks
      final noiseValue = (math.sin(noiseAngle) > 0 ? 1.0 : -1.0) * (random.nextDouble() - 0.5) * 20.0;

      // Interpolate between clean signal and noisy signal based on SNR
      final double finalY = centerY + (signalY * snr) + (noiseValue * (1.0 - snr));

      if (x == 0) {
        wavePath.moveTo(x, finalY);
      } else {
        wavePath.lineTo(x, finalY);
      }
    }

    final wavePaint = Paint()
      ..color = Color.lerp(Colors.redAccent, Colors.greenAccent, snr)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _OscilloscopePainter oldDelegate) {
    return oldDelegate.snr != snr || oldDelegate.phase != phase;
  }
}
