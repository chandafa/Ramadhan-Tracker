import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Added
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_providers.dart';
// import '../models/activity_model.dart'; // Removed unused
import '../services/quote_service.dart';
import '../widgets/shareable_stat_widget.dart';
import '../utils/pdf_generator.dart';
import '../utils/excel_generator.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startDate = ref.watch(ramadanStartDateProvider);
    final records = ref.watch(dailyRecordsProvider);
    final currentStreak = ref.watch(streakProvider);
    final allActivities = ref.watch(activitiesProvider); // Fetch all activities

    // Calculate Stats
    int totalQuran = 0;
    int totalSedekah = 0;
    int totalSunnah = 0;

    // Category Stats for Pie Chart
    final Map<String, int> categoryCounts = {};
    int totalActivitiesCompleted = 0;

    // Map ID to Category for O(1) lookup
    final activityMap = {for (var a in allActivities) a.id: a.category};

    // Sunnah Prayer IDs
    final sunnahIds = {'3', '11', '18', '20', '23', '25', '26', '41'};
    // Sedekah IDs
    final sedekahIds = {'15', '29'};

    for (var record in records.values) {
      final completed = record.completedActivityIds;

      for (var id in completed) {
        totalActivitiesCompleted++;

        // Pie Chart Calculation
        final category = activityMap[id] ?? 'Other';
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;

        if (id == '14') totalQuran++;
        if (sedekahIds.contains(id)) totalSedekah++;
        if (sunnahIds.contains(id)) totalSunnah++;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: startDate == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Please set Ramadan Start Date in Settings'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(navIndexProvider.notifier).state = 4;
                    },
                    child: const Text('Go to Settings'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Grid
                  Text(
                    'Overall Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    childAspectRatio: 1.5,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _StatCard(
                        title: "Qur'an Sessions",
                        value: totalQuran.toString(),
                        icon: Icons.menu_book_rounded,
                        color: Colors.blue,
                      ),
                      _StatCard(
                        title: "Sedekah",
                        value: totalSedekah.toString(),
                        icon: Icons.monetization_on_rounded,
                        color: Colors.green,
                      ),
                      _StatCard(
                        title: "Sunnah Prayers",
                        value: totalSunnah.toString(),
                        icon: Icons.mosque_rounded,
                        color: Colors.purple,
                      ),
                      _StatCard(
                        title: "Current Streak",
                        value: "$currentStreak Days",
                        icon: Icons.whatshot_rounded,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Pie Chart Section
                  if (totalActivitiesCompleted > 0) ...[
                    Text(
                      'Activity Distribution',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: categoryCounts.entries.map((entry) {
                                  final percentage =
                                      (entry.value / totalActivitiesCompleted) *
                                      100;
                                  final color = _getCategoryColor(entry.key);

                                  return PieChartSectionData(
                                    color: color,
                                    value: entry.value.toDouble(),
                                    title: '${percentage.toStringAsFixed(0)}%',
                                    radius: 50,
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: categoryCounts.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(entry.key),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${entry.key} (${entry.value})',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  Text(
                    'Activity Heatmap',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
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
                      children: [
                        HeatMap(
                          datasets: {
                            for (var record in records.values)
                              DateTime(
                                    startDate.year,
                                    startDate.month,
                                    startDate.day,
                                  ).add(Duration(days: record.day - 1)):
                                  record.completedActivityIds.length,
                          },
                          colorMode: ColorMode.color,
                          startDate: startDate.subtract(
                            const Duration(days: 1),
                          ),
                          endDate: startDate.add(const Duration(days: 35)),
                          showText: true,
                          scrollable: true,
                          textColor: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color,
                          defaultColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF2D2D2D)
                              : const Color(0xFFEBEDF0),
                          colorsets: const {
                            1: Color(0xFF9BE9A8),
                            5: Color(0xFF40C463),
                            15: Color(0xFF30A14E),
                            25: Color(0xFF216E39),
                            40: Color(0xFF0D471C),
                          },
                          size: 20,
                          fontSize: 10,
                          onClick: (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '$value / 47 activities completed',
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        // Legend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Less ',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              ),
                            ),
                            ...[
                              Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF2D2D2D)
                                  : const Color(0xFFEBEDF0),
                              const Color(0xFF9BE9A8),
                              const Color(0xFF40C463),
                              const Color(0xFF30A14E),
                              const Color(0xFF216E39),
                            ].map(
                              (color) => Container(
                                width: 14,
                                height: 14,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                            Text(
                              ' More',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Export Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await PdfGenerator.generate(ref);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('PDF Generated!')),
                              );
                            }
                          },
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Export PDF'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await ExcelGenerator.generate(ref);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Excel Generated!'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.table_chart),
                          label: const Text('Export Excel'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _shareStats(context, ref),
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Share to Instagram/WA'),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  Future<void> _shareStats(BuildContext context, WidgetRef ref) async {
    // Logic to capture and share
    final screenshotController = ScreenshotController();
    final day = ref.read(selectedDayProvider);
    final streak = ref.read(streakProvider);
    final dailyProgress = ref.read(dailyProgressProvider(day));
    final quote = ref.read(quoteServiceProvider).getQuote(day);

    // Create a hidden widget to capture
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    try {
      final image = await screenshotController.captureFromWidget(
        ShareableStatWidget(
          day: day,
          progress: (dailyProgress * 100).toInt(),
          quote: quote,
          streak: streak,
        ),
        delay: const Duration(milliseconds: 100),
        pixelRatio: pixelRatio,
        context: context,
      );

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File(
        '${directory.path}/share_stats.png',
      ).create();
      await imagePath.writeAsBytes(image);

      await Share.shareXFiles([
        XFile(imagePath.path),
      ], text: 'My Ramadhan Check-in! #RamadhanTracker');
    } catch (e) {
      debugPrint('Error sharing: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Last Third of the Night':
        return Colors.indigo;
      case 'Fajr':
        return Colors.blue;
      case 'Dhuha':
        return Colors.orange;
      case 'Dhuhr':
        return Colors.yellow[700]!;
      case 'Asr':
        return Colors.amber;
      case 'Iftar':
        return Colors.deepOrange;
      case 'Maghrib':
        return Colors.purple;
      case 'Isha':
        return Colors.deepPurple;
      case 'Before Sleep':
        return Colors.blueGrey;
      default:
        // Generate random or hashed color for custom categories
        return Colors.primaries[category.hashCode % Colors.primaries.length];
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
