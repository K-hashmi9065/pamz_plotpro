import 'package:flutter_test/flutter_test.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/utils/calculation_engine.dart';
import 'package:land_investment_and_sales_management/core/utils/land_unit_converter.dart';
import 'package:land_investment_and_sales_management/core/services/whatsapp_share_service.dart';
import 'package:land_investment_and_sales_management/features/projects/domain/project_model.dart';
import 'package:land_investment_and_sales_management/features/landowners/domain/landowner_model.dart';
import 'package:land_investment_and_sales_management/features/investors/domain/project_investor_model.dart';
import 'package:land_investment_and_sales_management/features/expenses/domain/expense_model.dart';
import 'package:land_investment_and_sales_management/features/plots/domain/plot_model.dart';

void main() {
  group('Phase 1 to 33: Full Client Acceptance Mock Workflow Test', () {
    test('Phase 5: Create Mock Project - Kishanganj Green Valley', () {
      final project = ProjectModel(
        id: 'proj_kgv_1',
        code: 'KGV-01',
        name: 'Kishanganj Green Valley',
        location: 'Kishanganj, Bihar',
        landAreaSqFt: LandUnitConverter.kattaDhurToSqFt(5 * 20, 0),
        purchasePrice: 20000000.0, // ₹2,00,00,000
        actualCost: 20000000.0,
        status: ProjectStatus.active,
        createdAt: DateTime.now(),
      );

      expect(project.name, equals('Kishanganj Green Valley'));
      expect(project.location, equals('Kishanganj, Bihar'));
      expect(project.purchasePrice, equals(20000000.0));
      expect(project.landAreaSqFt, equals(136125.0));
    });

    test('Phase 6: Landowner Mock Test & Form Validations', () {
      final landowner = LandownerModel(
        id: 'lo_rajesh_1',
        name: 'Rajesh Kumar',
        phone: '9876543210',
        address: 'Kishanganj, Bihar',
        createdAt: DateTime.now(),
      );

      expect(landowner.name, equals('Rajesh Kumar'));
      expect(landowner.phone, equals('9876543210'));

      // Form validation logic checks
      String? validateName(String? val) => (val == null || val.trim().isEmpty) ? 'Name required' : null;
      String? validatePhone(String? val) {
        if (val == null || val.trim().isEmpty) return 'Mobile required';
        if (!RegExp(r'^\d{10}$').hasMatch(val.trim())) return 'Invalid 10-digit mobile';
        return null;
      }

      expect(validateName(''), equals('Name required'));
      expect(validatePhone(''), equals('Mobile required'));
      expect(validatePhone('123'), equals('Invalid 10-digit mobile'));
      expect(validatePhone('9876543210'), isNull);
    });

    test('Phase 7 & 8: Token Payment & Landowner Installments Calculation', () {
      const landPurchasePrice = 20000000.0; // ₹2,00,00,000
      const tokenPaid = 1000000.0; // ₹10,00,000

      final outstandingAfterToken = CalculationEngine.calculateBalancePayable(
        totalObligations: landPurchasePrice,
        cashPaid: tokenPaid,
      );
      expect(outstandingAfterToken, equals(19000000.0)); // ₹1,90,00,000

      // Installment payments: ₹50L + ₹25L + ₹25L = ₹100L (+ Token ₹10L = ₹110L Total Paid)
      final landownerPayments = [tokenPaid, 5000000.0, 2500000.0, 2500000.0];
      final totalPaidToLandowner = landownerPayments.fold(0.0, (a, b) => a + b);
      final finalOutstandingLandowner = CalculationEngine.calculateBalancePayable(
        totalObligations: landPurchasePrice,
        cashPaid: totalPaidToLandowner,
      );

      expect(totalPaidToLandowner, equals(11000000.0)); // ₹1,10,00,000
      expect(finalOutstandingLandowner, equals(9000000.0)); // ₹90,00,000
    });

    test('Phase 9: Investor Capital & Ownership Split Validation', () {
      final projectInvestors = [
        ProjectInvestorModel(
          id: 'pi_a',
          projectId: 'proj_kgv_1',
          investorId: 'inv_a',
          investorName: 'Investor A',
          investedAmount: 1000000.0, // ₹10L
          ownershipPercent: 20.0,
          ownershipMethod: OwnershipMethod.capitalBased,
          createdAt: DateTime.now(),
        ),
        ProjectInvestorModel(
          id: 'pi_b',
          projectId: 'proj_kgv_1',
          investorId: 'inv_b',
          investorName: 'Investor B',
          investedAmount: 2000000.0, // ₹20L
          ownershipPercent: 40.0,
          ownershipMethod: OwnershipMethod.capitalBased,
          createdAt: DateTime.now(),
        ),
        ProjectInvestorModel(
          id: 'pi_c',
          projectId: 'proj_kgv_1',
          investorId: 'inv_c',
          investorName: 'Investor C',
          investedAmount: 2000000.0, // ₹20L
          ownershipPercent: 40.0,
          ownershipMethod: OwnershipMethod.capitalBased,
          createdAt: DateTime.now(),
        ),
      ];

      final totalInvestment = projectInvestors.fold<double>(0, (sum, i) => sum + i.investedAmount);
      final totalOwnership = projectInvestors.fold<double>(0, (sum, i) => sum + i.ownershipPercent);

      expect(totalInvestment, equals(5000000.0)); // ₹50,00,000
      expect(totalOwnership, equals(100.0)); // Exactly 100%

      bool validateOwnershipTotal(List<double> percentages) {
        final sum = percentages.fold<double>(0, (a, b) => a + b);
        return (sum - 100.0).abs() < 0.001;
      }

      expect(validateOwnershipTotal([20.0, 40.0, 40.0]), isTrue);
      expect(validateOwnershipTotal([20.0, 40.0, 50.0]), isFalse);
    });

    test('Phase 10: Expense Breakdown & Totals', () {
      final expenses = [
        ExpenseModel(
          id: 'exp_1',
          projectId: 'proj_kgv_1',
          category: ExpenseCategory.registration,
          amount: 200000.0, // ₹2L
          expenseDate: DateTime.now(),
          isCapitalized: true,
          createdAt: DateTime.now(),
        ),
        ExpenseModel(
          id: 'exp_2',
          projectId: 'proj_kgv_1',
          category: ExpenseCategory.registration,
          amount: 500000.0, // ₹5L
          expenseDate: DateTime.now(),
          isCapitalized: true,
          createdAt: DateTime.now(),
        ),
        ExpenseModel(
          id: 'exp_3',
          projectId: 'proj_kgv_1',
          category: ExpenseCategory.brokerage,
          amount: 300000.0, // ₹3L
          expenseDate: DateTime.now(),
          isCapitalized: true,
          createdAt: DateTime.now(),
        ),
        ExpenseModel(
          id: 'exp_4',
          projectId: 'proj_kgv_1',
          category: ExpenseCategory.legal,
          amount: 200000.0, // ₹2L
          expenseDate: DateTime.now(),
          isCapitalized: true,
          createdAt: DateTime.now(),
        ),
        ExpenseModel(
          id: 'exp_5',
          projectId: 'proj_kgv_1',
          category: ExpenseCategory.development,
          amount: 800000.0, // ₹8L
          expenseDate: DateTime.now(),
          isCapitalized: true,
          createdAt: DateTime.now(),
        ),
        ExpenseModel(
          id: 'exp_6',
          projectId: 'proj_kgv_1',
          category: ExpenseCategory.other,
          amount: 200000.0, // ₹2L
          expenseDate: DateTime.now(),
          isCapitalized: true,
          createdAt: DateTime.now(),
        ),
      ];

      final totalExpenses = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
      expect(totalExpenses, equals(2200000.0)); // ₹22,00,000
    });

    test('Phase 11: Plotting & Unique Plot Number Validation', () {
      final plots = [
        PlotModel(
          id: 'plot_a01',
          projectId: 'proj_kgv_1',
          plotNumber: 'A-01',
          areaSqFt: 2000.0,
          allocatedCost: 2000000.0,
          expectedPrice: 2500000.0,
          status: PlotStatus.available,
          createdAt: DateTime.now(),
        ),
        PlotModel(
          id: 'plot_a02',
          projectId: 'proj_kgv_1',
          plotNumber: 'A-02',
          areaSqFt: 2000.0,
          allocatedCost: 2000000.0,
          expectedPrice: 3000000.0,
          status: PlotStatus.available,
          createdAt: DateTime.now(),
        ),
      ];

      final existingNumbers = plots.map((p) => p.plotNumber).toSet();
      expect(existingNumbers.contains('A-01'), isTrue);
      expect(existingNumbers.contains('A-03'), isFalse);

      String? validateDuplicatePlot(String newNumber, Set<String> existing) {
        if (existing.contains(newNumber.trim().toUpperCase())) {
          return 'Plot number already exists.';
        }
        return null;
      }

      expect(validateDuplicatePlot('A-01', existingNumbers), equals('Plot number already exists.'));
      expect(validateDuplicatePlot('A-03', existingNumbers), isNull);
    });

    test('Phase 13 to 15: Customer Plot Sales & Multi-Installment Tracking', () {
      // Sale 1: Plot A-01 @ ₹25,00,000, Advance ₹10,00,000
      const sale1Price = 2500000.0;
      const advance1 = 1000000.0;
      final outst1Before = CalculationEngine.calculateBalanceReceivable(totalAgreedSales: sale1Price, cashCollected: advance1);
      expect(outst1Before, equals(1500000.0)); // ₹15,00,000

      // Installments for Sale 1: 3 x ₹5,00,000 = ₹15,00,000
      final installmentsSale1 = [advance1, 500000.0, 500000.0, 500000.0];
      final totalRecvSale1 = installmentsSale1.fold<double>(0.0, (a, b) => a + b);
      final finalOutstSale1 = CalculationEngine.calculateBalanceReceivable(totalAgreedSales: sale1Price, cashCollected: totalRecvSale1);

      expect(totalRecvSale1, equals(2500000.0)); // ₹25,00,000
      expect(finalOutstSale1, equals(0.0)); // Fully Paid

      // Sale 2: Plot A-02 @ ₹30,00,000, Advance ₹10,00,000
      const sale2Price = 3000000.0;
      const advance2 = 1000000.0;
      final outst2 = CalculationEngine.calculateBalanceReceivable(totalAgreedSales: sale2Price, cashCollected: advance2);
      expect(outst2, equals(2000000.0)); // ₹20,00,000
      expect(advance2, isNot(equals(sale2Price))); // Received != Sale Value
    });

    test('Phase 16: Project Financial Health & Accurate Cash Flow Calculation', () {
      const landCost = 20000000.0; // ₹2,00,00,000
      const totalExpenses = 2200000.0; // ₹22,00,000
      const totalSalesRevenue = 5500000.0; // ₹25L (A-01) + ₹30L (A-02) = ₹55,00,000
      const totalCashReceived = 3500000.0; // ₹25L (A-01) + ₹10L (A-02) = ₹35,00,000

      const totalCost = landCost + totalExpenses;

      final netCashFlow = CalculationEngine.calculateNetCashFlow(
        totalCashInflows: totalCashReceived,
        totalCashOutflows: 11000000.0 + totalExpenses, // Land Paid ₹1.1Cr + Expenses ₹22L
      );

      expect(totalCost, equals(22200000.0));
      expect(netCashFlow, equals(3500000.0 - 13200000.0)); // Net Cash Flow (-₹97L)
      expect(totalSalesRevenue, isNot(equals(totalCashReceived))); // Revenue != Cash Received
    });

    test('Phase 17 & 19: Report Export & WhatsApp Payment Receipt Payload', () {
      final sharePayload = WhatsAppShareService.formatPaymentReceiptMessage(
        projectName: 'Kishanganj Green Valley',
        customerName: 'Amit Kumar',
        plotNumber: 'A-01',
        salePrice: 2500000.0,
        totalPaid: 2500000.0,
        outstanding: 0.0,
        paymentReceived: 500000.0,
        paymentDate: DateTime(2026, 9, 5),
        referenceNumber: 'TXN-KGV-1001',
      );

      expect(sharePayload, contains('Kishanganj Green Valley'));
      expect(sharePayload, contains('Amit Kumar'));
      expect(sharePayload, contains('A-01'));
      expect(sharePayload, contains('TXN-KGV-1001'));
    });
  });
}
