import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/calculation_engine.dart';
import '../domain/plot_model.dart';

enum CostAllocationMethod {
  areaBased,
  percentageBased,
  manual,
}

class PlotsRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  PlotsRepository(this._db);

  PlotModel toModel(Plot row) {
    final statusEnum = PlotStatus.values.firstWhere(
      (s) => s.name == row.status,
      orElse: () => PlotStatus.available,
    );

    return PlotModel(
      id: row.id,
      projectId: row.projectId,
      plotNumber: row.plotNumber,
      areaSqFt: row.areaSqFt,
      measurementUnit: row.measurementUnit,
      displayArea: row.displayArea,
      kattaValue: row.kattaValue,
      dhurValue: row.dhurValue,
      lengthFt: row.lengthFt,
      lengthIn: row.lengthIn,
      breadthFt: row.breadthFt,
      breadthIn: row.breadthIn,
      allocatedCost: row.allocatedCost,
      expectedPrice: row.expectedPrice,
      status: statusEnum,
      brokerName: row.brokerName,
      brokerPhone: row.brokerPhone,
      brokerageCharge: row.brokerageCharge,
      createdAt: row.createdAt,
    );
  }

  /// Watch stream of all plots
  Stream<List<PlotModel>> watchAllPlots() {
    _syncAllProjectCostAllocations();
    return _db.select(_db.plots).watch().map(
          (rows) => rows.map(toModel).toList(),
        );
  }

  /// Watch plots for a specific project
  Stream<List<PlotModel>> watchPlotsForProject(String projectId) {
    recalculateProjectCostAllocation(projectId);
    final query = _db.select(_db.plots)..where((tbl) => tbl.projectId.equals(projectId));
    return query.watch().map((rows) => rows.map(toModel).toList());
  }

  Future<void> _syncAllProjectCostAllocations() async {
    final allProjects = await _db.select(_db.projects).get();
    for (final p in allProjects) {
      await recalculateProjectCostAllocation(p.id);
    }
  }

  /// Create a new plot (Validation: Plot Number *, Area Sq. Ft. > 0)
  Future<PlotModel> createPlot({
    required String projectId,
    required String plotNumber,
    required double areaSqFt,
    String measurementUnit = 'Square Feet',
    double? displayArea,
    double? kattaValue,
    double? dhurValue,
    double? lengthFt,
    double? lengthIn,
    double? breadthFt,
    double? breadthIn,
    double expectedPrice = 0.0,
    PlotStatus status = PlotStatus.available,
    required String userId,
  }) async {
    if (plotNumber.trim().isEmpty) {
      throw ArgumentError('Plot Number * is required.');
    }
    if (areaSqFt <= 0) {
      throw ArgumentError('Plot Area * must be greater than zero sq. ft.');
    }

    final id = _uuid.v4();
    await _db.into(_db.plots).insert(
          PlotsCompanion(
            id: Value(id),
            projectId: Value(projectId),
            plotNumber: Value(plotNumber.trim()),
            areaSqFt: Value(areaSqFt),
            measurementUnit: Value(measurementUnit),
            displayArea: Value(displayArea),
            kattaValue: Value(kattaValue),
            dhurValue: Value(dhurValue),
            lengthFt: Value(lengthFt),
            lengthIn: Value(lengthIn),
            breadthFt: Value(breadthFt),
            breadthIn: Value(breadthIn),
            allocatedCost: const Value(0.0),
            expectedPrice: Value(expectedPrice),
            status: Value(status.name),
            createdAt: Value(DateTime.now()),
          ),
        );

    // Automatically trigger area-based cost allocation for project
    await recalculateProjectCostAllocation(projectId);

    // Audit log
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('SUBDIVIDE_PLOT'),
            entityType: const Value('Plot'),
            entityId: Value(id),
            details: Value('Created Plot #$plotNumber ($areaSqFt sq.ft) in project $projectId.'),
            timestamp: Value(DateTime.now()),
          ),
        );

    final row = await (_db.select(_db.plots)..where((tbl) => tbl.id.equals(id))).getSingle();
    return toModel(row);
  }

  /// Create multiple plots with identical dimensions/measurements in batch
  Future<List<PlotModel>> createPlotsBatch({
    required String projectId,
    required List<String> plotNumbers,
    required double areaSqFt,
    String measurementUnit = 'Square Feet',
    double? displayArea,
    double? kattaValue,
    double? dhurValue,
    double? lengthFt,
    double? lengthIn,
    double? breadthFt,
    double? breadthIn,
    double expectedPrice = 0.0,
    PlotStatus status = PlotStatus.available,
    required String userId,
  }) async {
    if (plotNumbers.isEmpty) {
      throw ArgumentError('At least one Plot Number is required.');
    }
    if (areaSqFt <= 0) {
      throw ArgumentError('Plot Area * must be greater than zero sq. ft.');
    }

    final createdIds = <String>[];
    final now = DateTime.now();

    for (final number in plotNumbers) {
      final id = _uuid.v4();
      createdIds.add(id);
      await _db.into(_db.plots).insert(
            PlotsCompanion(
              id: Value(id),
              projectId: Value(projectId),
              plotNumber: Value(number.trim()),
              areaSqFt: Value(areaSqFt),
              measurementUnit: Value(measurementUnit),
              displayArea: Value(displayArea),
              kattaValue: Value(kattaValue),
              dhurValue: Value(dhurValue),
              lengthFt: Value(lengthFt),
              lengthIn: Value(lengthIn),
              breadthFt: Value(breadthFt),
              breadthIn: Value(breadthIn),
              allocatedCost: const Value(0.0),
              expectedPrice: Value(expectedPrice),
              status: Value(status.name),
              createdAt: Value(now),
            ),
          );
    }

    // Automatically trigger area-based cost allocation for project
    await recalculateProjectCostAllocation(projectId);

    // Audit log
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('SUBDIVIDE_PLOTS_BATCH'),
            entityType: const Value('Plot'),
            entityId: Value(projectId),
            details: Value('Created ${plotNumbers.length} plots with identical dimensions ($areaSqFt sq.ft each) in project $projectId.'),
            timestamp: Value(now),
          ),
        );

    final rows = await (_db.select(_db.plots)..where((tbl) => tbl.id.isIn(createdIds))).get();
    final modelMap = {for (final r in rows) r.id: toModel(r)};
    return createdIds.map((id) => modelMap[id]!).toList();
  }

  /// Update existing plot details
  Future<void> updatePlot(PlotModel plot, {required String userId}) async {
    await (_db.update(_db.plots)..where((tbl) => tbl.id.equals(plot.id))).write(
      PlotsCompanion(
        plotNumber: Value(plot.plotNumber),
        areaSqFt: Value(plot.areaSqFt),
        measurementUnit: Value(plot.measurementUnit),
        displayArea: Value(plot.displayArea),
        kattaValue: Value(plot.kattaValue),
        dhurValue: Value(plot.dhurValue),
        expectedPrice: Value(plot.expectedPrice),
        status: Value(plot.status.name),
      ),
    );

    await recalculateProjectCostAllocation(plot.projectId);

    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('UPDATE_PLOT'),
            entityType: const Value('Plot'),
            entityId: Value(plot.id),
            details: Value('Updated Plot #${plot.plotNumber} details.'),
            timestamp: Value(DateTime.now()),
          ),
        );
  }

  /// Recalculate area-based cost allocation for all plots in a project (PRD §7.2 / AC-05.1)
  /// General project expenses are divided area-wise pro-rata across all plots.
  /// Brokerage charges are added strictly to their specific plot only.
  Future<void> recalculateProjectCostAllocation(String projectId) async {
    final project = await (_db.select(_db.projects)..where((tbl) => tbl.id.equals(projectId))).getSingleOrNull();
    if (project == null) return;

    final plotsList = await (_db.select(_db.plots)..where((tbl) => tbl.projectId.equals(projectId))).get();
    if (plotsList.isEmpty) return;

    // Use project.landAreaSqFt (the entire acquired project land) so un-subdivided land is not erroneously dumped onto existing plots.
    final totalProjectArea = project.landAreaSqFt > 0
        ? project.landAreaSqFt
        : plotsList.fold<double>(0.0, (sum, p) => sum + p.areaSqFt);

    // Retrieve all capitalized project expenses
    final allProjectExpenses = await (_db.select(_db.expenses)
          ..where((tbl) => tbl.projectId.equals(projectId) & tbl.isCapitalized.equals(true)))
        .get();
    final totalCapitalizedExpenses = allProjectExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);

    // Sum of all individual plot brokerage charges
    final totalPlotBrokerages = plotsList.fold<double>(0.0, (sum, p) => sum + p.brokerageCharge);

    // General project expenses (distributed pro-rata by area across all plots)
    final generalProjectExpenses = (totalCapitalizedExpenses - totalPlotBrokerages).clamp(0.0, double.infinity);

    for (final plot in plotsList) {
      final baseLandCost = totalProjectArea > 0
          ? (plot.areaSqFt / totalProjectArea) * project.purchasePrice
          : 0.0;
      final allocatedGeneralExpense = totalProjectArea > 0
          ? (plot.areaSqFt / totalProjectArea) * generalProjectExpenses
          : 0.0;
      final plotTotalCost = CalculationEngine.calculatePlotTotalCost(
        basePurchaseCost: baseLandCost,
        plotTotalExpense: CalculationEngine.calculatePlotTotalExpense(
          allocatedExpense: allocatedGeneralExpense,
          brokerageCharge: plot.brokerageCharge,
        ),
      );

      await (_db.update(_db.plots)..where((tbl) => tbl.id.equals(plot.id))).write(
        PlotsCompanion(
          allocatedCost: Value(plotTotalCost),
        ),
      );
    }
  }

  /// Update plot status
  Future<void> updatePlotStatus(String plotId, PlotStatus newStatus, {required String userId}) async {
    await (_db.update(_db.plots)..where((tbl) => tbl.id.equals(plotId))).write(
      PlotsCompanion(
        status: Value(newStatus.name),
      ),
    );
  }

  /// Generate next auto-incremented plot number with format AXPN0001
  Future<String> generateNextPlotNumber() async {
    final allPlots = await _db.select(_db.plots).get();
    int maxSeq = 0;
    final regExp = RegExp(r'AXPN(\d+)', caseSensitive: false);

    for (final plot in allPlots) {
      final match = regExp.firstMatch(plot.plotNumber);
      if (match != null) {
        final seq = int.tryParse(match.group(1) ?? '') ?? 0;
        if (seq > maxSeq) maxSeq = seq;
      }
    }

    final nextSeq = maxSeq > 0 ? maxSeq + 1 : 1;
    return 'AXPN${nextSeq.toString().padLeft(4, '0')}';
  }

  /// Generate next auto-incremented road identifier with format ROAD-01
  Future<String> generateNextRoadNumber() async {
    final allPlots = await _db.select(_db.plots).get();
    int maxSeq = 0;
    final regExp1 = RegExp(r'ROAD-(\d+)', caseSensitive: false);
    final regExp2 = RegExp(r'ROAD\s*#?(\d+)', caseSensitive: false);
    final regExp3 = RegExp(r'AXRD(\d+)', caseSensitive: false);

    for (final plot in allPlots) {
      final match = regExp1.firstMatch(plot.plotNumber) ??
          regExp2.firstMatch(plot.plotNumber) ??
          regExp3.firstMatch(plot.plotNumber);
      if (match != null) {
        final seq = int.tryParse(match.group(1) ?? '') ?? 0;
        if (seq > maxSeq) maxSeq = seq;
      }
    }

    final nextSeq = maxSeq > 0 ? maxSeq + 1 : 1;
    return 'ROAD-${nextSeq.toString().padLeft(2, '0')}';
  }

  /// Delete plot and automatically recalculate project cost allocation
  Future<void> deletePlot(String plotId, {required String userId}) async {
    final plot = await (_db.select(_db.plots)..where((tbl) => tbl.id.equals(plotId))).getSingleOrNull();
    if (plot == null) return;

    await (_db.delete(_db.plots)..where((tbl) => tbl.id.equals(plotId))).go();

    // Recalculate cost allocation for remaining plots in the project
    await recalculateProjectCostAllocation(plot.projectId);

    // Audit log
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('DELETE_PLOT'),
            entityType: const Value('Plot'),
            entityId: Value(plotId),
            details: Value('Deleted Plot #${plot.plotNumber} in project ID ${plot.projectId}.'),
            timestamp: Value(DateTime.now()),
          ),
        );
  }

  /// Record or update brokerage charge for a specific plot and log it in project expenses
  Future<void> recordPlotBrokerage({
    required String plotId,
    required String brokerName,
    required String brokerPhone,
    required double brokerageCharge,
    required String userId,
  }) async {
    final plot = await (_db.select(_db.plots)..where((tbl) => tbl.id.equals(plotId))).getSingleOrNull();
    if (plot == null) {
      throw ArgumentError('Plot not found.');
    }
    if (brokerageCharge <= 0) {
      throw ArgumentError('Brokerage Charge must be greater than zero.');
    }
    if (brokerName.trim().isEmpty) {
      throw ArgumentError('Broker Name is required.');
    }

    // 1. Update plot table with brokerage details
    await (_db.update(_db.plots)..where((tbl) => tbl.id.equals(plotId))).write(
      PlotsCompanion(
        brokerName: Value(brokerName.trim()),
        brokerPhone: Value(brokerPhone.trim()),
        brokerageCharge: Value(brokerageCharge),
      ),
    );

    // 2. Automatically record or update in Expenses table under the project as capitalized brokerage expense
    final existingBrokerageExpenses = await (_db.select(_db.expenses)
          ..where((tbl) =>
              tbl.projectId.equals(plot.projectId) &
              tbl.category.equals(ExpenseCategory.brokerage.name)))
        .get();

    final matchExpense = existingBrokerageExpenses.where((e) {
      return (e.notes != null && e.notes!.contains('Plot #${plot.plotNumber}')) ||
          (e.vendor != null && e.vendor!.trim() == brokerName.trim());
    }).firstOrNull;

    if (matchExpense != null) {
      await (_db.update(_db.expenses)..where((tbl) => tbl.id.equals(matchExpense.id))).write(
        ExpensesCompanion(
          amount: Value(brokerageCharge),
          vendor: Value(brokerName.trim().isNotEmpty ? brokerName.trim() : null),
          notes: Value(
            'Brokerage charge for Plot #${plot.plotNumber}${brokerPhone.trim().isNotEmpty ? ' (Mobile: ${brokerPhone.trim()})' : ''}',
          ),
          isCapitalized: const Value(true),
        ),
      );
    } else {
      final expenseId = _uuid.v4();
      await _db.into(_db.expenses).insert(
        ExpensesCompanion(
          id: Value(expenseId),
          projectId: Value(plot.projectId),
          category: Value(ExpenseCategory.brokerage.name),
          amount: Value(brokerageCharge),
          expenseDate: Value(DateTime.now()),
          vendor: Value(brokerName.trim().isNotEmpty ? brokerName.trim() : null),
          isCapitalized: const Value(true),
          notes: Value(
            'Brokerage charge for Plot #${plot.plotNumber}${brokerPhone.trim().isNotEmpty ? ' (Mobile: ${brokerPhone.trim()})' : ''}',
          ),
          createdAt: Value(DateTime.now()),
        ),
      );
    }

    // 3. Recalculate Actual Project Cost and area-based cost allocation
    final allProjectExpenses = await (_db.select(_db.expenses)
          ..where((tbl) => tbl.projectId.equals(plot.projectId)))
        .get();
    final capitalizedList = allProjectExpenses
        .where((e) => e.isCapitalized)
        .map((e) => e.amount)
        .toList();

    final project = await (_db.select(_db.projects)
          ..where((tbl) => tbl.id.equals(plot.projectId)))
        .getSingleOrNull();
    if (project != null) {
      final newActualCost = CalculationEngine.calculateActualProjectCost(
        purchasePrice: project.purchasePrice,
        capitalizedExpenses: capitalizedList,
      );

      await (_db.update(_db.projects)..where((tbl) => tbl.id.equals(plot.projectId))).write(
        ProjectsCompanion(
          actualCost: Value(newActualCost),
        ),
      );
      await recalculateProjectCostAllocation(plot.projectId);
    }

    // 4. Audit Log
    await _db.into(_db.auditLogs).insert(
      AuditLogsCompanion(
        id: Value(_uuid.v4()),
        userId: Value(userId),
        action: const Value('RECORD_BROKERAGE_CHARGE'),
        entityType: const Value('Plot'),
        entityId: Value(plotId),
        details: Value(
          'Recorded Brokerage Charge ₹$brokerageCharge for Plot #${plot.plotNumber} with Broker $brokerName ($brokerPhone). Isolated to this plot.',
        ),
        timestamp: Value(DateTime.now()),
      ),
    );
  }
}
