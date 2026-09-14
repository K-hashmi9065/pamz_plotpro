import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/services/pdf/project_overview_pdf_service.dart';
import 'package:land_investment_and_sales_management/core/storage/hive_service.dart';
import 'package:land_investment_and_sales_management/features/expenses/domain/expense_model.dart';
import 'package:land_investment_and_sales_management/features/plots/domain/plot_model.dart';
import 'package:land_investment_and_sales_management/features/profit_loss_settlement/domain/profit_loss_models.dart';
import 'package:land_investment_and_sales_management/features/projects/domain/project_model.dart';

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

  group('Project Overview A4 PDF Service Tests', () {
    test('generateProjectOverviewPdf produces non-empty valid byte array', () async {
      final project = ProjectModel(
        id: 'prj-101',
        code: 'PRJ-002',
        name: 'ACB Greens',
        location: 'KNE',
        status: ProjectStatus.active,
        landownerName: 'Saad',
        landAreaSqFt: 27500.0,
        lengthFt: 250,
        lengthIn: 0,
        breadthFt: 110,
        breadthIn: 0,
        purchasePrice: 6000.0,
        actualCost: 6000.0,
        createdAt: DateTime(2026, 1, 1),
      );

      final plots = [
        PlotModel(
          id: 'plot-1',
          projectId: 'prj-101',
          plotNumber: 'P-1',
          areaSqFt: 5500.0,
          allocatedCost: 2000.0,
          expectedPrice: 15000.0,
          status: PlotStatus.sold,
          createdAt: DateTime(2026, 1, 5),
        ),
        PlotModel(
          id: 'road-1',
          projectId: 'prj-101',
          plotNumber: 'Access Road',
          areaSqFt: 2500.0,
          allocatedCost: 0.0,
          expectedPrice: 0.0,
          status: PlotStatus.available,
          createdAt: DateTime(2026, 1, 5),
        ),
      ];

      final expenses = [
        ExpenseModel(
          id: 'exp-1',
          projectId: 'prj-101',
          category: ExpenseCategory.legal,
          amount: 1000.0,
          expenseDate: DateTime(2026, 1, 10),
          isCapitalized: true,
          createdAt: DateTime(2026, 1, 10),
        ),
      ];

      final pnlList = [
        ProjectProfitLossModel(
          projectId: 'prj-101',
          projectName: 'ACB Greens',
          totalAgreedSales: 15000.0,
          directSaleExpenses: 0.0,
          actualProjectCost: 7000.0,
          cashCollected: 6000.0,
        ),
      ];

      final pdfBytes = await ProjectOverviewPdfService.generateProjectOverviewPdf(
        project: project,
        plots: plots,
        expenses: expenses,
        pnlList: pnlList,
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      // PDF standard header check %PDF-
      expect(String.fromCharCodes(pdfBytes.take(4)), equals('%PDF'));
    });

    test('generateProjectOverviewPdf respects custom branding header', () async {
      await HiveService.setPdfHeaderTitle('Wasi Property');

      final project = ProjectModel(
        id: 'prj-102',
        code: 'PRJ-WASI',
        name: 'Wasi Residency',
        location: 'City Center',
        status: ProjectStatus.active,
        landAreaSqFt: 10000.0,
        purchasePrice: 5000000.0,
        actualCost: 5000000.0,
        createdAt: DateTime(2026, 2, 1),
      );

      final pdfBytes = await ProjectOverviewPdfService.generateProjectOverviewPdf(
        project: project,
        plots: const [],
        expenses: const [],
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
    });
  });
}
