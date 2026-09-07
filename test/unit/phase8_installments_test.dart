import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/database/app_database.dart';
import 'package:land_investment_and_sales_management/features/installments_payments/data/installments_repository.dart';
import 'package:land_investment_and_sales_management/features/installments_payments/domain/installment_model.dart';
import 'package:land_investment_and_sales_management/features/installments_payments/domain/transaction_model.dart';

class MockInstallmentsRepository extends Mock implements InstallmentsRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(PaymentMethod.bankTransfer);
    registerFallbackValue(DateTime.now());
  });

  late AppDatabase db;
  late InstallmentsRepository installmentsRepo;
  late MockInstallmentsRepository mockInstallmentsRepo;
  const uuid = Uuid();

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    installmentsRepo = InstallmentsRepository(db);
    mockInstallmentsRepo = MockInstallmentsRepository();

    // Insert a default project to satisfy foreign key constraint during payment recording
    await db.into(db.projects).insert(
          ProjectsCompanion(
            id: const drift.Value('proj_default'),
            code: const drift.Value('PRJ-000'),
            name: const drift.Value('Default Test Project'),
            location: const drift.Value('Test Location'),
            status: drift.Value(ProjectStatus.active.name),
            landAreaSqFt: const drift.Value(10000.0),
            createdAt: drift.Value(DateTime.now()),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 8 - Installments & Payments Unit Tests (Drift Memory Database)', () {
    test('recordPayment updates paidAmount and transitions status (pending -> partial -> paid)', () async {
      final installmentId = uuid.v4();

      // Insert dummy installment of ₹1,00,000
      await db.into(db.installments).insert(
            InstallmentsCompanion(
              id: drift.Value(installmentId),
              saleId: const drift.Value.absent(),
              installmentNumber: const drift.Value(1),
              dueDate: drift.Value(DateTime.now().add(const Duration(days: 30))),
              dueAmount: const drift.Value(100000.0),
              paidAmount: const drift.Value(0.0),
              status: drift.Value(InstallmentStatus.pending.name),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      // 1. Partial payment of ₹40,000
      final tx1 = await installmentsRepo.recordPayment(
        projectId: 'proj_1',
        installmentId: installmentId,
        amount: 40000.0,
        paymentDate: DateTime.now(),
        paymentMethod: PaymentMethod.bankTransfer,
        userId: 'admin_user',
      );

      expect(tx1.amount, equals(40000.0));
      expect(tx1.isVoided, isFalse);

      var inst = await (db.select(db.installments)..where((tbl) => tbl.id.equals(installmentId))).getSingle();
      expect(inst.paidAmount, equals(40000.0));
      expect(inst.status, equals(InstallmentStatus.partiallyPaid.name));

      // 2. Full balance payment of ₹60,000
      await installmentsRepo.recordPayment(
        projectId: 'proj_1',
        installmentId: installmentId,
        amount: 60000.0,
        paymentDate: DateTime.now(),
        paymentMethod: PaymentMethod.cheque,
        userId: 'admin_user',
      );

      inst = await (db.select(db.installments)..where((tbl) => tbl.id.equals(installmentId))).getSingle();
      expect(inst.paidAmount, equals(100000.0));
      expect(inst.status, equals(InstallmentStatus.paid.name));
    });

    test('Section 269ST cash limit (>= ₹2,00,000) generates compliance audit flag', () async {
      final installmentId = uuid.v4();

      await db.into(db.installments).insert(
            InstallmentsCompanion(
              id: drift.Value(installmentId),
              installmentNumber: const drift.Value(1),
              dueDate: drift.Value(DateTime.now()),
              dueAmount: const drift.Value(300000.0),
              paidAmount: const drift.Value(0.0),
              status: drift.Value(InstallmentStatus.pending.name),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      await installmentsRepo.recordPayment(
        projectId: 'proj_cash',
        installmentId: installmentId,
        amount: 250000.0, // Exceeds ₹2,00,000 limit
        paymentDate: DateTime.now(),
        paymentMethod: PaymentMethod.cash,
        userId: 'admin_user',
      );

      final logs = await db.select(db.auditLogs).get();
      expect(logs.isNotEmpty, isTrue);

      final cashLog = logs.firstWhere((l) => l.action == 'RECORD_PAYMENT');
      expect(cashLog.details, contains('Section 269ST Cash limit threshold acknowledged'));
    });

    test('voidTransaction reverses installment paid amount and status', () async {
      final installmentId = uuid.v4();

      await db.into(db.installments).insert(
            InstallmentsCompanion(
              id: drift.Value(installmentId),
              installmentNumber: const drift.Value(1),
              dueDate: drift.Value(DateTime.now()),
              dueAmount: const drift.Value(100000.0),
              paidAmount: const drift.Value(0.0),
              status: drift.Value(InstallmentStatus.pending.name),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      final tx = await installmentsRepo.recordPayment(
        projectId: 'proj_void',
        installmentId: installmentId,
        amount: 100000.0,
        paymentDate: DateTime.now(),
        paymentMethod: PaymentMethod.bankTransfer,
        userId: 'admin_user',
      );

      var inst = await (db.select(db.installments)..where((tbl) => tbl.id.equals(installmentId))).getSingle();
      expect(inst.status, equals(InstallmentStatus.paid.name));

      // Admin voids transaction
      await installmentsRepo.voidTransaction(
        transactionId: tx.id,
        voidReason: 'Cheque bounced by bank',
        userId: 'admin_user',
      );

      final voidedTx = await (db.select(db.transactions)..where((tbl) => tbl.id.equals(tx.id))).getSingle();
      expect(voidedTx.isVoided, isTrue);
      expect(voidedTx.voidReason, equals('Cheque bounced by bank'));

      inst = await (db.select(db.installments)..where((tbl) => tbl.id.equals(installmentId))).getSingle();
      expect(inst.paidAmount, equals(0.0));
      expect(inst.status, equals(InstallmentStatus.pending.name));
    });

    test('voidTransaction throws error on empty reason or duplicate void attempt', () async {
      final installmentId = uuid.v4();

      await db.into(db.installments).insert(
            InstallmentsCompanion(
              id: drift.Value(installmentId),
              installmentNumber: const drift.Value(1),
              dueDate: drift.Value(DateTime.now()),
              dueAmount: const drift.Value(50000.0),
              paidAmount: const drift.Value(0.0),
              status: drift.Value(InstallmentStatus.pending.name),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      final tx = await installmentsRepo.recordPayment(
        projectId: 'proj_err',
        installmentId: installmentId,
        amount: 50000.0,
        paymentDate: DateTime.now(),
        paymentMethod: PaymentMethod.online,
        userId: 'admin_user',
      );

      // Expect ArgumentError on empty void reason
      expect(
        () async => await installmentsRepo.voidTransaction(
          transactionId: tx.id,
          voidReason: '   ',
          userId: 'admin_user',
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Void properly first time
      await installmentsRepo.voidTransaction(
        transactionId: tx.id,
        voidReason: 'Duplicate entry',
        userId: 'admin_user',
      );

      // Expect StateError on second void attempt
      expect(
        () async => await installmentsRepo.voidTransaction(
          transactionId: tx.id,
          voidReason: 'Trying again',
          userId: 'admin_user',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('Mocktail Mock-Driven Tests for InstallmentsRepository', () {
    test('Mocktail: recordPayment returns stubbed TransactionModel', () async {
      final fakeTx = TransactionModel(
        id: 'tx_mock_123',
        projectId: 'proj_default',
        installmentId: 'inst_mock_1',
        amount: 250000.0,
        paymentDate: DateTime.now(),
        paymentMethod: PaymentMethod.cash,
        isVoided: false,
        createdBy: 'admin_user',
        createdAt: DateTime.now(),
      );

      when(() => mockInstallmentsRepo.recordPayment(
            projectId: any(named: 'projectId'),
            installmentId: any(named: 'installmentId'),
            amount: any(named: 'amount'),
            paymentDate: any(named: 'paymentDate'),
            paymentMethod: any(named: 'paymentMethod'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => fakeTx);

      final tx = await mockInstallmentsRepo.recordPayment(
        projectId: 'proj_default',
        installmentId: 'inst_mock_1',
        amount: 250000.0,
        paymentDate: DateTime.now(),
        paymentMethod: PaymentMethod.cash,
        userId: 'admin_user',
      );

      expect(tx.id, equals('tx_mock_123'));
      expect(tx.amount, equals(250000.0));
      expect(tx.paymentMethod, equals(PaymentMethod.cash));

      verify(() => mockInstallmentsRepo.recordPayment(
            projectId: 'proj_default',
            installmentId: 'inst_mock_1',
            amount: 250000.0,
            paymentDate: any(named: 'paymentDate'),
            paymentMethod: PaymentMethod.cash,
            userId: 'admin_user',
          )).called(1);
    });

    test('Mocktail: voidTransaction executes and verifies invocation', () async {
      when(() => mockInstallmentsRepo.voidTransaction(
            transactionId: any(named: 'transactionId'),
            voidReason: any(named: 'voidReason'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async {});

      await mockInstallmentsRepo.voidTransaction(
        transactionId: 'tx_mock_123',
        voidReason: 'Duplicate entry correction',
        userId: 'admin_user',
      );

      verify(() => mockInstallmentsRepo.voidTransaction(
            transactionId: 'tx_mock_123',
            voidReason: 'Duplicate entry correction',
            userId: 'admin_user',
          )).called(1);
    });

    test('Mocktail: watchAllInstallments streams mocked list of InstallmentModels', () {
      final fakeInstallment = InstallmentModel(
        id: 'inst_mock_1',
        installmentNumber: 1,
        dueDate: DateTime.now(),
        dueAmount: 500000.0,
        paidAmount: 250000.0,
        status: InstallmentStatus.partiallyPaid,
        createdAt: DateTime.now(),
      );

      when(() => mockInstallmentsRepo.watchAllInstallments())
          .thenAnswer((_) => Stream.value([fakeInstallment]));

      expect(
        mockInstallmentsRepo.watchAllInstallments(),
        emits(contains(fakeInstallment)),
      );

      verify(() => mockInstallmentsRepo.watchAllInstallments()).called(1);
    });
  });
}
