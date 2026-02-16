import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Background type enum
enum BackgroundType { solid, gradient, image }

/// Provider for background type
final backgroundTypeProvider = StateProvider<BackgroundType>((ref) {
  final box = Hive.box('app_settings');
  final stored = box.get('background_type', defaultValue: 'solid');
  switch (stored) {
    case 'gradient':
      return BackgroundType.gradient;
    case 'image':
      return BackgroundType.image;
    default:
      return BackgroundType.solid;
  }
});

/// Provider for background color index (preset colors)
final backgroundColorIndexProvider = StateProvider<int>((ref) {
  final box = Hive.box('app_settings');
  return box.get('background_color_index', defaultValue: 0) as int;
});

/// Provider for background image path
final backgroundImagePathProvider = StateProvider<String?>((ref) {
  final box = Hive.box('app_settings');
  return box.get('background_image_path', defaultValue: null);
});

/// Provider for background brightness (to control text color)
/// 'light' means Light Theme (Dark Text), 'dark' means Dark Theme (White Text)
final backgroundBrightnessProvider = StateProvider<String>((ref) {
  final box = Hive.box('app_settings');
  return box.get(
    'background_brightness',
    defaultValue: 'dark',
  ); // Default to dark (white text) for backward compat
});

/// Preset gradient color pairs
class BackgroundPresets {
  static const List<Map<String, dynamic>> presets = [
    {
      'name': 'Default',
      'colors': [Color(0xFF0D471C), Color(0xFF004D40)],
      'icon': Icons.spa,
    },
    {
      'name': 'Emerald',
      'colors': [Color(0xFF1B5E20), Color(0xFF2E7D32)],
      'icon': Icons.eco,
    },
    {
      'name': 'Ocean',
      'colors': [Color(0xFF0D47A1), Color(0xFF1565C0)],
      'icon': Icons.water,
    },
    {
      'name': 'Sunset',
      'colors': [Color(0xFFE65100), Color(0xFFF57C00)],
      'icon': Icons.wb_twilight,
    },
    {
      'name': 'Rose',
      'colors': [Color(0xFF880E4F), Color(0xFFC2185B)],
      'icon': Icons.local_florist,
    },
    {
      'name': 'Midnight',
      'colors': [Color(0xFF1A237E), Color(0xFF283593)],
      'icon': Icons.nights_stay,
    },
    {
      'name': 'Lavender',
      'colors': [Color(0xFF4A148C), Color(0xFF7B1FA2)],
      'icon': Icons.auto_awesome,
    },
    {
      'name': 'Teal',
      'colors': [Color(0xFF004D40), Color(0xFF00695C)],
      'icon': Icons.landscape,
    },
    {
      'name': 'Charcoal',
      'colors': [Color(0xFF212121), Color(0xFF424242)],
      'icon': Icons.dark_mode,
    },
    {
      'name': 'Gold',
      'colors': [Color(0xFF795548), Color(0xFFA1887F)],
      'icon': Icons.mosque,
    },
    {
      'name': 'Sahara',
      'colors': [Color(0xFFBF360C), Color(0xFFD84315)],
      'icon': Icons.wb_sunny,
    },
    {
      'name': 'Forest',
      'colors': [Color(0xFF33691E), Color(0xFF558B2F)],
      'icon': Icons.forest,
    },
  ];
}

/// Helper to get current background decoration
BoxDecoration? getBackgroundDecoration(WidgetRef ref) {
  final bgType = ref.watch(backgroundTypeProvider);
  final colorIndex = ref.watch(backgroundColorIndexProvider);
  final imagePath = ref.watch(backgroundImagePathProvider);

  switch (bgType) {
    case BackgroundType.solid:
      return null; // Use default scaffold background
    case BackgroundType.gradient:
      if (colorIndex >= 0 && colorIndex < BackgroundPresets.presets.length) {
        final colors =
            BackgroundPresets.presets[colorIndex]['colors'] as List<Color>;
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors[0].withValues(alpha: 0.15),
              colors[1].withValues(alpha: 0.08),
            ],
          ),
        );
      }
      return null;
    case BackgroundType.image:
      if (imagePath != null && imagePath.isNotEmpty) {
        return BoxDecoration(
          image: DecorationImage(
            image: FileImage(File(imagePath)),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.3),
              BlendMode.darken,
            ),
          ),
        );
      }
      return null;
  }
}
