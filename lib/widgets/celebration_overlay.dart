import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

/// A celebration overlay that shows confetti when daily progress reaches 100%
class CelebrationOverlay extends ConsumerStatefulWidget {
  final Widget child;
  const CelebrationOverlay({super.key, required this.child});

  @override
  ConsumerState<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends ConsumerState<CelebrationOverlay> {
  late ConfettiController _confettiController;
  bool _hasShownForThisDay = false;
  int _lastCelebratedDay = -1;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _triggerCelebration(BuildContext context, int day) {
    if (_hasShownForThisDay && _lastCelebratedDay == day) return;
    _hasShownForThisDay = true;
    _lastCelebratedDay = day;
    _confettiController.play();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Masya Allah! 100% Completed!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Call this from the parent when progress changes
  void checkProgress(double progress, int day) {
    if (progress >= 1.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _triggerCelebration(context, day);
      });
    } else if (day != _lastCelebratedDay) {
      _hasShownForThisDay = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2, // downwards
            maxBlastForce: 25,
            minBlastForce: 8,
            emissionFrequency: 0.06,
            numberOfParticles: 20,
            gravity: 0.15,
            colors: const [
              Color(0xFF0D471C),
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF43A047),
              Color(0xFF66BB6A),
              Color(0xFFFBC02D),
              Color(0xFFFFD54F),
              Colors.white,
            ],
            shouldLoop: false,
          ),
        ),
      ],
    );
  }
}

/// A global key to access the celebration overlay from anywhere
final celebrationOverlayKey = GlobalKey<_CelebrationOverlayState>();
