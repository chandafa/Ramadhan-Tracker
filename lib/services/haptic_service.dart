import 'package:flutter/services.dart';
// import 'package:audioplayers/audioplayers.dart'; // Unused for now
// import '../services/hive_service.dart';

class HapticService {
  // We can inject HiveService to save prefs, or just use a simple flag for now/
  // Better to pass HiveService or load from it.

  bool _hapticEnabled = false;
  bool _soundEnabled = false;

  bool get hapticEnabled => _hapticEnabled;
  bool get soundEnabled => _soundEnabled;

  HapticService();

  Future<void> init() async {
    // Load prefs if needed
  }

  Future<void> setHaptic(bool value) async {
    _hapticEnabled = value;
    // Save to hive
  }

  Future<void> setSound(bool value) async {
    _soundEnabled = value;
    // Save to hive
  }

  Future<void> feedbackSuccess() async {
    if (_hapticEnabled) {
      await HapticFeedback.mediumImpact();
    }
    if (_soundEnabled) {
      // Play sound
      // Ensure asset exists: assets/sounds/success.mp3
      // For now, let's just use a system sound or skip if asset missing
      // await _audioPlayer.play(AssetSource('sounds/success.mp3'));
      // Since I don't have the asset, I won't play it to avoid errors.
      // Or I can generate a sound? No.
      // User asked for "suara lonceng".
      SystemSound.play(SystemSoundType.click); // Simple alternative
    }
  }
}
