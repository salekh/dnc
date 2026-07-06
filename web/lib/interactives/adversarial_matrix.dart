import 'dart:async';
import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class AdversarialMatrix extends StatefulWidget {
  const AdversarialMatrix({super.key});

  @override
  State<AdversarialMatrix> createState() => _AdversarialMatrixState();
}

class _AdversarialMatrixState extends State<AdversarialMatrix> {
  bool _isPlaying = false;
  int _elapsedSeconds = 0;
  Timer? _timer;

  // Verification steps mapped by seconds range
  final List<Map<String, dynamic>> _steps = [
    {
      "name": "Phase 1: Sandbox Initialization",
      "start": 0,
      "end": 5,
      "status": "PENDING",
      "detail": "Spinning up isolated Dev Capsule sandbox...",
    },
    {
      "name": "Phase 2: Latency SLO Check",
      "start": 5,
      "end": 12,
      "status": "PENDING",
      "detail": "Running 10k QPS load simulator. Target: p99 <= 50ms.",
    },
    {
      "name": "Phase 3: Banned Package Audit",
      "start": 12,
      "end": 18,
      "status": "PENDING",
      "detail": "Auditing AST imports against GEMINI.md policy...",
    },
    {
      "name": "Phase 4: Regression Test Verification",
      "start": 18,
      "end": 25,
      "status": "PENDING",
      "detail": "Executing rapid-cli test suite //content/magenta-tv/...",
    },
    {
      "name": "Phase 5: Compliance Reporting",
      "start": 25,
      "end": 30,
      "status": "PENDING",
      "detail": "Compiling compliance json artifact log...",
    },
  ];

  void _startAnimation() {
    if (_isPlaying) return;
    setState(() {
      _isPlaying = true;
      _elapsedSeconds = 0;
      for (var step in _steps) {
        step["status"] = "PENDING";
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _elapsedSeconds++;
        
        // Update statuses based on elapsed time
        for (var step in _steps) {
          final int start = step["start"];
          final int end = step["end"];

          if (_elapsedSeconds >= end) {
            step["status"] = "PASSED";
          } else if (_elapsedSeconds >= start && _elapsedSeconds < end) {
            step["status"] = "RUNNING";
          } else {
            step["status"] = "PENDING";
          }
        }

        if (_elapsedSeconds >= 30) {
          _timer?.cancel();
          _isPlaying = false;
        }
      });
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _elapsedSeconds = 0;
      for (var step in _steps) {
        step["status"] = "PENDING";
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double totalProgress = (_elapsedSeconds / 30.0).clamp(0.0, 1.0);

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
                    "30S VERIFICATION SEQUENCE",
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Test-Driven Spec Verification Matrix",
                    style: AppTypography.subheading.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
              Row(
                children: [
                  if (_isPlaying)
                    Text(
                      "${30 - _elapsedSeconds}s left",
                      style: const TextStyle(fontFamily: 'Courier', color: AppColors.accentPrimary, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(width: 12),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: _isPlaying ? Colors.redAccent : AppColors.accentPrimary,
                      foregroundColor: Colors.white,
                    ),
                    icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                    onPressed: _isPlaying ? _reset : _startAnimation,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Total progress bar
          LinearProgressIndicator(
            value: totalProgress,
            backgroundColor: AppColors.elevated,
            color: AppColors.accentPrimary,
            minHeight: 6,
          ),
          const SizedBox(height: 24),

          // Steps list
          Expanded(
            child: ListView.builder(
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                final String status = step["status"];
                final String name = step["name"];
                final String detail = step["detail"];

                Color statusColor = Colors.grey;
                IconData statusIcon = Icons.radio_button_unchecked;
                bool showPulse = false;

                if (status == "PASSED") {
                  statusColor = Colors.greenAccent;
                  statusIcon = Icons.check_circle;
                } else if (status == "RUNNING") {
                  statusColor = AppColors.accentPrimary;
                  statusIcon = Icons.hourglass_top;
                  showPulse = true;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: status == "RUNNING" ? AppColors.accentPrimary.withOpacity(0.5) : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 20),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: status == "RUNNING" ? AppColors.accentPrimary : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              detail,
                              style: AppTypography.caption.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (showPulse)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accentPrimary,
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
}
