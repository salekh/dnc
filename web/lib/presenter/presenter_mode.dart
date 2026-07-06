import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';

class TogglePresenterModeIntent extends Intent {
  const TogglePresenterModeIntent();
}

class PresenterMode extends StatefulWidget {
  final Widget child;

  const PresenterMode({super.key, required this.child});

  @override
  State<PresenterMode> createState() => _PresenterModeState();
}

class _PresenterModeState extends State<PresenterMode> {
  bool _isPresenterMode = false;

  void _togglePresenterMode() {
    setState(() {
      _isPresenterMode = !_isPresenterMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.keyP): const TogglePresenterModeIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          TogglePresenterModeIntent: CallbackAction<TogglePresenterModeIntent>(
            onInvoke: (TogglePresenterModeIntent intent) {
              _togglePresenterMode();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Stack(
            children: [
              widget.child,
              if (_isPresenterMode) _buildOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Center(
        child: AnimatedContainer(
          duration: AppMotion.defaultDuration,
          curve: AppMotion.silkCurve,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.elevated.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accentPrimary.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.accentPrimary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Presenter Mode Active',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _togglePresenterMode,
                child: const Text('Exit (P)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
