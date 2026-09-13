import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../domain/buyer_model.dart';
import '../domain/sale_model.dart';

class SalesRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  SalesRepository(this._db);

  BuyerModel _toBuyerModel(Buyer row) {
    return BuyerModel(
      id: row.id,
      name: row.name,
      phone: row.phone,
      email: row.email,
      pan: row.pan,
      aadhar: row.aadhar,
      createdAt: row.createdAt,
    );
  }

  /// Watch stream of all buyers
  Stream<List<BuyerModel>> watchAllBuyers() {
    return _db.select(_db.buyers).watch().map(
          (rows) => rows.map(_toBuyerModel).toList(),
        );
  }

  /// Register a new buyer with KYC details
  Future<BuyerModel> createBuyer({
    required String name,
    required String phone,
    String? email,
    String? pan,
    String? aadhar,
    required String userId,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Buyer Name * is required.');
    }
    if (phone.trim().isEmpty) {
      throw ArgumentError('Phone Number * is required.');
    }

    final id = _uuid.v4();
    await _db.into(_db.buyers).insert(
          BuyersCompanion(
            id: Value(id),
            name: Value(name.trim()),
            phone: Value(phone.trim()),
            email: Value(email?.trim()),
            pan: Value(pan?.trim()),
            aadhar: Value(aadhar?.trim()),
            createdAt: Value(DateTime.now()),
          ),
        );

    // Audit log
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('CREATE_BUYER'),
            entityType: const Value('Buyer'),
            entityId: Value(id),
            details: Value('Registered buyer "$name" ($phone).'),
            timestamp: Value(DateTime.now()),
          ),
        );

    final row = await (_db.select(_db.buyers)..where((tbl) => tbl.id.equals(id))).getSingle();
    return _toBuyerModel(row);
  }

  /// Watch sales joined with Buyer details
  Stream<List<SaleModel>> watchAllSales() {
    final query = _db.select(_db.sales).join([
      innerJoin(
        _db.buyers,
        _db.buyers.id.equalsExp(_db.sales.buyerId),
      ),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final sale = row.readTable(_db.sales);
        final buyer = row.readTable(_db.buyers);

        final saleTypeEnum = SaleType.values.firstWhere(
          (t) => t.name == sale.saleType,
          orElse: () => SaleType.plotWise,
        );

        return SaleModel(
          id: sale.id,
          projectId: sale.projectId,
          buyerId: sale.buyerId,
          buyerName: buyer.name,
          saleType: saleTypeEnum,
          agreedPrice: sale.agreedPrice,
          saleExpenses: sale.saleExpenses,
          circleRateValue: sale.circleRateValue,
          saleDate: sale.saleDate,
          status: sale.status,
          createdAt: sale.createdAt,
        );
      }).toList();
    });
  }

  /// Create a new sale agreement (PRD §6.5 / User Flow §3.6)
  Future<SaleModel> createSaleAgreement({
    required String projectId,
    required String buyerId,
    required SaleType saleType,
    required double agreedPrice,
    double saleExpenses = 0.0,
    double? circleRateValue,
    required DateTime saleDate,
    List<String> plotIds = const [],
    double? initialInstallmentAmount,
    int? installmentCount,
    required String userId,
  }) async {
    if (agreedPrice <= 0) {
      throw ArgumentError('Agreed Sale Price * must be greater than zero.');
    }

    final id = _uuid.v4();
    await _db.into(_db.sales).insert(
          SalesCompanion(
            id: Value(id),
            projectId: Value(projectId),
            buyerId: Value(buyerId),
            saleType: Value(saleType.name),
            agreedPrice: Value(agreedPrice),
            saleExpenses: Value(saleExpenses),
            circleRateValue: Value(circleRateValue),
            saleDate: Value(saleDate),
            status: const Value('SALE_AGREEMENT'),
            createdAt: Value(DateTime.now()),
          ),
        );

    // Update status of linked plots to SALE_AGREEMENT / BOOKED
    for (final plotId in plotIds) {
      await (_db.update(_db.plots)..where((tbl) => tbl.id.equals(plotId))).write(
        PlotsCompanion(
          status: Value(PlotStatus.saleAgreement.name),
        ),
      );
      await _db.into(_db.auditLogs).insert(
        AuditLogsCompanion(
          id: Value(_uuid.v4()),
          userId: Value(userId),
          action: const Value('LINK_PLOT_SALE'),
          entityType: const Value('Plot'),
          entityId: Value(plotId),
          details: Value('SaleId:$id;BuyerId:$buyerId'),
          timestamp: Value(DateTime.now()),
        ),
      );
    }

    // Auto-create Installments & Initial Down Payment Transaction if specified
    final double initialAmount = (initialInstallmentAmount ?? 0.0).clamp(0.0, agreedPrice);
    final int count = installmentCount ?? ((initialAmount > 0 && initialAmount < agreedPrice) ? 2 : (initialAmount > 0 ? 1 : 0));

    if (count > 0 || initialAmount > 0) {
      final double remainingBalance = agreedPrice - initialAmount;
      final int remainingCount = initialAmount > 0 ? (count - 1).clamp(0, 999) : count;
      int installmentNo = 1;

      if (initialAmount > 0) {
        final firstInstId = _uuid.v4();
        await _db.into(_db.installments).insert(
              InstallmentsCompanion(
                id: Value(firstInstId),
                saleId: Value(id),
                installmentNumber: Value(installmentNo++),
                dueDate: Value(saleDate),
                dueAmount: Value(initialAmount),
                paidAmount: Value(initialAmount),
                status: const Value('PAID'),
                createdAt: Value(DateTime.now()),
              ),
            );

        await _db.into(_db.transactions).insert(
              TransactionsCompanion(
                id: Value(_uuid.v4()),
                projectId: Value(projectId),
                installmentId: Value(firstInstId),
                amount: Value(initialAmount),
                paymentDate: Value(saleDate),
                paymentMethod: const Value('bankTransfer'),
                createdBy: Value(userId),
                createdAt: Value(DateTime.now()),
              ),
            );
      }

      if (remainingBalance > 0 && remainingCount > 0) {
        final perInstAmount = remainingBalance / remainingCount;
        for (int i = 1; i <= remainingCount; i++) {
          final dueDate = saleDate.add(Duration(days: 30 * i));
          await _db.into(_db.installments).insert(
                InstallmentsCompanion(
                  id: Value(_uuid.v4()),
                  saleId: Value(id),
                  installmentNumber: Value(installmentNo++),
                  dueDate: Value(dueDate),
                  dueAmount: Value(perInstAmount),
                  paidAmount: const Value(0.0),
                  status: const Value('PENDING'),
                  createdAt: Value(DateTime.now()),
                ),
              );
        }
      }
    }

    // Auto-record direct sale expense / brokerage into expenses table (Capitalized)
    if (saleExpenses > 0) {
      final buyer = await (_db.select(_db.buyers)..where((tbl) => tbl.id.equals(buyerId))).getSingleOrNull();
      final buyerName = buyer?.name ?? 'Customer';
      final expId = _uuid.v4();
      await _db.into(_db.expenses).insert(
            ExpensesCompanion(
              id: Value(expId),
              projectId: Value(projectId),
              category: Value(ExpenseCategory.brokerage.name),
              amount: Value(saleExpenses),
              expenseDate: Value(saleDate),
              vendor: Value('Broker / Sale Agent ($buyerName)'),
              isCapitalized: const Value(true),
              notes: Value('Direct Sale Expense / Brokerage for Plot Sale Agreement ($id) - $buyerName'),
              createdAt: Value(DateTime.now()),
            ),
          );

      // Recalculate Project Actual Cost
      final allExpenses = await (_db.select(_db.expenses)..where((tbl) => tbl.projectId.equals(projectId))).get();
      final totalCapitalized = allExpenses
          .where((e) => e.isCapitalized)
          .fold(0.0, (sum, e) => sum + e.amount);
      final project = await (_db.select(_db.projects)..where((tbl) => tbl.id.equals(projectId))).getSingleOrNull();
      if (project != null) {
        final dynamicActualCost = project.purchasePrice + totalCapitalized;
        await (_db.update(_db.projects)..where((tbl) => tbl.id.equals(projectId))).write(
          ProjectsCompanion(
            actualCost: Value(dynamicActualCost),
          ),
        );
      }
    }

    final isBelowCircleRate = circleRateValue != null && agreedPrice < circleRateValue;

    // Write audit log with compliance flag details
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('CREATE_SALE_AGREEMENT'),
            entityType: const Value('Sale'),
            entityId: Value(id),
            details: Value(
              'Created ${saleType.name} sale for ₹$agreedPrice. ${isBelowCircleRate ? "WARNING: Sale price is below DLC/Circle rate threshold!" : ""}',
            ),
            timestamp: Value(DateTime.now()),
          ),
        );

    final row = await (_db.select(_db.sales).join([
      innerJoin(_db.buyers, _db.buyers.id.equalsExp(_db.sales.buyerId)),
    ])..where(_db.sales.id.equals(id))).getSingle();

    final sale = row.readTable(_db.sales);
    final buyer = row.readTable(_db.buyers);

    return SaleModel(
      id: sale.id,
      projectId: sale.projectId,
      buyerId: sale.buyerId,
      buyerName: buyer.name,
      saleType: saleType,
      agreedPrice: sale.agreedPrice,
      saleExpenses: sale.saleExpenses,
      circleRateValue: sale.circleRateValue,
      saleDate: sale.saleDate,
      status: sale.status,
      createdAt: sale.createdAt,
    );
  }

  /// Update buyer profile
  Future<BuyerModel> updateBuyer({
    required String id,
    required String name,
    required String phone,
    String? email,
    String? pan,
    String? aadhar,
    required String userId,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Buyer Name * is required.');
    }
    if (phone.trim().isEmpty) {
      throw ArgumentError('Phone Number * is required.');
    }

    await (_db.update(_db.buyers)..where((tbl) => tbl.id.equals(id))).write(
      BuyersCompanion(
        name: Value(name.trim()),
        phone: Value(phone.trim()),
        email: Value(email?.trim()),
        pan: Value(pan?.trim()),
        aadhar: Value(aadhar?.trim()),
      ),
    );

    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('UPDATE_BUYER'),
            entityType: const Value('Buyer'),
            entityId: Value(id),
            details: Value('Updated buyer "$name" ($phone).'),
            timestamp: Value(DateTime.now()),
          ),
        );

    final row = await (_db.select(_db.buyers)..where((tbl) => tbl.id.equals(id))).getSingle();
    return _toBuyerModel(row);
  }

  /// Delete buyer profile and linked sales records
  Future<void> deleteBuyer(String id, {required String userId}) async {
    final buyer = await (_db.select(_db.buyers)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    final sales = await (_db.select(_db.sales)..where((tbl) => tbl.buyerId.equals(id))).get();
    for (final sale in sales) {
      await deleteSaleAgreement(sale.id, userId: userId);
    }

    await (_db.delete(_db.buyers)..where((tbl) => tbl.id.equals(id))).go();

    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('DELETE_BUYER'),
            entityType: const Value('Buyer'),
            entityId: Value(id),
            details: Value('Deleted buyer "${buyer?.name ?? id}".'),
            timestamp: Value(DateTime.now()),
          ),
        );
  }

  /// Delete sale agreement and linked installment & transaction records
  Future<void> deleteSaleAgreement(String saleId, {required String userId}) async {
    final sale = await (_db.select(_db.sales)..where((tbl) => tbl.id.equals(saleId))).getSingleOrNull();
    if (sale == null) return;

    final insts = await (_db.select(_db.installments)..where((tbl) => tbl.saleId.equals(saleId))).get();
    for (final inst in insts) {
      await (_db.delete(_db.transactions)..where((tbl) => tbl.installmentId.equals(inst.id))).go();
      await (_db.delete(_db.installments)..where((tbl) => tbl.id.equals(inst.id))).go();
    }

    // Reset linked plots status back to AVAILABLE
    final linkLogs = await (_db.select(_db.auditLogs)
      ..where((tbl) => tbl.action.equals('LINK_PLOT_SALE') & tbl.details.like('%SaleId:$saleId%'))).get();
    for (final log in linkLogs) {
      await (_db.update(_db.plots)..where((tbl) => tbl.id.equals(log.entityId))).write(
        PlotsCompanion(
          status: Value(PlotStatus.available.name),
        ),
      );
    }

    // Delete linked direct sale expenses from expenses table
    await (_db.delete(_db.expenses)..where((tbl) => tbl.notes.like('%($saleId)%'))).go();

    await (_db.delete(_db.sales)..where((tbl) => tbl.id.equals(saleId))).go();

    // Recalculate Project Actual Cost
    final allExpenses = await (_db.select(_db.expenses)..where((tbl) => tbl.projectId.equals(sale.projectId))).get();
    final totalCapitalized = allExpenses
        .where((e) => e.isCapitalized)
        .fold(0.0, (sum, e) => sum + e.amount);
    final project = await (_db.select(_db.projects)..where((tbl) => tbl.id.equals(sale.projectId))).getSingleOrNull();
    if (project != null) {
      final dynamicActualCost = project.purchasePrice + totalCapitalized;
      await (_db.update(_db.projects)..where((tbl) => tbl.id.equals(sale.projectId))).write(
        ProjectsCompanion(
          actualCost: Value(dynamicActualCost),
        ),
      );
    }

    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('DELETE_SALE_AGREEMENT'),
            entityType: const Value('Sale'),
            entityId: Value(saleId),
            details: Value('Deleted sale agreement of ₹${sale.agreedPrice}.'),
            timestamp: Value(DateTime.now()),
          ),
        );
  }
}
