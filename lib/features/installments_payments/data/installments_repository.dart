import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../domain/installment_model.dart';
import '../domain/transaction_model.dart';

class InstallmentsRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  InstallmentsRepository(this._db);

  TransactionModel _toTransactionModel(Transaction row) {
    final methodEnum = PaymentMethod.values.firstWhere(
      (m) => m.name == row.paymentMethod,
      orElse: () => PaymentMethod.bankTransfer,
    );

    return TransactionModel(
      id: row.id,
      projectId: row.projectId,
      installmentId: row.installmentId,
      amount: row.amount,
      paymentDate: row.paymentDate,
      paymentMethod: methodEnum,
      referenceNumber: row.referenceNumber,
      receiptPath: row.receiptPath,
      isVoided: row.isVoided,
      voidReason: row.voidReason,
      createdBy: row.createdBy,
      createdAt: row.createdAt,
    );
  }

  /// Watch stream of all installments joined with Sale, Buyer, Landowner, and Project details
  Stream<List<InstallmentModel>> watchAllInstallments() {
    final query = _db.select(_db.installments).join([
      leftOuterJoin(
        _db.sales,
        _db.sales.id.equalsExp(_db.installments.saleId),
      ),
      leftOuterJoin(
        _db.buyers,
        _db.buyers.id.equalsExp(_db.sales.buyerId),
      ),
      leftOuterJoin(
        _db.purchaseAgreements,
        _db.purchaseAgreements.id.equalsExp(_db.installments.purchaseAgreementId),
      ),
      leftOuterJoin(
        _db.landowners,
        _db.landowners.id.equalsExp(_db.purchaseAgreements.landownerId),
      ),
      leftOuterJoin(
        _db.projects,
        _db.projects.id.equalsExp(_db.sales.projectId) |
            _db.projects.id.equalsExp(_db.purchaseAgreements.projectId),
      ),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final inst = row.readTable(_db.installments);
        final sale = row.readTableOrNull(_db.sales);
        final buyer = row.readTableOrNull(_db.buyers);
        final pa = row.readTableOrNull(_db.purchaseAgreements);
        final lo = row.readTableOrNull(_db.landowners);
        final project = row.readTableOrNull(_db.projects);

        final statusEnum = InstallmentStatus.values.firstWhere(
          (s) => s.name == inst.status,
          orElse: () => InstallmentStatus.pending,
        );

        String? buyerName = buyer?.name ?? (lo != null ? '${lo.name} (Landowner)' : null);
        String? projectName = project != null ? '${project.name} (${project.code})' : null;
        String? plotInfo;
        if (sale != null) {
          switch (sale.saleType) {
            case 'plotWise':
            case 'plotSale':
              plotInfo = 'Plot Sale';
              break;
            case 'wholeLand':
              plotInfo = 'Whole Land';
              break;
            case 'multiplePlots':
              plotInfo = 'Multiple Plots';
              break;
            case 'mixed':
              plotInfo = 'Mixed Parcel';
              break;
            default:
              plotInfo = sale.saleType;
          }
        } else if (pa != null) {
          plotInfo = 'Land Purchase';
        }

        return InstallmentModel(
          id: inst.id,
          saleId: inst.saleId,
          purchaseAgreementId: inst.purchaseAgreementId,
          installmentNumber: inst.installmentNumber,
          dueDate: inst.dueDate,
          dueAmount: inst.dueAmount,
          paidAmount: inst.paidAmount,
          status: statusEnum,
          createdAt: inst.createdAt,
          buyerName: buyerName,
          projectName: projectName,
          plotInfo: plotInfo,
        );
      }).toList();
    });
  }

  /// Watch installments for a sale joined with details
  Stream<List<InstallmentModel>> watchInstallmentsForSale(String saleId) {
    final query = _db.select(_db.installments).join([
      leftOuterJoin(_db.sales, _db.sales.id.equalsExp(_db.installments.saleId)),
      leftOuterJoin(_db.buyers, _db.buyers.id.equalsExp(_db.sales.buyerId)),
      leftOuterJoin(_db.projects, _db.projects.id.equalsExp(_db.sales.projectId)),
    ])..where(_db.installments.saleId.equals(saleId));

    return query.watch().map((rows) {
      return rows.map((row) {
        final inst = row.readTable(_db.installments);
        final sale = row.readTableOrNull(_db.sales);
        final buyer = row.readTableOrNull(_db.buyers);
        final project = row.readTableOrNull(_db.projects);

        final statusEnum = InstallmentStatus.values.firstWhere(
          (s) => s.name == inst.status,
          orElse: () => InstallmentStatus.pending,
        );

        return InstallmentModel(
          id: inst.id,
          saleId: inst.saleId,
          purchaseAgreementId: inst.purchaseAgreementId,
          installmentNumber: inst.installmentNumber,
          dueDate: inst.dueDate,
          dueAmount: inst.dueAmount,
          paidAmount: inst.paidAmount,
          status: statusEnum,
          createdAt: inst.createdAt,
          buyerName: buyer?.name,
          projectName: project != null ? '${project.name} (${project.code})' : null,
          plotInfo: sale?.saleType,
        );
      }).toList();
    });
  }

  /// Watch all transactions joined with Project and Buyer details
  Stream<List<TransactionModel>> watchAllTransactions() {
    final query = _db.select(_db.transactions).join([
      leftOuterJoin(_db.projects, _db.projects.id.equalsExp(_db.transactions.projectId)),
      leftOuterJoin(_db.installments, _db.installments.id.equalsExp(_db.transactions.installmentId)),
      leftOuterJoin(_db.sales, _db.sales.id.equalsExp(_db.installments.saleId)),
      leftOuterJoin(_db.buyers, _db.buyers.id.equalsExp(_db.sales.buyerId)),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final tx = row.readTable(_db.transactions);
        final project = row.readTableOrNull(_db.projects);
        final buyer = row.readTableOrNull(_db.buyers);

        final methodEnum = PaymentMethod.values.firstWhere(
          (m) => m.name == tx.paymentMethod,
          orElse: () => PaymentMethod.bankTransfer,
        );

        return TransactionModel(
          id: tx.id,
          projectId: tx.projectId,
          installmentId: tx.installmentId,
          amount: tx.amount,
          paymentDate: tx.paymentDate,
          paymentMethod: methodEnum,
          referenceNumber: tx.referenceNumber,
          receiptPath: tx.receiptPath,
          isVoided: tx.isVoided,
          voidReason: tx.voidReason,
          createdBy: tx.createdBy,
          createdAt: tx.createdAt,
          buyerName: buyer?.name,
          projectName: project != null ? '${project.name} (${project.code})' : null,
        );
      }).toList();
    });
  }

  /// Record payment against installment or project directly (AC-02.1 / AC-02.3)
  Future<TransactionModel> recordPayment({
    required String projectId,
    String? installmentId,
    required double amount,
    required DateTime paymentDate,
    required PaymentMethod paymentMethod,
    String? referenceNumber,
    String? receiptPath,
    required String userId,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Payment Amount * must be greater than zero.');
    }

    Installment? installment;
    if (installmentId != null && installmentId.isNotEmpty) {
      installment = await (_db.select(_db.installments)
            ..where((tbl) => tbl.id.equals(installmentId)))
          .getSingleOrNull();

      if (installment == null) {
        throw ArgumentError('Installment record not found.');
      }
    }

    final transactionId = _uuid.v4();

    // Resolve valid project ID from installment context (Sale or Purchase Agreement)
    String resolvedProjectId = projectId;
    if (installment != null) {
      final targetInst = installment;
      if (targetInst.saleId != null && targetInst.saleId!.isNotEmpty) {
        final sale = await (_db.select(_db.sales)
              ..where((tbl) => tbl.id.equals(targetInst.saleId!)))
            .getSingleOrNull();
        if (sale != null) {
          resolvedProjectId = sale.projectId;
        }
      } else if (targetInst.purchaseAgreementId != null &&
          targetInst.purchaseAgreementId!.isNotEmpty) {
        final pa = await (_db.select(_db.purchaseAgreements)
              ..where((tbl) => tbl.id.equals(targetInst.purchaseAgreementId!)))
            .getSingleOrNull();
        if (pa != null) {
          resolvedProjectId = pa.projectId;
        }
      }
    }

    // Verify resolvedProjectId exists in projects table; fallback if necessary
    final existingProject = await (_db.select(_db.projects)
          ..where((tbl) => tbl.id.equals(resolvedProjectId)))
        .getSingleOrNull();

    if (existingProject == null) {
      final anyProject = await (_db.select(_db.projects)..limit(1)).getSingleOrNull();
      if (anyProject != null) {
        resolvedProjectId = anyProject.id;
      } else {
        throw ArgumentError('No valid project found in database to associate transaction.');
      }
    }

    // Insert transaction
    await _db.into(_db.transactions).insert(
          TransactionsCompanion(
            id: Value(transactionId),
            projectId: Value(resolvedProjectId),
            installmentId: Value(installmentId),
            amount: Value(amount),
            paymentDate: Value(paymentDate),
            paymentMethod: Value(paymentMethod.name),
            referenceNumber: Value(referenceNumber?.trim()),
            receiptPath: Value(receiptPath?.trim()),
            isVoided: const Value(false),
            createdBy: Value(userId),
            createdAt: Value(DateTime.now()),
          ),
        );

    // Update installment paid amount & status (AC-02.1) if linked to an installment
    if (installment != null) {
      final targetInst = installment;
      final newPaidAmount = targetInst.paidAmount + amount;
      InstallmentStatus newStatus;
      if (newPaidAmount >= targetInst.dueAmount) {
        newStatus = InstallmentStatus.paid;
      } else {
        newStatus = InstallmentStatus.partiallyPaid;
      }

      await (_db.update(_db.installments)..where((tbl) => tbl.id.equals(targetInst.id))).write(
        InstallmentsCompanion(
          paidAmount: Value(newPaidAmount),
          status: Value(newStatus.name),
        ),
      );
    }

    // Compliance auditing for cash >= ₹2,00,000 (Section 269ST - AC-02.3)
    final isCashLimitTriggered =
        paymentMethod == PaymentMethod.cash && amount >= AppConstants.cashTransactionLimit;

    // Audit log
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('RECORD_PAYMENT'),
            entityType: const Value('Transaction'),
            entityId: Value(transactionId),
            details: Value(
              'Recorded payment of ₹$amount via ${paymentMethod.name}. ${isCashLimitTriggered ? "WARNING: Section 269ST Cash limit threshold acknowledged." : ""}',
            ),
            timestamp: Value(DateTime.now()),
          ),
        );

    final row = await (_db.select(_db.transactions)..where((tbl) => tbl.id.equals(transactionId))).getSingle();
    return _toTransactionModel(row);
  }

  /// Void / Reverse a transaction (PRD §9 / Master Build Prompt §4 / Admin-only)
  Future<void> voidTransaction({
    required String transactionId,
    required String voidReason,
    required String userId,
  }) async {
    if (voidReason.trim().isEmpty) {
      throw ArgumentError('Reason for voiding transaction * is required.');
    }

    final tx = await (_db.select(_db.transactions)
          ..where((tbl) => tbl.id.equals(transactionId)))
        .getSingleOrNull();

    if (tx == null) {
      throw ArgumentError('Transaction record not found.');
    }
    if (tx.isVoided) {
      throw StateError('Transaction is already voided.');
    }

    // Mark transaction as voided
    await (_db.update(_db.transactions)..where((tbl) => tbl.id.equals(transactionId))).write(
      TransactionsCompanion(
        isVoided: const Value(true),
        voidReason: Value(voidReason.trim()),
      ),
    );

    // Reverse installment paid amount if linked
    if (tx.installmentId != null) {
      final installment = await (_db.select(_db.installments)
            ..where((tbl) => tbl.id.equals(tx.installmentId!)))
          .getSingleOrNull();

      if (installment != null) {
        final reversedPaidAmount = (installment.paidAmount - tx.amount) < 0
            ? 0.0
            : (installment.paidAmount - tx.amount);

        InstallmentStatus reversedStatus;
        if (reversedPaidAmount <= 0) {
          reversedStatus = InstallmentStatus.pending;
        } else if (reversedPaidAmount < installment.dueAmount) {
          reversedStatus = InstallmentStatus.partiallyPaid;
        } else {
          reversedStatus = InstallmentStatus.paid;
        }

        await (_db.update(_db.installments)..where((tbl) => tbl.id.equals(installment.id))).write(
          InstallmentsCompanion(
            paidAmount: Value(reversedPaidAmount),
            status: Value(reversedStatus.name),
          ),
        );
      }
    }

    // Audit log
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('VOID_TRANSACTION'),
            entityType: const Value('Transaction'),
            entityId: Value(transactionId),
            details: Value('Voided transaction ${tx.id} of ₹${tx.amount}. Reason: $voidReason'),
            timestamp: Value(DateTime.now()),
          ),
        );
  }
}
