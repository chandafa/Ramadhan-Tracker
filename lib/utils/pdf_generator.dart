import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../utils/app_data.dart';

class PdfGenerator {
  static Future<void> generate(WidgetRef ref) async {
    final pdf = pw.Document();
    final records = ref.read(dailyRecordsProvider);
    final startDate = ref.read(ramadanStartDateProvider);
    final activities = AppData.activities;

    // Group activities by category for the summary page
    final categories = AppData.categories;

    // ===== Page 1: Summary Table (Day / Date / Completed / Progress) =====
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Ramadhan Tracker Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(DateFormat('dd MMMM yyyy').format(DateTime.now())),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Daily Summary',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF0D471C),
              ),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                ),
              ),
              oddRowDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFF5F5F5),
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellPadding: const pw.EdgeInsets.all(5),
              cellAlignment: pw.Alignment.centerLeft,
              headers: ['Day', 'Date', 'Completed', 'Progress'],
              data: List<List<dynamic>>.generate(30, (index) {
                final day = index + 1;
                final record = records[day];
                final completedCount = record?.completedActivityIds.length ?? 0;
                final progress = (completedCount / activities.length * 100)
                    .toStringAsFixed(1);

                String dateStr = '-';
                if (startDate != null) {
                  final date = startDate.add(Duration(days: index));
                  dateStr = DateFormat('dd MMM').format(date);
                }

                return [
                  'Day $day',
                  dateStr,
                  '$completedCount / ${activities.length}',
                  '$progress%',
                ];
              }),
            ),
          ];
        },
      ),
    );

    // ===== Page 2+: Detailed Activity Breakdown per Category =====
    for (final category in categories) {
      final categoryActivities = activities
          .where((a) => a.category == category)
          .toList();
      if (categoryActivities.isEmpty) continue;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            // Build header row: Day | Date | activity1 | activity2 | ...
            final headers = [
              'Day',
              'Date',
              ...categoryActivities.map((a) => a.title),
            ];

            // Build data rows
            final data = List<List<dynamic>>.generate(30, (index) {
              final day = index + 1;
              final record = records[day];
              final Set<String> completedIds =
                  (record?.completedActivityIds ?? []).toSet();

              String dateStr = '-';
              if (startDate != null) {
                final date = startDate.add(Duration(days: index));
                dateStr = DateFormat('dd/MM').format(date);
              }

              return [
                '$day',
                dateStr,
                ...categoryActivities.map(
                  (a) => completedIds.contains(a.id)
                      ? pw.Text(
                          'OK', // Using text check due to font limitations, or unicode
                          style: pw.TextStyle(
                            color: PdfColors.green,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        )
                      : pw.Text(
                          '-',
                          style: const pw.TextStyle(color: PdfColors.grey400),
                        ),
                ),
              ];
            });

            return [
              pw.Header(
                level: 1,
                child: pw.Text(
                  category,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 7,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF0D471C),
                ),
                oddRowDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF5F5F5),
                ),
                cellStyle: const pw.TextStyle(fontSize: 7),
                cellPadding: const pw.EdgeInsets.all(3),
                cellAlignment: pw.Alignment.center,
                headerAlignment: pw.Alignment.center,
                headers: headers,
                data: data,
                columnWidths: {
                  0: const pw.FixedColumnWidth(30),
                  1: const pw.FixedColumnWidth(40),
                },
              ),
            ];
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
