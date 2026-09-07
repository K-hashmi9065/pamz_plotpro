import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../domain/project_model.dart';

class ProjectsRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  ProjectsRepository(this._db);

  /// Convert Drift Project row and optional Landowner to domain ProjectModel
  ProjectModel _toModel(Project row, [Landowner? landowner]) {
    final statusEnum = ProjectStatus.values.firstWhere(
      (e) => e.name == row.status,
      orElse: () => ProjectStatus.draft,
    );

    return ProjectModel(
      id: row.id,
      code: row.code,
      name: row.name,
      description: row.description,
      location: row.location,
      status: statusEnum,
      landownerId: row.landownerId,
      landownerName: landowner?.name,
      landAreaSqFt: row.landAreaSqFt,
      measurementUnit: row.measurementUnit,
      displayArea: row.displayArea,
      kattaValue: row.kattaValue,
      dhurValue: row.dhurValue,
      lengthFt: row.lengthFt,
      lengthIn: row.lengthIn,
      breadthFt: row.breadthFt,
      breadthIn: row.breadthIn,
      purchasePrice: row.purchasePrice,
      actualCost: row.actualCost,
      createdAt: row.createdAt,
    );
  }

  /// Watch / Get all projects stream (with landowner join)
  Stream<List<ProjectModel>> watchAllProjects() {
    final query = _db.select(_db.projects).join([
      leftOuterJoin(
        _db.landowners,
        _db.landowners.id.equalsExp(_db.projects.landownerId),
      ),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final prj = row.readTable(_db.projects);
        final lo = row.readTableOrNull(_db.landowners);
        return _toModel(prj, lo);
      }).toList();
    });
  }

  /// Get single project by ID (with landowner join)
  Future<ProjectModel?> getProjectById(String id) async {
    final query = _db.select(_db.projects).join([
      leftOuterJoin(
        _db.landowners,
        _db.landowners.id.equalsExp(_db.projects.landownerId),
      ),
    ])..where(_db.projects.id.equals(id));

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final prj = row.readTable(_db.projects);
    final lo = row.readTableOrNull(_db.landowners);
    return _toModel(prj, lo);
  }

  /// Create a new project (AC-01.1 validation: Name, Location, Area > 0)
  Future<ProjectModel> createProject({
    required String name,
    required String location,
    required double landAreaSqFt,
    String? landownerId,
    String measurementUnit = 'Square Feet',
    double? displayArea,
    double? kattaValue,
    double? dhurValue,
    double? lengthFt,
    double? lengthIn,
    double? breadthFt,
    double? breadthIn,
    String? description,
    double purchasePrice = 0.0,
    ProjectStatus status = ProjectStatus.draft,
    required String userId,
  }) async {
    // Validation rules
    if (name.trim().isEmpty) {
      throw ArgumentError('Project Name * is required.');
    }
    if (location.trim().isEmpty) {
      throw ArgumentError('Location * is required.');
    }
    if (landAreaSqFt <= 0) {
      throw ArgumentError('Land Area * must be greater than zero sq. ft.');
    }

    final newId = _uuid.v4();
    final nextCodeNum = (await _db.select(_db.projects).get()).length + 1;
    final code = 'PRJ-${nextCodeNum.toString().padLeft(3, '0')}';

    final companion = ProjectsCompanion(
      id: Value(newId),
      code: Value(code),
      name: Value(name.trim()),
      description: Value(description?.trim()),
      location: Value(location.trim()),
      status: Value(status.name),
      landownerId: Value(landownerId),
      landAreaSqFt: Value(landAreaSqFt),
      measurementUnit: Value(measurementUnit),
      displayArea: Value(displayArea),
      kattaValue: Value(kattaValue),
      dhurValue: Value(dhurValue),
      lengthFt: Value(lengthFt),
      lengthIn: Value(lengthIn),
      breadthFt: Value(breadthFt),
      breadthIn: Value(breadthIn),
      purchasePrice: Value(purchasePrice),
      actualCost: Value(purchasePrice), // Initial actual cost = purchase price
      createdAt: Value(DateTime.now()),
    );

    await _db.into(_db.projects).insert(companion);

    // Write audit log
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('CREATE_PROJECT'),
            entityType: const Value('Project'),
            entityId: Value(newId),
            details: Value('Created project "$name" ($code) in $location.'),
            timestamp: Value(DateTime.now()),
          ),
        );

    final created = await getProjectById(newId);
    return created!;
  }

  /// Update existing project details (AC-01.2: Block edits if closed)
  Future<void> updateProject(ProjectModel project, {required String userId}) async {
    final existing = await getProjectById(project.id);
    if (existing != null && existing.isClosed) {
      throw StateError('Project is closed — financial edits are disabled.');
    }

    await (_db.update(_db.projects)..where((tbl) => tbl.id.equals(project.id))).write(
      ProjectsCompanion(
        name: Value(project.name),
        description: Value(project.description),
        location: Value(project.location),
        status: Value(project.status.name),
        landownerId: Value(project.landownerId),
        landAreaSqFt: Value(project.landAreaSqFt),
        measurementUnit: Value(project.measurementUnit),
        displayArea: Value(project.displayArea),
        kattaValue: Value(project.kattaValue),
        dhurValue: Value(project.dhurValue),
        lengthFt: Value(project.lengthFt),
        lengthIn: Value(project.lengthIn),
        breadthFt: Value(project.breadthFt),
        breadthIn: Value(project.breadthIn),
        purchasePrice: Value(project.purchasePrice),
      ),
    );

    // Write audit log
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('UPDATE_PROJECT'),
            entityType: const Value('Project'),
            entityId: Value(project.id),
            details: Value('Updated project "${project.name}" details.'),
            timestamp: Value(DateTime.now()),
          ),
        );
  }

  /// Delete project with strict relation checks (Requirement 21)
  Future<void> deleteProject(String projectId, {required String userId}) async {
    final plots = await (_db.select(_db.plots)..where((tbl) => tbl.projectId.equals(projectId))).get();
    if (plots.isNotEmpty) {
      throw StateError('Cannot delete project: Project contains ${plots.length} mapped plot(s).');
    }

    final sales = await (_db.select(_db.sales)..where((tbl) => tbl.projectId.equals(projectId))).get();
    if (sales.isNotEmpty) {
      throw StateError('Cannot delete project: Project has recorded plot sales.');
    }

    final expenses = await (_db.select(_db.expenses)..where((tbl) => tbl.projectId.equals(projectId))).get();
    if (expenses.isNotEmpty) {
      throw StateError('Cannot delete project: Project has recorded expenses.');
    }

    final investments = await (_db.select(_db.projectInvestors)..where((tbl) => tbl.projectId.equals(projectId))).get();
    if (investments.isNotEmpty) {
      throw StateError('Cannot delete project: Project has active investor capital.');
    }

    await (_db.delete(_db.projects)..where((tbl) => tbl.id.equals(projectId))).go();

    // Audit log
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('DELETE_PROJECT'),
            entityType: const Value('Project'),
            entityId: Value(projectId),
            details: Value('Deleted project ID $projectId.'),
            timestamp: Value(DateTime.now()),
          ),
        );
  }
}
