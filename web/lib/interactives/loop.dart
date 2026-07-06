import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class Loop extends StatefulWidget {
  const Loop({super.key});

  @override
  State<Loop> createState() => _LoopState();
}

class _LoopState extends State<Loop> with SingleTickerProviderStateMixin {
  int _activeNodeIndex = 0;
  late AnimationController _rotationController;

  final List<Map<String, dynamic>> _nodes = [
    {
      "title": "Observation",
      "icon": Icons.search,
      "desc": "The agent reads specifications, scans files, queries dependencies, and collects local workspace context.",
      "log": "[LOG] Scan target content/magenta-tv/spec.md...\n[LOG] Found 4 pending proposals.\n[LOG] Loaded codebase symbols map."
    },
    {
      "title": "Hypothesis",
      "icon": Icons.psychology,
      "desc": "The agent reasons about the changes required to resolve the drift, planning edits, and validating security rules.",
      "log": "[LOG] Formulating plan: replace WatchHistory interface.\n[LOG] Check compliance: no external libraries allowed.\n[LOG] Plan locked: 3 targets affected."
    },
    {
      "title": "Implementation",
      "icon": Icons.code,
      "desc": "The agent executes code changes and updates target source files in the container sandbox.",
      "log": "[LOG] Updating recommendations.dart...\n[LOG] Writing changes (14 lines added, 3 lines removed).\n[LOG] Running local compiler... build successful."
    },
    {
      "title": "Evaluation",
      "icon": Icons.fact_check,
      "desc": "The agent runs validation checks: static analyzer gates, unit tests, and latency simulation. If checks fail, the loop restarts.",
      "log": "[LOG] Running watch_history_test.go... PASS.\n[LOG] Running latency load tests... PASS.\n[LOG] Evaluation Complete: 100% compliance."
    },
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
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
          // Header
          Text(
            "THE AGENTIC SELF-HEALING LOOP",
            style: AppTypography.caption.copyWith(
              color: AppColors.accentPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Observation, Hypothesis, Action, Verification",
            style: AppTypography.subheading.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 24),

          // Central Radial Flowchart and Detail Panel split
          Expanded(
            child: Row(
              children: [
                // Left side: Radial Loop
                Expanded(
                  flex: 5,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating dotted path circle
                      AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationController.value * 2 * math.pi,
                            child: CustomPaint(
                              size: const Size(200, 200),
                              painter: _DottedCirclePainter(),
                            ),
                          );
                        },
                      ),
                      
                      // Node buttons placed in a circle
                      ...List.generate(4, (index) {
                        final angle = (index * 90 - 90) * math.pi / 180;
                        const double radius = 95.0;
                        final node = _nodes[index];
                        final isSelected = _activeNodeIndex == index;

                        return Transform.translate(
                          offset: Offset(radius * math.cos(angle), radius * math.sin(angle)),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _activeNodeIndex = index;
                              });
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.accentPrimary : AppColors.elevated,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : AppColors.surface,
                                  width: 2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.accentPrimary.withOpacity(0.4),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                node["icon"],
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                                size: 22,
                              ),
                            ),
                          ),
                        );
                      }),
                      
                      // Inner core label
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cached, color: AppColors.accentPrimary, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            "FEEDBACK\nLOOP",
                            textAlign: TextAlign.center,
                            style: AppTypography.caption.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Right side: Details panel
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nodes[_activeNodeIndex]["title"].toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _nodes[_activeNodeIndex]["desc"],
                          style: const TextStyle(fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "AGENT CONSOLE OUTPUT:",
                          style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.base,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                _nodes[_activeNodeIndex]["log"],
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 10,
                                  color: Colors.greenAccent,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary.withOpacity(0.2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw simple dotted circular track
    const int dots = 40;
    for (int i = 0; i < dots; i++) {
      final angle = (i * (360 / dots)) * math.pi / 180;
      final offset = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
      canvas.drawCircle(offset, 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DottedCirclePainter oldDelegate) => false;
}
