import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/calculation_engine.dart';
import '../domain/investor_model.dart';
import '../domain/project_investor_model.dart';

class InvestorsRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  InvestorsRepository(this._db);

  InvestorModel _toInvestorModel(Investor row) {
    return InvestorModel(
      id: row.id,
      name: row.name,
      phone: row.phone,
      email: row.email,
      pan: row.pan,
      createdAt: row.createdAt,
    );
  }

  /// Watch stream of all registered investors
  Stream<List<InvestorModel>> watchAllInvestors() {
    return _db.select(_db.investors).watch().map(
          (rows) => rows.map(_toInvestorModel).toList(),
        );
  }

  /// Register a new investor profile (Validation: Name *, Phone *)
  Future<InvestorModel> createInvestor({
    required String name,
    required String phone,
    String? email,
    String? pan,
    required String userId,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Investor Name * is required.');
    }
    if (phone.trim().isEmpty) {
      throw ArgumentError('Phone Number * is required.');
    }

    final id = _uuid.v4();
    await _db.into(_db.investors).insert(
          InvestorsCompanion(
            id: Value(id),
            name: Value(name.trim()),
            phone: Value(phone.trim()),
            email: Value(email?.trim()),
            pan: Value(pan?.trim()),
            createdAt: Value(DateTime.now()),
          ),
        );

    // Audit log
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('CREATE_INVESTOR'),
            entityType: const Value('Investor'),
            entityId: Value(id),
            details: Value('Registered investor "$name" ($phone).'),
            timestamp: Value(DateTime.now()),
          ),
        );

    final row = await (_db.select(_db.investors)..where((tbl) => tbl.id.equals(id))).getSingle();
    return _toInvestorModel(row);
  }

  /// Watch project investor allocations for a specific project
  Stream<List<ProjectInvestorModel>> watchProjectInvestors(String projectId) {
    final query = _db.select(_db.projectInvestors).join([
      innerJoin(
        _db.investors,
        _db.investors.id.equalsExp(_db.projectInvestors.investorId),
      ),
    ])..where(_db.projectInvestors.projectId.equals(projectId));

    return query.watch().map((rows) {
      return rows.map((row) {
        final pi = row.readTable(_db.projectInvestors);
        final inv = row.readTable(_db.investors);

        final method = OwnershipMethod.values.firstWhere(
          (m) => m.name == pi.ownershipMethod,
          orElse: () => OwnershipMethod.capitalBased,
        );

        return ProjectInvestorModel(
          id: pi.id,
          projectId: pi.projectId,
          investorId: pi.investorId,
          investorName: inv.name,
          investedAmount: pi.investedAmount,
          ownershipPercent: pi.ownershipPercent,
          ownershipMethod: method,
          createdAt: pi.createdAt,
        );
      }).toList();
    });
  }

  /// Get list of project investors once
  Future<List<ProjectInvestorModel>> getProjectInvestors(String projectId) =>
      watchProjectInvestors(projectId).first;

  /// Watch all project participations for a single investor across all projects
  Stream<List<ProjectInvestorModel>> watchInvestorProjects(String investorId) {
    final query = _db.select(_db.projectInvestors).join([
      innerJoin(
        _db.projects,
        _db.projects.id.equalsExp(_db.projectInvestors.projectId),
      ),
    ])..where(_db.projectInvestors.investorId.equals(investorId));

    return query.watch().map((rows) {
      return rows.map((row) {
        final pi = row.readTable(_db.projectInvestors);
        final prj = row.readTable(_db.projects);

        final method = OwnershipMethod.values.firstWhere(
          (m) => m.name == pi.ownershipMethod,
          orElse: () => OwnershipMethod.capitalBased,
        );

        return ProjectInvestorModel(
          id: pi.id,
          projectId: pi.projectId,
          investorId: pi.investorId,
          investorName: prj.name, // Use project name for displaying participation
          investedAmount: pi.investedAmount,
          ownershipPercent: pi.ownershipPercent,
          ownershipMethod: method,
          createdAt: pi.createdAt,
        );
      }).toList();
    });
  }

  /// Add capital investment to project and recalculate Ownership % (AC-03.1, AC-03.2)
  Future<ProjectInvestorModel> addProjectInvestment({
    required String projectId,
    required String investorId,
    required double investedAmount,
    String? agreementDocPath,
    OwnershipMethod method = OwnershipMethod.capitalBased,
    double? manualOwnershipPercent,
    required String userId,
  }) async {
    if (investedAmount < 0) {
      throw ArgumentError('Invested Amount * must be greater than or equal to zero.');
    }

    final id = _uuid.v4();

    // Insert new investment record
    await _db.into(_db.projectInvestors).insert(
          ProjectInvestorsCompanion(
            id: Value(id),
            projectId: Value(projectId),
            investorId: Value(investorId),
            investedAmount: Value(investedAmount),
            ownershipPercent: Value(manualOwnershipPercent ?? 0.0),
            ownershipMethod: Value(method.name),
            createdAt: Value(DateTime.now()),
          ),
        );

    // If CAPITAL_BASED, recalculate Ownership % across ALL investors in this project (AC-03.1 & AC-03.2)
    if (method == OwnershipMethod.capitalBased) {
      await recalculateCapitalBasedOwnership(projectId);
    }

    // Write audit log
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('ADD_PROJECT_INVESTMENT'),
            entityType: const Value('ProjectInvestor'),
            entityId: Value(id),
            details: Value('Recorded investment of ₹$investedAmount for investor $investorId in project $projectId.'),
            timestamp: Value(DateTime.now()),
          ),
        );

    final row = await (_db.select(_db.projectInvestors).join([
      innerJoin(
        _db.investors,
        _db.investors.id.equalsExp(_db.projectInvestors.investorId),
      ),
    ])..where(_db.projectInvestors.id.equals(id))).getSingle();

    final pi = row.readTable(_db.projectInvestors);
    final inv = row.readTable(_db.investors);

    final resolvedMethod = OwnershipMethod.values.firstWhere(
      (m) => m.name == pi.ownershipMethod,
      orElse: () => OwnershipMethod.capitalBased,
    );

    return ProjectInvestorModel(
      id: pi.id,
      projectId: pi.projectId,
      investorId: pi.investorId,
      investorName: inv.name,
      investedAmount: pi.investedAmount,
      ownershipPercent: pi.ownershipPercent,
      ownershipMethod: resolvedMethod,
      createdAt: pi.createdAt,
    );
  }

  /// Recalculate Ownership % for all capital-based investors in a project (AC-03.1 & AC-03.2)
  Future<void> recalculateCapitalBasedOwnership(String projectId) async {
    final existingRows = await (_db.select(_db.projectInvestors)
          ..where((tbl) => tbl.projectId.equals(projectId)))
        .get();

    final totalShareCapital = existingRows.fold<double>(
      0.0,
      (sum, item) => sum + item.investedAmount,
    );

    for (final row in existingRows) {
      if (row.ownershipMethod == OwnershipMethod.capitalBased.name) {
        final newPercent = CalculationEngine.calculateInvestorOwnershipPercent(
          investorContribution: row.investedAmount,
          totalShareCapital: totalShareCapital,
        );

        await (_db.update(_db.projectInvestors)..where((tbl) => tbl.id.equals(row.id))).write(
          ProjectInvestorsCompanion(
            ownershipPercent: Value(newPercent),
          ),
        );
      }
    }
  }

  /// Recalculate Ownership % for all projects across the database
  Future<void> recalculateAllCapitalBasedOwnership() async {
    final allProjectInvestors = await _db.select(_db.projectInvestors).get();
    final projectIds = allProjectInvestors.map((pi) => pi.projectId).toSet();
    for (final pid in projectIds) {
      await recalculateCapitalBasedOwnership(pid);
    }
  }

  /// Calculate financial summary for an investor to verify if capital + profit withdraw is complete
  Future<InvestorFinancialSummary> getInvestorFinancialSummary(String investorId) async {
    final inv = await (_db.select(_db.investors)..where((tbl) => tbl.id.equals(investorId))).getSingleOrNull();
    final name = inv?.name ?? 'Investor';

    // Get all project allocations for this investor
    final allocations = await (_db.select(_db.projectInvestors)..where((tbl) => tbl.investorId.equals(investorId))).get();

    double totalInvestedCapital = 0.0;
    double totalProfitEarned = 0.0;

    for (final alloc in allocations) {
      totalInvestedCapital += alloc.investedAmount;

      // Sales for this project
      final sales = await (_db.select(_db.sales)..where((tbl) => tbl.projectId.equals(alloc.projectId))).get();
      double totalAgreedSales = 0.0;
      double directSaleExpenses = 0.0;
      for (final s in sales) {
        totalAgreedSales += s.agreedPrice;
        directSaleExpenses += s.saleExpenses;
      }

      // Project actual cost
      final prj = await (_db.select(_db.projects)..where((tbl) => tbl.id.equals(alloc.projectId))).getSingleOrNull();
      final actualCost = prj?.actualCost ?? 0.0;

      final projectProfit = totalAgreedSales - directSaleExpenses - actualCost;
      if (projectProfit > 0) {
        final share = projectProfit * (alloc.ownershipPercent / 100.0);
        totalProfitEarned += share;
      }
    }

    // Direct distributions
    final dists = await (_db.select(_db.distributions)..where((tbl) => tbl.investorId.equals(investorId))).get();
    double distTotal = dists.fold(0.0, (sum, d) => sum + d.amount);

    // Audit log payout disbursements
    double logDisbursedTotal = 0.0;
    for (final alloc in allocations) {
      final logs = await (_db.select(_db.auditLogs)
            ..where((tbl) =>
                tbl.action.equals('DISBURSE_INVESTOR_PAYOUT') &
                tbl.entityId.equals(alloc.id)))
          .get();

      for (final log in logs) {
        final parts = log.details.split('₹');
        if (parts.length > 1) {
          final amtStr = parts[1].split(' ')[0].replaceAll(',', '');
          logDisbursedTotal += double.tryParse(amtStr) ?? 0.0;
        }
      }
    }

    final totalWithdrawnPayouts = distTotal + logDisbursedTotal;
    final totalEntitled = totalInvestedCapital + totalProfitEarned;
    final netRemainingBalance = totalEntitled - totalWithdrawnPayouts;

    // Rule: Can be deleted if investor has no active project allocations OR if all invested money + profit are fully withdrawn (netRemainingBalance <= 0.01)
    final canBeDeleted = allocations.isEmpty ||
        (netRemainingBalance <= 0.01 && totalInvestedCapital <= totalWithdrawnPayouts + 0.01);

    return InvestorFinancialSummary(
      investorId: investorId,
      investorName: name,
      totalInvestedCapital: totalInvestedCapital,
      totalProfitEarned: totalProfitEarned,
      totalWithdrawnPayouts: totalWithdrawnPayouts,
      netRemainingBalance: netRemainingBalance < 0 ? 0.0 : netRemainingBalance,
      canBeDeleted: canBeDeleted,
    );
  }

  /// Stream of all project investor allocations across all projects
  Stream<List<ProjectInvestorModel>> watchAllProjectInvestors() {
    final query = _db.select(_db.projectInvestors).join([
      innerJoin(
        _db.investors,
        _db.investors.id.equalsExp(_db.projectInvestors.investorId),
      ),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final pi = row.readTable(_db.projectInvestors);
        final inv = row.readTable(_db.investors);

        final method = OwnershipMethod.values.firstWhere(
          (m) => m.name == pi.ownershipMethod,
          orElse: () => OwnershipMethod.capitalBased,
        );

        return ProjectInvestorModel(
          id: pi.id,
          projectId: pi.projectId,
          investorId: pi.investorId,
          investorName: inv.name,
          investedAmount: pi.investedAmount,
          ownershipPercent: pi.ownershipPercent,
          ownershipMethod: method,
          createdAt: pi.createdAt,
        );
      }).toList();
    });
  }

  /// Update investor profile
  Future<InvestorModel> updateInvestor({
    required String id,
    required String name,
    required String phone,
    String? email,
    String? pan,
    required String userId,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Investor Name * is required.');
    }
    if (phone.trim().isEmpty) {
      throw ArgumentError('Phone Number * is required.');
    }

    await (_db.update(_db.investors)..where((tbl) => tbl.id.equals(id))).write(
      InvestorsCompanion(
        name: Value(name.trim()),
        phone: Value(phone.trim()),
        email: Value(email?.trim()),
        pan: Value(pan?.trim()),
      ),
    );

    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('UPDATE_INVESTOR'),
            entityType: const Value('Investor'),
            entityId: Value(id),
            details: Value('Updated investor "$name" ($phone).'),
            timestamp: Value(DateTime.now()),
          ),
        );

    final row = await (_db.select(_db.investors)..where((tbl) => tbl.id.equals(id))).getSingle();
    return _toInvestorModel(row);
  }

  /// Delete investor by admin (with optional settlement check / force cascade cleanup)
  Future<void> deleteInvestor(String investorId, {required String userId, bool force = true}) async {
    final summary = await getInvestorFinancialSummary(investorId);

    if (!force && !summary.canBeDeleted) {
      final capitalStr = CalculationEngine.formatCurrency(summary.totalInvestedCapital);
      final profitStr = CalculationEngine.formatCurrency(summary.totalProfitEarned);
      final withdrawnStr = CalculationEngine.formatCurrency(summary.totalWithdrawnPayouts);
      final remainingStr = CalculationEngine.formatCurrency(summary.netRemainingBalance);

      throw StateError(
        'Cannot delete investor "${summary.investorName}": Active invested capital ($capitalStr) or profit share ($profitStr) has not been fully withdrawn/settled yet. '
        'Total Withdrawn: $withdrawnStr. Unsettled Balance: $remainingStr. '
        'Please complete all payout distributions before deleting.',
      );
    }

    // Clean up project investor allocations & distributions for investor
    await (_db.delete(_db.projectInvestors)..where((tbl) => tbl.investorId.equals(investorId))).go();
    await (_db.delete(_db.distributions)..where((tbl) => tbl.investorId.equals(investorId))).go();

    // Delete investor profile
    await (_db.delete(_db.investors)..where((tbl) => tbl.id.equals(investorId))).go();

    // Recalculate remaining capital ownership for all projects this investor was attached to
    await recalculateAllCapitalBasedOwnership();

    // Audit log
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('DELETE_INVESTOR'),
            entityType: const Value('Investor'),
            entityId: Value(investorId),
            details: Value(
              'Deleted investor "${summary.investorName}" (ID: $investorId). Cleaned up allocations & distributions.',
            ),
            timestamp: Value(DateTime.now()),
          ),
        );
  }
}
