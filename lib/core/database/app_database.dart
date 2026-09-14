import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';

part 'app_database.g.dart';

// --- DRIFT TABLE DEFINITIONS ---

class Users extends Table {
  TextColumn get id => text()();
  /// Display name of the user.
  TextColumn get name => text().withDefault(const Constant(''))();
  /// Mobile number used as login identifier.
  TextColumn get mobileNo => text().withDefault(const Constant(''))();
  /// Legacy field kept for compatibility; mirrors mobileNo for new accounts.
  TextColumn get username => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get passwordHash => text()();
  /// Per-user random salt (hex string) for SHA-256 password hashing.
  TextColumn get salt => text().withDefault(const Constant(''))();
  TextColumn get role => text()(); // 'admin' | 'member'
  /// Sub-type for member role: 'customerBuyer' | 'investor' | 'landowner'. Null for admin.
  TextColumn get memberType => text().nullable()();
  /// FK to Buyers/Investors/Landowners table depending on memberType.
  TextColumn get linkedEntityId => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text().unique()();
  TextColumn get description => text().nullable()();
  TextColumn get location => text()();
  TextColumn get status => text()(); // ProjectStatus enum string
  TextColumn get landownerId => text().nullable().references(Landowners, #id)();
  RealColumn get landAreaSqFt => real().withDefault(const Constant(0.0))();
  TextColumn get measurementUnit => text().withDefault(const Constant('Kattha'))();
  RealColumn get displayArea => real().nullable()();
  RealColumn get kattaValue => real().nullable()();
  RealColumn get dhurValue => real().nullable()();
  RealColumn get lengthFt => real().nullable()();
  RealColumn get lengthIn => real().nullable()();
  RealColumn get breadthFt => real().nullable()();
  RealColumn get breadthIn => real().nullable()();
  RealColumn get purchasePrice => real().withDefault(const Constant(0.0))();
  RealColumn get actualCost => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Landowners extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get pan => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseAgreements extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get landownerId => text().references(Landowners, #id)();
  RealColumn get totalPrice => real()();
  DateTimeColumn get agreementDate => dateTime()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Investors extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  TextColumn get pan => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ProjectInvestors extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get investorId => text().references(Investors, #id)();
  RealColumn get investedAmount => real()();
  RealColumn get ownershipPercent => real()();
  TextColumn get ownershipMethod => text()(); // 'capitalBased' | 'manual'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get category => text()(); // ExpenseCategory enum string
  RealColumn get amount => real()();
  DateTimeColumn get expenseDate => dateTime()();
  TextColumn get vendor => text().nullable()();
  BoolColumn get isCapitalized => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Plots extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get plotNumber => text()();
  RealColumn get areaSqFt => real()();
  TextColumn get measurementUnit => text().withDefault(const Constant('Kattha'))();
  RealColumn get displayArea => real().nullable()();
  RealColumn get kattaValue => real().nullable()();
  RealColumn get dhurValue => real().nullable()();
  RealColumn get lengthFt => real().nullable()();
  RealColumn get lengthIn => real().nullable()();
  RealColumn get breadthFt => real().nullable()();
  RealColumn get breadthIn => real().nullable()();
  RealColumn get allocatedCost => real().withDefault(const Constant(0.0))();
  RealColumn get expectedPrice => real().withDefault(const Constant(0.0))();
  TextColumn get status => text()(); // PlotStatus enum string
  TextColumn get brokerName => text().nullable()();
  TextColumn get brokerPhone => text().nullable()();
  RealColumn get brokerageCharge => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Buyers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  TextColumn get pan => text().nullable()();
  TextColumn get aadhar => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get buyerId => text().references(Buyers, #id)();
  TextColumn get saleType => text()(); // SaleType enum string
  RealColumn get agreedPrice => real()();
  RealColumn get saleExpenses => real().withDefault(const Constant(0.0))();
  RealColumn get circleRateValue => real().nullable()();
  DateTimeColumn get saleDate => dateTime()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Installments extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text().nullable().references(Sales, #id)();
  TextColumn get purchaseAgreementId => text().nullable().references(PurchaseAgreements, #id)();
  IntColumn get installmentNumber => integer()();
  DateTimeColumn get dueDate => dateTime()();
  RealColumn get dueAmount => real()();
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();
  TextColumn get status => text()(); // InstallmentStatus enum string
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get installmentId => text().nullable().references(Installments, #id)();
  RealColumn get amount => real()();
  DateTimeColumn get paymentDate => dateTime()();
  TextColumn get paymentMethod => text()();
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get receiptPath => text().nullable()();
  BoolColumn get isVoided => boolean().withDefault(const Constant(false))();
  TextColumn get voidReason => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Distributions extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get investorId => text().references(Investors, #id)();
  RealColumn get amount => real()();
  DateTimeColumn get distributionDate => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class AuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get action => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get details => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// --- DRIFT DATABASE CLASS ---

@DriftDatabase(tables: [
  Users,
  Projects,
  Landowners,
  PurchaseAgreements,
  Investors,
  ProjectInvestors,
  Expenses,
  Plots,
  Buyers,
  Sales,
  Installments,
  Transactions,
  Distributions,
  AuditLogs,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(projects, projects.measurementUnit);
            await m.addColumn(projects, projects.displayArea);
            await m.addColumn(projects, projects.kattaValue);
            await m.addColumn(projects, projects.dhurValue);

            await m.addColumn(plots, plots.measurementUnit);
            await m.addColumn(plots, plots.displayArea);
            await m.addColumn(plots, plots.kattaValue);
            await m.addColumn(plots, plots.dhurValue);
          }
          if (from < 3) {
            await m.addColumn(projects, projects.landownerId);
          }
          if (from < 4) {
            await m.addColumn(plots, plots.lengthFt);
            await m.addColumn(plots, plots.lengthIn);
            await m.addColumn(plots, plots.breadthFt);
            await m.addColumn(plots, plots.breadthIn);
          }
          if (from < 5) {
            await m.addColumn(projects, projects.lengthFt);
            await m.addColumn(projects, projects.lengthIn);
            await m.addColumn(projects, projects.breadthFt);
            await m.addColumn(projects, projects.breadthIn);
          }
          if (from < 6) {
            await m.addColumn(users, users.name);
            await m.addColumn(users, users.mobileNo);
            await m.addColumn(users, users.salt);
            await m.addColumn(users, users.memberType);
            await m.addColumn(users, users.linkedEntityId);
          }
          if (from < 7) {
            await m.addColumn(plots, plots.brokerName);
            await m.addColumn(plots, plots.brokerPhone);
            await m.addColumn(plots, plots.brokerageCharge);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON;');
          await customStatement('PRAGMA journal_mode = WAL;');
          await customStatement('PRAGMA synchronous = NORMAL;');
          await customStatement('PRAGMA cache_size = -488000;'); // 488MB memory cache
          await customStatement('PRAGMA temp_store = MEMORY;');
          try {
            await customStatement('ALTER TABLE plots ADD COLUMN length_ft REAL;');
          } catch (_) {}
          try {
            await customStatement('ALTER TABLE plots ADD COLUMN length_in REAL;');
          } catch (_) {}
          try {
            await customStatement('ALTER TABLE plots ADD COLUMN breadth_ft REAL;');
          } catch (_) {}
          try {
            await customStatement('ALTER TABLE plots ADD COLUMN breadth_in REAL;');
          } catch (_) {}
          try {
            await customStatement('ALTER TABLE projects ADD COLUMN length_ft REAL;');
          } catch (_) {}
          try {
            await customStatement('ALTER TABLE projects ADD COLUMN length_in REAL;');
          } catch (_) {}
          try {
            await customStatement('ALTER TABLE projects ADD COLUMN breadth_ft REAL;');
          } catch (_) {}
          try {
            await customStatement('ALTER TABLE projects ADD COLUMN breadth_in REAL;');
          } catch (_) {}
          try {
            await customStatement('CREATE UNIQUE INDEX IF NOT EXISTS idx_projects_name_unique ON projects(LOWER(TRIM(name)));');
          } catch (_) {}
          // Safe migration for users auth columns (v6)
          try {
            await customStatement('ALTER TABLE users ADD COLUMN name TEXT NOT NULL DEFAULT \'\';');
          } catch (_) {}
          try {
            await customStatement('ALTER TABLE users ADD COLUMN mobile_no TEXT NOT NULL DEFAULT \'\';');
          } catch (_) {}
          try {
            await customStatement('ALTER TABLE users ADD COLUMN salt TEXT NOT NULL DEFAULT \'\';');
          } catch (_) {}
          try {
            await customStatement('ALTER TABLE users ADD COLUMN member_type TEXT;');
          } catch (_) {}
          try {
            await customStatement('ALTER TABLE users ADD COLUMN linked_entity_id TEXT;');
          } catch (_) {}
          try {
            await customStatement('CREATE UNIQUE INDEX IF NOT EXISTS idx_users_mobile_no ON users(mobile_no) WHERE mobile_no != \'\';');
          } catch (_) {}
          try {
            await customStatement('CREATE INDEX IF NOT EXISTS idx_plots_project_id ON plots(project_id);');
            await customStatement('CREATE INDEX IF NOT EXISTS idx_expenses_project_id ON expenses(project_id);');
            await customStatement('CREATE INDEX IF NOT EXISTS idx_sales_project_id ON sales(project_id);');
            await customStatement('CREATE INDEX IF NOT EXISTS idx_sales_buyer_id ON sales(buyer_id);');
            await customStatement('CREATE INDEX IF NOT EXISTS idx_installments_sale_id ON installments(sale_id);');
            await customStatement('CREATE INDEX IF NOT EXISTS idx_installments_agreement_id ON installments(purchase_agreement_id);');
            await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_project_id ON transactions(project_id);');
            await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_installment_id ON transactions(installment_id);');
            await customStatement('CREATE INDEX IF NOT EXISTS idx_project_investors_project_id ON project_investors(project_id);');
            await customStatement('CREATE INDEX IF NOT EXISTS idx_distributions_project_id ON distributions(project_id);');
            await customStatement('CREATE INDEX IF NOT EXISTS idx_audit_logs_timestamp ON audit_logs(timestamp DESC);');
          } catch (_) {}
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final customFolder = Directory(p.join(dbFolder.path, AppConstants.appDataFolder));
    if (!await customFolder.exists()) {
      await customFolder.create(recursive: true);
    }
    final file = File(p.join(customFolder.path, 'land_investment.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
