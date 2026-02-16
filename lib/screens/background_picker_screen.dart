import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../providers/background_provider.dart';

/// Screen for customizing the app background with color presets or gallery image
class BackgroundPickerScreen extends ConsumerWidget {
  const BackgroundPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentType = ref.watch(backgroundTypeProvider);
    final currentColorIndex = ref.watch(backgroundColorIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Background'),
          actions: [
            // Text Color Toggle
            if (currentType != BackgroundType.solid)
              Consumer(
                builder: (context, ref, _) {
                  final brightness = ref.watch(backgroundBrightnessProvider);
                  return IconButton(
                    icon: Icon(
                      brightness == 'light'
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                    tooltip: 'Toggle Text Color',
                    onPressed: () {
                      final newBrightness = brightness == 'light'
                          ? 'dark'
                          : 'light';
                      ref.read(backgroundBrightnessProvider.notifier).state =
                          newBrightness;
                      Hive.box(
                        'app_settings',
                      ).put('background_brightness', newBrightness);
                    },
                  );
                },
              ),
          ],
          bottom: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            tabs: const [
              Tab(icon: Icon(Icons.color_lens), text: 'Colors'),
              Tab(icon: Icon(Icons.image), text: 'Gallery'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Color Presets
            _ColorPresetsTab(
              currentType: currentType,
              currentColorIndex: currentColorIndex,
            ),
            // Tab 2: Gallery Image
            const _GalleryTab(),
          ],
        ),
      ),
    );
  }
}

class _ColorPresetsTab extends ConsumerWidget {
  final BackgroundType currentType;
  final int currentColorIndex;

  const _ColorPresetsTab({
    required this.currentType,
    required this.currentColorIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Default (no background) option
          _buildOption(
            context: context,
            ref: ref,
            label: 'Default (No Background)',
            icon: Icons.format_color_reset,
            isSelected: currentType == BackgroundType.solid,
            colors: [Colors.grey[300]!, Colors.grey[400]!],
            onTap: () {
              ref.read(backgroundTypeProvider.notifier).state =
                  BackgroundType.solid;
              Hive.box('app_settings').put('background_type', 'solid');
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Gradient Presets',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          // Grid of preset gradients
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: BackgroundPresets.presets.length,
            itemBuilder: (context, index) {
              final preset = BackgroundPresets.presets[index];
              final colors = preset['colors'] as List<Color>;
              final name = preset['name'] as String;
              final icon = preset['icon'] as IconData;
              final isSelected =
                  currentType == BackgroundType.gradient &&
                  currentColorIndex == index;

              return GestureDetector(
                onTap: () {
                  ref.read(backgroundTypeProvider.notifier).state =
                      BackgroundType.gradient;
                  ref.read(backgroundColorIndexProvider.notifier).state = index;
                  Hive.box('app_settings').put('background_type', 'gradient');
                  Hive.box('app_settings').put('background_color_index', index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colors[0].withValues(alpha: 0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 28),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required IconData icon,
    required bool isSelected,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _GalleryTab extends ConsumerWidget {
  const _GalleryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = ref.watch(backgroundImagePathProvider);
    final currentType = ref.watch(backgroundTypeProvider);
    final hasImage =
        imagePath != null &&
        imagePath.isNotEmpty &&
        currentType == BackgroundType.image;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Preview area
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).cardColor,
              image: hasImage
                  ? DecorationImage(
                      image: FileImage(File(imagePath)),
                      fit: BoxFit.cover,
                    )
                  : null,
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: !hasImage
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.color?.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No image selected',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  )
                : null,
          ),
          const SizedBox(height: 24),
          // Pick image button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.photo_library),
              label: const Text(
                'Choose from Gallery',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onPressed: () => _pickImage(context, ref),
            ),
          ),
          const SizedBox(height: 12),
          if (hasImage)
            TextButton.icon(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Remove Image',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                ref.read(backgroundTypeProvider.notifier).state =
                    BackgroundType.solid;
                ref.read(backgroundImagePathProvider.notifier).state = null;
                Hive.box('app_settings').put('background_type', 'solid');
                Hive.box('app_settings').put('background_image_path', null);
              },
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      ref.read(backgroundTypeProvider.notifier).state = BackgroundType.image;
      ref.read(backgroundImagePathProvider.notifier).state = pickedFile.path;
      Hive.box('app_settings').put('background_type', 'image');
      Hive.box('app_settings').put('background_image_path', pickedFile.path);
    }
  }
}
