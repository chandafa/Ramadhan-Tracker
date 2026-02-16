import 'package:flutter/material.dart';

/// Full-screen dialog shown when user taps on the Sahur notification.
/// Shows a checklist of pre-sahur tasks with a celebration button.
class SahurChecklistScreen extends StatefulWidget {
  const SahurChecklistScreen({super.key});

  @override
  State<SahurChecklistScreen> createState() => _SahurChecklistScreenState();
}

class _SahurChecklistScreenState extends State<SahurChecklistScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _items = [
    {'label': 'Sudah Makan 🍚', 'checked': false},
    {'label': 'Sudah Minum 💧', 'checked': false},
    {'label': 'Niat Puasa 🤲', 'checked': false},
  ];

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  int get _completedCount => _items.where((i) => i['checked'] == true).length;
  bool get _allCompleted => _completedCount == _items.length;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleItem(int index) {
    setState(() {
      _items[index]['checked'] = !_items[index]['checked'];
    });
    if (_allCompleted) {
      _animController.forward().then((_) => _animController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A1F0D)
          : const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Sahur Checklist'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Icon(Icons.nights_stay_rounded, size: 64, color: primaryColor),
              const SizedBox(height: 16),
              Text(
                'Persiapan Sahur',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pastikan semua sudah siap sebelum imsak!',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Progress indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: CircularProgressIndicator(
                            value: _completedCount / _items.length,
                            strokeWidth: 6,
                            backgroundColor: primaryColor.withValues(
                              alpha: 0.15,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryColor,
                            ),
                          ),
                        ),
                        Text(
                          '$_completedCount/${_items.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Text(
                      _allCompleted ? 'Siap puasa! ✨' : 'Sedang persiapan...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Checklist items
              ...List.generate(_items.length, (index) {
                final item = _items[index];
                final isChecked = item['checked'] as bool;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isChecked
                        ? primaryColor.withValues(alpha: 0.12)
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isChecked ? primaryColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isChecked ? primaryColor : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isChecked
                              ? primaryColor
                              : (isDark
                                    ? Colors.grey[600]!
                                    : Colors.grey[400]!),
                          width: 2,
                        ),
                      ),
                      child: isChecked
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                    title: Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : null,
                        color: isChecked
                            ? (isDark ? Colors.grey[400] : Colors.grey[500])
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    onTap: () => _toggleItem(index),
                  ),
                );
              }),

              const Spacer(),

              // Action button
              ScaleTransition(
                scale: _scaleAnimation,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _allCompleted
                          ? primaryColor
                          : Colors.grey[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: _allCompleted ? 6 : 0,
                    ),
                    onPressed: _allCompleted
                        ? () => Navigator.of(context).pop()
                        : null,
                    child: Text(
                      _allCompleted
                          ? 'Bismillah, Siap Puasa! 🌙'
                          : 'Lengkapi checklist...',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
