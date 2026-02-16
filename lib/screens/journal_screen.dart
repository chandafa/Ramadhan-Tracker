import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_providers.dart';
import '../utils/app_strings.dart';
import '../widgets/day_selector.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _currentMood;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(selectedDayProvider);
    final record = ref.watch(dailyRecordProvider(selectedDay));
    final locale = ref.watch(localeProvider);

    // Sync state with record if day changes
    ref.listen(dailyRecordProvider(selectedDay), (previous, next) {
      if (next != null) {
        if (_controller.text != next.note) {
          _controller.text = next.note ?? '';
        }
        if (_currentMood != next.mood) {
          // setState not strictly needed if we pass record.mood directly to editor
          // but we want to track local changes?
          // Actually, easier to just read from record unless editing.
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(AppStrings.journal, locale)),
        actions: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedFloppyDisk,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              final notifier = ref.read(dailyRecordsProvider.notifier);
              notifier.saveNote(selectedDay, _controller.text);
              if (_currentMood != null) {
                notifier.saveMood(selectedDay, _currentMood!);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppStrings.get(AppStrings.journalSaved, locale),
                  ),
                ),
              );
              FocusScope.of(context).unfocus();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.only(bottom: 16),
                  child: const DaySelector(),
                )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideX(begin: 0.1, end: 0, curve: Curves.easeOut),
            Expanded(
              child:
                  Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _JournalEditor(
                          day: selectedDay,
                          initialContent: record?.note ?? '',
                          initialMood: record?.mood,
                          controller: _controller,
                          locale: locale,
                          onMoodChanged: (mood) {
                            _currentMood = mood;
                          },
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 500.ms)
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalEditor extends StatefulWidget {
  final int day;
  final String initialContent;
  final String? initialMood;
  final TextEditingController controller;
  final Locale locale;
  final Function(String) onMoodChanged;

  const _JournalEditor({
    Key? key,
    required this.day,
    required this.initialContent,
    this.initialMood,
    required this.controller,
    required this.locale,
    required this.onMoodChanged,
  }) : super(key: key);

  @override
  State<_JournalEditor> createState() => _JournalEditorState();
}

class _JournalEditorState extends State<_JournalEditor> {
  String? selectedMood;

  @override
  void initState() {
    super.initState();
    widget.controller.text = widget.initialContent;
    selectedMood = widget.initialMood;
  }

  @override
  void didUpdateWidget(covariant _JournalEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.day != widget.day) {
      widget.controller.text = widget.initialContent;
      setState(() {
        selectedMood = widget.initialMood;
      });
      // Also notify parent implicitly? No need.
    }
  }

  void _handleMoodTap(String mood) {
    setState(() {
      selectedMood = mood;
    });
    widget.onMoodChanged(mood);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppStrings.get(AppStrings.day, widget.locale)} ${widget.day} ${AppStrings.get(AppStrings.dayReflections, widget.locale)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          // Mood Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _MoodItem(
                  emoji: '😊',
                  label: 'Happy',
                  selected: selectedMood == 'Happy',
                  onTap: () => _handleMoodTap('Happy'),
                ),
                _MoodItem(
                  emoji: '😐',
                  label: 'Neutral',
                  selected: selectedMood == 'Neutral',
                  onTap: () => _handleMoodTap('Neutral'),
                ),
                _MoodItem(
                  emoji: '😔',
                  label: 'Sad',
                  selected: selectedMood == 'Sad',
                  onTap: () => _handleMoodTap('Sad'),
                ),
                _MoodItem(
                  emoji: '😇',
                  label: 'Blessed',
                  selected: selectedMood == 'Blessed',
                  onTap: () => _handleMoodTap('Blessed'),
                ),
                _MoodItem(
                  emoji: '😴',
                  label: 'Tired',
                  selected: selectedMood == 'Tired',
                  onTap: () => _handleMoodTap('Tired'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: widget.controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: AppStrings.get(AppStrings.journalHint, widget.locale),
                border: InputBorder.none,
                hintStyle: TextStyle(color: Theme.of(context).disabledColor),
              ),
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodItem extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MoodItem({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
