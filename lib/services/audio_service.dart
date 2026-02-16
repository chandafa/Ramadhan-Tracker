import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> init() async {
    // Preload sounds if necessary
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playCompletionSound() async {
    try {
      // Ensure you add a sound file to assets/audio/completion.mp3
      // For now, this is a placeholder. If file missing, it might log an error but won't crash app (usually).
      await _player.play(AssetSource('audio/completion.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
