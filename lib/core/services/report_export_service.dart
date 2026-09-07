import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ReportExportService {
  /// Export any list of headers & rows to a CSV file in the Downloads/Documents folder
  static Future<File> exportToCsv({
    required String reportTitle,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    final buffer = StringBuffer();
    
    // Header title row
    buffer.writeln('# $reportTitle');
    buffer.writeln('# Generated: ${DateTime.now()}');
    buffer.writeln();

    // CSV Headers
    buffer.writeln(headers.map(_escapeCsvCell).join(','));

    // CSV Rows
    for (final row in rows) {
      buffer.writeln(row.map((cell) => _escapeCsvCell(cell?.toString() ?? '')).join(','));
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${reportTitle.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(p.join(dir.path, fileName));

    await file.writeAsString(buffer.toString());
    return file;
  }

  static String _escapeCsvCell(dynamic value) {
    final str = value?.toString() ?? '';
    if (str.contains(',') || str.contains('"') || str.contains('\n')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }
}
