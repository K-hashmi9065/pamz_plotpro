import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:land_investment_and_sales_management/core/storage/hive_service.dart';
import 'package:land_investment_and_sales_management/features/settings/presentation/settings_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_pdf_test_');
    Hive.init(tempDir.path);
    await Hive.openBox(HiveService.settingsBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('PDF Header Settings Unit Tests', () {
    test('Default PDF Header is PAMZ PlotPro when unset', () {
      final header = HiveService.getPdfHeaderTitle();
      expect(header, equals('PAMZ PlotPro'));
    });

    test('Updating PDF Header persists and retrieves custom name', () async {
      await HiveService.setPdfHeaderTitle('Wasi Property');
      final header = HiveService.getPdfHeaderTitle();
      expect(header, equals('Wasi Property'));
    });

    test('Empty or whitespace header falls back to default', () async {
      await HiveService.setPdfHeaderTitle('   ');
      final header = HiveService.getPdfHeaderTitle();
      expect(header, equals('PAMZ PlotPro'));
    });

    test('PdfHeaderNotifier updates and resets to default correctly', () async {
      final notifier = PdfHeaderNotifier();
      expect(notifier.state, equals('PAMZ PlotPro'));

      await notifier.updateHeaderTitle('Wasi Property');
      expect(notifier.state, equals('Wasi Property'));
      expect(HiveService.getPdfHeaderTitle(), equals('Wasi Property'));

      await notifier.resetToDefault();
      expect(notifier.state, equals('PAMZ PlotPro'));
      expect(HiveService.getPdfHeaderTitle(), equals('PAMZ PlotPro'));
    });
  });
}
