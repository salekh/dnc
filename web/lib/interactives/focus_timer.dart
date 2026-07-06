import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design_system/design_system.dart';

class FocusTimer extends StatefulWidget {
  const FocusTimer({super.key});

  @override
  State<FocusTimer> createState() => _FocusTimerState();
}

class _FocusTimerState extends State<FocusTimer> {
  static const int _defaultSeconds = 1500; // 25 minutes
  int _secondsRemaining = _defaultSeconds;
  bool _isRunning = false;
  Timer? _timer;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs != null) {
      final savedSeconds = _prefs!.getInt('focus_timer_seconds');
      final savedIsRunning = _prefs!.getBool('focus_timer_running') ?? false;
      final savedLastTick = _prefs!.getInt('focus_timer_last_tick');

      if (savedSeconds != null) {
        setState(() {
          _secondsRemaining = savedSeconds;
        });
      }

      if (savedIsRunning && savedLastTick != null) {
        // Calculate offset if app was closed
        final now = DateTime.now().millisecondsSinceEpoch;
        final elapsedSeconds = ((now - savedLastTick) / 1000).floor();
        setState(() {
          _secondsRemaining = (savedSeconds! - elapsedSeconds).clamp(0, _defaultSeconds);
          if (_secondsRemaining > 0) {
            _startTimer();
          } else {
            _secondsRemaining = _defaultSeconds;
            _isRunning = false;
          }
        });
      }
    }
  }

  Future<void> _saveState() async {
    if (_prefs != null) {
      await _prefs!.setInt('focus_timer_seconds', _secondsRemaining);
      await _prefs!.setBool('focus_timer_running', _isRunning);
      await _prefs!.setInt('focus_timer_last_tick', DateTime.now().millisecondsSinceEpoch);
    }
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
        _saveState();
      } else {
        _stopTimer(reset: true);
      }
    });
  }

  void _stopTimer({bool reset = false}) {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (reset) {
        _secondsRemaining = _defaultSeconds;
      }
    });
    _saveState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1.0 - (_secondsRemaining / _defaultSeconds);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.elevated, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "AGENT COGNITIVE SYNCHRONIZATION",
            style: AppTypography.caption.copyWith(
              color: AppColors.accentPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Focus Sprint Countdown",
            style: AppTypography.subheading.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 32),

          // Circle visualizer
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: AppColors.elevated,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentPrimary),
                ),
                Text(
                  _formatTime(_secondsRemaining),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 32,
                style: IconButton.styleFrom(
                  backgroundColor: _isRunning ? Colors.amber : Colors.green,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  if (_isRunning) {
                    _stopTimer();
                  } else {
                    _startTimer();
                  }
                },
              ),
              const SizedBox(width: 24),
              IconButton(
                iconSize: 32,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.elevated,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.replay),
                onPressed: () {
                  _stopTimer(reset: true);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Time limits & state saved to localStorage",
            style: AppTypography.caption.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
