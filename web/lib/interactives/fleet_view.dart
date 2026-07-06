import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class FleetView extends StatefulWidget {
  const FleetView({super.key});

  @override
  State<FleetView> createState() => _FleetViewState();
}

class _FleetViewState extends State<FleetView> with SingleTickerProviderStateMixin {
  late Timer _ticker;
  double _pulseValue = 0.0;
  final math.Random _random = math.Random();

  // Mock agents list
  final List<Map<String, dynamic>> _agents = [
    {
      "name": "Planner-04",
      "type": "Planning",
      "status": "ACTIVE",
      "task": "Parsing content/magenta-tv/spec.md",
      "progress": 0.45,
      "log": "Observation Phase: loading spec dependencies..."
    },
    {
      "name": "Builder-09",
      "type": "Synthesis",
      "status": "ACTIVE",
      "task": "Regenerating query-watch-history.md",
      "progress": 0.88,
      "log": "Writing target SQL queries to sandbox..."
    },
    {
      "name": "Verifier-02",
      "type": "Validation",
      "status": "IDLE",
      "task": "Awaiting build completion",
      "progress": 0.0,
      "log": "Idle. Ready to scan target compile targets."
    },
    {
      "name": "Auditor-01",
      "type": "Safety Check",
      "status": "ACTIVE",
      "task": "Scanning imports for banned packages",
      "progress": 0.15,
      "log": "Audit: checking imports against GEMINI.md policy..."
    },
  ];

  final List<String> _plannerTasks = [
    "Parsing content/magenta-tv/spec.md",
    "Validating interface contracts in plan.md",
    "Mapping PRD user stories to execution phases",
    "Extracting schema requirements from design.md"
  ];

  final List<String> _builderTasks = [
    "Regenerating query-watch-history.md",
    "Synthesizing recommendations.dart helper methods",
    "Applying lint fixes to watch_history_test.go",
    "Compiling generated protobuf messages"
  ];

  final List<String> _verifierTasks = [
    "Running unit test suites...",
    "Running static analyzer check gates",
    "Running load-tests: 10,000 QPS target simulation",
    "Executing dry-run database deployments"
  ];

  final List<String> _auditorTasks = [
    "Scanning imports for banned packages",
    "Verifying memory-safety isolation parameters",
    "Auditing capsule sandbox execution limits",
    "Running vulnerability dependency resolver"
  ];

  @override
  void initState() {
    super.initState();
    // Live simulator tick
    _ticker = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) return;
      setState(() {
        _pulseValue = (_pulseValue + 0.15) % 1.0;
        
        // Randomly update agent tasks & logs to simulate live progress
        for (var agent in _agents) {
          if (agent["status"] == "ACTIVE") {
            agent["progress"] += _random.nextDouble() * 0.08;
            if (agent["progress"] >= 1.0) {
              agent["progress"] = 0.0;
              // Cycle to next tasks
              if (agent["type"] == "Planning") {
                agent["task"] = _plannerTasks[_random.nextInt(_plannerTasks.length)];
                agent["log"] = "Planning: executing phase blueprint...";
              } else if (agent["type"] == "Synthesis") {
                agent["task"] = _builderTasks[_random.nextInt(_builderTasks.length)];
                agent["log"] = "Synthesis: writing target source files...";
              } else if (agent["type"] == "Validation") {
                agent["task"] = _verifierTasks[_random.nextInt(_verifierTasks.length)];
                agent["log"] = "Validation: running test suite suites...";
              } else if (agent["type"] == "Safety Check") {
                agent["task"] = _auditorTasks[_random.nextInt(_auditorTasks.length)];
                agent["log"] = "Safety Audit: validating sandboxed commands...";
              }
            }
          }

          // Random idle/active cycle
          if (_random.nextDouble() < 0.1) {
            agent["status"] = agent["status"] == "ACTIVE" ? "IDLE" : "ACTIVE";
            if (agent["status"] == "IDLE") {
              agent["progress"] = 0.0;
              agent["task"] = "Awaiting instructions...";
              agent["log"] = "Standby mode.";
            } else {
              agent["progress"] = _random.nextDouble() * 0.3;
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AGENT FLEET DASHBOARD",
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Active Agent Nodes & Global SLOs",
                    style: AppTypography.subheading.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "LIVE CONNECTION STATUS",
                    style: AppTypography.caption.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Speedometer SLO Dials
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSloDial("Spec Compliance", 0.984, "98.4%", Colors.green),
              _buildSloDial("Mean Healing Time", 0.72, "42s", Colors.cyan),
              _buildSloDial("Build Success Rate", 0.998, "99.8%", AppColors.accentPrimary),
              _buildSloDial("Sandbox Isolation", 1.0, "100%", Colors.purpleAccent),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            "ACTIVE AGENT ORCHESTRATION FLEET",
            style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 12),

          // Agents Grid / List
          Expanded(
            child: ListView.builder(
              itemCount: _agents.length,
              itemBuilder: (context, index) {
                final agent = _agents[index];
                final isActive = agent["status"] == "ACTIVE";
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive ? AppColors.accentPrimary.withOpacity(0.3) : AppColors.surface,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Status dot with pulse effect
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isActive)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accentPrimary.withOpacity(0.2 * _pulseValue),
                              ),
                            ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive ? AppColors.accentPrimary : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Name and details
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              agent["name"],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              agent["type"],
                              style: AppTypography.caption.copyWith(color: AppColors.accentPrimary),
                            ),
                          ],
                        ),
                      ),

                      // Current Task
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              agent["task"],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            if (isActive)
                              LinearProgressIndicator(
                                value: agent["progress"],
                                backgroundColor: AppColors.base,
                                color: AppColors.accentPrimary,
                                minHeight: 4,
                              )
                            else
                              const Text(
                                "Standby",
                                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Console Logs ticker
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.base,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            agent["log"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 10,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSloDial(String label, double value, String displayValue, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CustomPaint(
            painter: _SloDialPainter(value: value, color: color),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    displayValue,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _SloDialPainter extends CustomPainter {
  final double value;
  final Color color;

  _SloDialPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background track arc
    final trackPaint = Paint()
      ..color = AppColors.elevated
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw a semi-circle dial from 135 to 405 degrees (leaving the bottom open)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      135 * math.pi / 180,
      270 * math.pi / 180,
      false,
      trackPaint,
    );

    // Draw filled value arc
    final valPaint = Paint()
      ..color = color
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      135 * math.pi / 180,
      (270 * value) * math.pi / 180,
      false,
      valPaint,
    );

    // Draw dial needle pointer
    final angle = (135 + (270 * value)) * math.pi / 180;
    final needlePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    final needleLength = radius - 12;
    final needleTip = Offset(
      center.dx + needleLength * math.cos(angle),
      center.dy + needleLength * math.sin(angle),
    );

    canvas.drawLine(center, needleTip, needlePaint);
    canvas.drawCircle(center, 4.0, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SloDialPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
