import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../utils/app_data.dart';

class ExcelGenerator {
  static Future<void> generate(WidgetRef ref) async {
    final excel = Excel.createExcel();
    final records = ref.read(dailyRecordsProvider);
    final startDate = ref.read(ramadanStartDateProvider);
    final activities = AppData.activities;
    final categories = AppData.categories;

    // ===== Sheet 1: Summary =====
    final Sheet summary = excel['Summary'];
    excel.delete('Sheet1');

    // Header row style
    final headerStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#0D471C'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      bold: true,
      fontSize: 10,
    );

    // Summary headers
    summary.appendRow([
      TextCellValue('Day'),
      TextCellValue('Date'),
      TextCellValue('Completed'),
      TextCellValue('Total'),
      TextCellValue('Progress (%)'),
    ]);

    // Apply header style
    for (int col = 0; col < 5; col++) {
      summary
              .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
              .cellStyle =
          headerStyle;
    }

    for (int i = 0; i < 30; i++) {
      final day = i + 1;
      final record = records[day];
      final completedCount = record?.completedActivityIds.length ?? 0;
      final progress = (completedCount / activities.length * 100)
          .toStringAsFixed(2);

      String dateStr = '-';
      if (startDate != null) {
        final date = startDate.add(Duration(days: i));
        dateStr = DateFormat('yyyy-MM-dd').format(date);
      }

      summary.appendRow([
        IntCellValue(day),
        TextCellValue(dateStr),
        IntCellValue(completedCount),
        IntCellValue(activities.length),
        DoubleCellValue(double.tryParse(progress) ?? 0.0),
      ]);
    }

    // ===== Sheet 2: Detailed Activities =====
    final Sheet detail = excel['Detail Activities'];

    // Build header: Day | Date | Activity 1 | Activity 2 | ... | Activity 47
    final detailHeaders = <CellValue>[
      TextCellValue('Day'),
      TextCellValue('Date'),
      ...activities.map((a) => TextCellValue(a.title)),
    ];
    detail.appendRow(detailHeaders);

    // Apply header style to all columns
    for (int col = 0; col < detailHeaders.length; col++) {
      detail
              .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
              .cellStyle =
          headerStyle;
    }

    // Styles for check marks
    final doneStyle = CellStyle(
      fontColorHex: ExcelColor.fromHexString('#1B5E20'),
      bold: true,
    );
    final notDoneStyle = CellStyle(
      fontColorHex: ExcelColor.fromHexString('#BDBDBD'),
    );

    for (int i = 0; i < 30; i++) {
      final day = i + 1;
      final record = records[day];
      final Set<String> completedIds = (record?.completedActivityIds ?? [])
          .toSet();

      String dateStr = '-';
      if (startDate != null) {
        final date = startDate.add(Duration(days: i));
        dateStr = DateFormat('yyyy-MM-dd').format(date);
      }

      final row = <CellValue>[
        IntCellValue(day),
        TextCellValue(dateStr),
        ...activities.map(
          (a) => TextCellValue(completedIds.contains(a.id) ? '✓' : '—'),
        ),
      ];
      detail.appendRow(row);

      // Apply colored styles to activity cells
      final rowIndex = i + 1;
      for (int col = 2; col < 2 + activities.length; col++) {
        final cell = detail.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex),
        );
        final actIndex = col - 2;
        cell.cellStyle = completedIds.contains(activities[actIndex].id)
            ? doneStyle
            : notDoneStyle;
      }
    }

    // ===== Per-Category Sheets =====
    for (final category in categories) {
      final catActivities = activities
          .where((a) => a.category == category)
          .toList();
      if (catActivities.isEmpty) continue;

      final Sheet catSheet = excel[category];

      // Header
      final catHeaders = <CellValue>[
        TextCellValue('Day'),
        TextCellValue('Date'),
        ...catActivities.map((a) => TextCellValue(a.title)),
        TextCellValue('Completed'),
      ];
      catSheet.appendRow(catHeaders);

      for (int col = 0; col < catHeaders.length; col++) {
        catSheet
                .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
                .cellStyle =
            headerStyle;
      }

      for (int i = 0; i < 30; i++) {
        final day = i + 1;
        final record = records[day];
        final Set<String> completedIds = (record?.completedActivityIds ?? [])
            .toSet();

        String dateStr = '-';
        if (startDate != null) {
          final date = startDate.add(Duration(days: i));
          dateStr = DateFormat('dd/MM').format(date);
        }

        final catCompleted = catActivities
            .where((a) => completedIds.contains(a.id))
            .length;

        catSheet.appendRow([
          IntCellValue(day),
          TextCellValue(dateStr),
          ...catActivities.map(
            (a) => TextCellValue(completedIds.contains(a.id) ? '✓' : '—'),
          ),
          TextCellValue('$catCompleted / ${catActivities.length}'),
        ]);
      }
    }

    // Save and Share
    final fileBytes = excel.save();
    if (fileBytes != null) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/ramadhan_report.xlsx';
      final file = File(path);
      await file.writeAsBytes(fileBytes);

      await Share.shareXFiles([XFile(path)], text: 'My Ramadhan Progress');
    }
  }
}
