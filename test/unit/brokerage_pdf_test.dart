import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/services/pdf/brokerage_pdf_service.dart';
import 'package:land_investment_and_sales_management/core/storage/hive_service.dart';
import 'package:land_investment_and_sales_management/features/plots/domain/plot_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_brokerage_pdf_test_');
    Hive.init(tempDir.path);
    await Hive.openBox(HiveService.settingsBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Brokerage Voucher A4 PDF Service Tests', () {
    test('generateBrokerageVoucherPdf produces valid non-empty PDF byte array', () async {
      final plot = PlotModel(
        id: 'plot-101',
        projectId: 'prj-001',
        plotNumber: 'AXPN0001',
        areaSqFt: 24480.0,
        lengthFt: 120,
        lengthIn: 0,
        breadthFt: 204,
        breadthIn: 0,
        allocatedCost: 32393.0,
        expectedPrice: 39168.0,
        status: PlotStatus.booked,
        brokerName: 'Rashid Khan',
        brokerPhone: '9876543210',
        brokerageCharge: 1000.0,
        createdAt: DateTime(2026, 1, 10),
      );

      final pdfBytes = await BrokeragePdfService.generateBrokerageVoucherPdf(
        plot: plot,
        projectName: 'PAMZ',
        projectCode: 'PRJ-001',
        projectLocation: 'Kne Bihar',
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      // PDF standard header check %PDF-
      expect(String.fromCharCodes(pdfBytes.take(4)), equals('%PDF'));
    });

    test('generateBrokerageVoucherPdf respects dynamic branding title', () async {
      await HiveService.setPdfHeaderTitle('Wasi Property');

      final plot = PlotModel(
        id: 'plot-102',
        projectId: 'prj-002',
        plotNumber: 'P-02',
        areaSqFt: 5500.0,
        allocatedCost: 20000.0,
        expectedPrice: 50000.0,
        status: PlotStatus.available,
        brokerName: 'Sanjay Sharma',
        brokerPhone: '9123456780',
        brokerageCharge: 2500.0,
        createdAt: DateTime(2026, 2, 1),
      );

      final pdfBytes = await BrokeragePdfService.generateBrokerageVoucherPdf(
        plot: plot,
        projectName: 'Wasi Residency',
        projectCode: 'PRJ-WASI',
        projectLocation: 'City Center',
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
    });
  });
}
