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

  PlotModel _toModel(Plot row) {
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
      createdAt: row.createdAt,
    );
  }

  /// Watch stream of all plots
  Stream<List<PlotModel>> watchAllPlots() {
    return _db.select(_db.plots).watch().map(
          (rows) => rows.map(_toModel).toList(),
        );
  }

  /// Watch plots for a specific project
  Stream<List<PlotModel>> watchPlotsForProject(String projectId) {
    final query = _db.select(_db.plots)..where((tbl) => tbl.projectId.equals(projectId));
    return query.watch().map((rows) => rows.map(_toModel).toList());
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
    return _toModel(row);
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
    final modelMap = {for (final r in rows) r.id: _toModel(r)};
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
  Future<void> recalculateProjectCostAllocation(String projectId) async {
    final project = await (_db.select(_db.projects)..where((tbl) => tbl.id.equals(projectId))).getSingleOrNull();
    if (project == null) return;

    final plotsList = await (_db.select(_db.plots)..where((tbl) => tbl.projectId.equals(projectId))).get();
    if (plotsList.isEmpty) return;

    final totalProjectAllocatedArea = plotsList.fold<double>(0.0, (sum, p) => sum + p.areaSqFt);

    for (final plot in plotsList) {
      final allocatedCost = CalculationEngine.calculateAreaBasedPlotCost(
        plotAreaSqFt: plot.areaSqFt,
        totalProjectAreaSqFt: totalProjectAllocatedArea,
        actualProjectCost: project.actualCost,
      );

      await (_db.update(_db.plots)..where((tbl) => tbl.id.equals(plot.id))).write(
        PlotsCompanion(
          allocatedCost: Value(allocatedCost),
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
}
