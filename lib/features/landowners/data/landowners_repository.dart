import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../projects/domain/project_model.dart';
import '../domain/landowner_model.dart';
import '../domain/purchase_agreement_model.dart';

class LandownersRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  LandownersRepository(this._db);

  LandownerModel _toLandownerModel(Landowner row) {
    return LandownerModel(
      id: row.id,
      name: row.name,
      phone: row.phone,
      email: row.email,
      address: row.address,
      pan: row.pan,
      createdAt: row.createdAt,
    );
  }

  PurchaseAgreementModel _toAgreementModel(PurchaseAgreement row) {
    return PurchaseAgreementModel(
      id: row.id,
      projectId: row.projectId,
      landownerId: row.landownerId,
      totalPrice: row.totalPrice,
      agreementDate: row.agreementDate,
      status: row.status,
      createdAt: row.createdAt,
    );
  }

  /// Watch stream of all landowners
  Stream<List<LandownerModel>> watchAllLandowners() {
    return _db.select(_db.landowners).watch().map(
          (rows) => rows.map(_toLandownerModel).toList(),
        );
  }

  /// Register a new landowner (Validation: Name *, Phone *)
  Future<LandownerModel> createLandowner({
    required String name,
    required String phone,
    String? email,
    String? address,
    String? pan,
    required String userId,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Landowner Name * is required.');
    }
    if (phone.trim().isEmpty) {
      throw ArgumentError('Phone Number * is required.');
    }

    final id = _uuid.v4();
    await _db.into(_db.landowners).insert(
          LandownersCompanion(
            id: Value(id),
            name: Value(name.trim()),
            phone: Value(phone.trim()),
            email: Value(email?.trim()),
            address: Value(address?.trim()),
            pan: Value(pan?.trim()),
            createdAt: Value(DateTime.now()),
          ),
        );

    // Write audit log
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('CREATE_LANDOWNER'),
            entityType: const Value('Landowner'),
            entityId: Value(id),
            details: Value('Registered landowner "$name" ($phone).'),
            timestamp: Value(DateTime.now()),
          ),
        );

    final row = await (_db.select(_db.landowners)..where((tbl) => tbl.id.equals(id))).getSingle();
    return _toLandownerModel(row);
  }

  /// Watch purchase agreements for project
  Stream<List<PurchaseAgreementModel>> watchAgreementsForProject(String projectId) {
    final query = _db.select(_db.purchaseAgreements)..where((tbl) => tbl.projectId.equals(projectId));
    return query.watch().map((rows) => rows.map(_toAgreementModel).toList());
  }

  /// Watch all projects associated with a landowner
  Stream<List<ProjectModel>> watchLandownerProjects(String landownerId) {
    final query = _db.select(_db.projects)..where((tbl) => tbl.landownerId.equals(landownerId));
    return query.watch().map((rows) {
      return rows.map((row) {
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
          landAreaSqFt: row.landAreaSqFt,
          measurementUnit: row.measurementUnit,
          displayArea: row.displayArea,
          kattaValue: row.kattaValue,
          dhurValue: row.dhurValue,
          purchasePrice: row.purchasePrice,
          actualCost: row.actualCost,
          createdAt: row.createdAt,
        );
      }).toList();
    });
  }

  /// Create purchase agreement and build landowner payment schedule (PRD §6.3 / AC-02.1)
  Future<PurchaseAgreementModel> createPurchaseAgreement({
    required String projectId,
    required String landownerId,
    required double totalPrice,
    required DateTime agreementDate,
    required int installmentCount,
    required String userId,
  }) async {
    if (totalPrice <= 0) {
      throw ArgumentError('Total Purchase Price * must be greater than zero.');
    }
    if (installmentCount <= 0) {
      throw ArgumentError('Installment Count must be at least 1.');
    }

    final agreementId = _uuid.v4();
    await _db.into(_db.purchaseAgreements).insert(
          PurchaseAgreementsCompanion(
            id: Value(agreementId),
            projectId: Value(projectId),
            landownerId: Value(landownerId),
            totalPrice: Value(totalPrice),
            agreementDate: Value(agreementDate),
            status: const Value('ACTIVE'),
            createdAt: Value(DateTime.now()),
          ),
        );

    // Create installment schedule records
    final perInstallmentAmount = totalPrice / installmentCount;
    for (int i = 1; i <= installmentCount; i++) {
      final dueDate = agreementDate.add(Duration(days: 30 * i));
      await _db.into(_db.installments).insert(
            InstallmentsCompanion(
              id: Value(_uuid.v4()),
              purchaseAgreementId: Value(agreementId),
              installmentNumber: Value(i),
              dueDate: Value(dueDate),
              dueAmount: Value(perInstallmentAmount),
              paidAmount: const Value(0.0),
              status: const Value('PENDING'),
              createdAt: Value(DateTime.now()),
            ),
          );
    }

    // Write audit log
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('CREATE_PURCHASE_AGREEMENT'),
            entityType: const Value('PurchaseAgreement'),
            entityId: Value(agreementId),
            details: Value('Created purchase agreement for ₹$totalPrice with $installmentCount installments.'),
            timestamp: Value(DateTime.now()),
          ),
        );

    final row = await (_db.select(_db.purchaseAgreements)..where((tbl) => tbl.id.equals(agreementId))).getSingle();
    return _toAgreementModel(row);
  }

  /// Watch stream of all purchase agreements
  Stream<List<PurchaseAgreementModel>> watchAllPurchaseAgreements() {
    return _db.select(_db.purchaseAgreements).watch().map(
          (rows) => rows.map(_toAgreementModel).toList(),
        );
  }

  /// Update landowner profile
  Future<LandownerModel> updateLandowner({
    required String id,
    required String name,
    required String phone,
    String? email,
    String? address,
    String? pan,
    required String userId,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Landowner Name * is required.');
    }
    if (phone.trim().isEmpty) {
      throw ArgumentError('Phone Number * is required.');
    }

    await (_db.update(_db.landowners)..where((tbl) => tbl.id.equals(id))).write(
      LandownersCompanion(
        name: Value(name.trim()),
        phone: Value(phone.trim()),
        email: Value(email?.trim()),
        address: Value(address?.trim()),
        pan: Value(pan?.trim()),
      ),
    );

    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('UPDATE_LANDOWNER'),
            entityType: const Value('Landowner'),
            entityId: Value(id),
            details: Value('Updated landowner "$name" ($phone).'),
            timestamp: Value(DateTime.now()),
          ),
        );

    final row = await (_db.select(_db.landowners)..where((tbl) => tbl.id.equals(id))).getSingle();
    return _toLandownerModel(row);
  }

  /// Delete landowner with cascade cleanup / unlinking (Requirement 20 / Admin Override)
  Future<void> deleteLandowner(String landownerId, {required String userId, bool cascade = false}) async {
    final lo = await (_db.select(_db.landowners)..where((tbl) => tbl.id.equals(landownerId))).getSingleOrNull();
    final landownerName = lo?.name ?? landownerId;

    if (!cascade) {
      final linkedProjects = await (_db.select(_db.projects)..where((tbl) => tbl.landownerId.equals(landownerId))).get();
      if (linkedProjects.isNotEmpty) {
        throw StateError('Cannot delete landowner: Landowner is associated with ${linkedProjects.length} project(s).');
      }
      final linkedAgreements = await (_db.select(_db.purchaseAgreements)..where((tbl) => tbl.landownerId.equals(landownerId))).get();
      if (linkedAgreements.isNotEmpty) {
        throw StateError('Cannot delete landowner: Landowner has existing purchase agreement(s).');
      }
    } else {
      // Unlink landowner from any projects
      await (_db.update(_db.projects)..where((tbl) => tbl.landownerId.equals(landownerId))).write(
        const ProjectsCompanion(
          landownerId: Value(null),
        ),
      );
      // Delete associated purchase agreements
      await (_db.delete(_db.purchaseAgreements)..where((tbl) => tbl.landownerId.equals(landownerId))).go();
    }

    await (_db.delete(_db.landowners)..where((tbl) => tbl.id.equals(landownerId))).go();

    // Audit log
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('DELETE_LANDOWNER'),
            entityType: const Value('Landowner'),
            entityId: Value(landownerId),
            details: Value('Deleted landowner "$landownerName" (ID: $landownerId).'),
            timestamp: Value(DateTime.now()),
          ),
        );
  }
}
