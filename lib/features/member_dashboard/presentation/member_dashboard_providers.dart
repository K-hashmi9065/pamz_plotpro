import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../plots/domain/plot_model.dart';
import '../../plots/presentation/plots_providers.dart';

/// Helper to check if two phone numbers match (ignoring country code, spaces, +)
bool _phoneMatches(String? p1, String? p2) {
  if (p1 == null || p2 == null) return false;
  final d1 = p1.replaceAll(RegExp(r'\D'), '');
  final d2 = p2.replaceAll(RegExp(r'\D'), '');
  if (d1.isEmpty || d2.isEmpty) return false;
  if (d1 == d2) return true;
  if (d1.length >= 10 && d2.length >= 10) {
    return d1.substring(d1.length - 10) == d2.substring(d2.length - 10);
  }
  return false;
}

// ── Buyer Dashboard ──────────────────────────────────────────────────────────

/// Resolved Buyer IDs for the logged-in user.
final currentBuyerIdsProvider = StreamProvider<List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  final db = ref.watch(appDatabaseProvider);

  return db.select(db.buyers).watch().map((buyers) {
    final ids = <String>{};
    if (user.linkedEntityId != null) {
      ids.add(user.linkedEntityId!);
    }
    for (final b in buyers) {
      if (_phoneMatches(b.phone, user.mobileNo) ||
          b.name.trim().toLowerCase() == user.name.trim().toLowerCase()) {
        ids.add(b.id);
      }
    }
    return ids.toList();
  });
});

/// All sales for the logged-in buyer.
final buyerSalesProvider = StreamProvider<List<Sale>>((ref) {
  final idsAsync = ref.watch(currentBuyerIdsProvider);
  final ids = idsAsync.value ?? [];
  if (ids.isEmpty) return Stream.value([]);
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.sales)..where((s) => s.buyerId.isIn(ids))).watch();
});

/// Resolved Plots for a specific sale.
final salePlotsProvider =
    StreamProvider.family<List<PlotModel>, Sale>((ref, sale) {
  final db = ref.watch(appDatabaseProvider);
  final plotsRepo = ref.watch(plotsRepositoryProvider);

  return db.select(db.auditLogs).watch().asyncMap((logs) async {
    final linkedPlotIds = <String>{};
    for (final log in logs) {
      if (log.entityType == 'Plot' &&
          log.action == 'LINK_PLOT_SALE' &&
          log.details.contains('SaleId:${sale.id}')) {
        linkedPlotIds.add(log.entityId);
      }
    }

    final query = db.select(db.plots)
      ..where((tbl) => tbl.projectId.equals(sale.projectId));
    final plotRows = await query.get();
    final allPlots = plotRows.map((r) => plotsRepo.toModel(r)).toList();

    final matched =
        allPlots.where((p) => linkedPlotIds.contains(p.id)).toList();
    if (matched.isNotEmpty) return matched;

    if (sale.saleType != 'wholeLand') {
      final priceMatches = allPlots
          .where((p) =>
              !p.isRoad && (p.expectedPrice - sale.agreedPrice).abs() < 1.0)
          .toList();
      if (priceMatches.length == 1) {
        return priceMatches;
      }
      final soldOrBooked = allPlots
          .where((p) =>
              !p.isRoad &&
              (p.status == PlotStatus.saleAgreement ||
                  p.status == PlotStatus.sold ||
                  p.status == PlotStatus.booked))
          .toList();
      if (soldOrBooked.length == 1) {
        return soldOrBooked;
      }
    }
    return <PlotModel>[];
  });
});

/// Installments for a specific sale.
final saleInstallmentsProvider =
    StreamProvider.family<List<Installment>, String>((ref, saleId) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.installments)
        ..where((i) => i.saleId.equals(saleId))
        ..orderBy([(i) => drift.OrderingTerm.asc(i.installmentNumber)]))
      .watch();
});

/// Direct Payment Transactions for a specific sale.
final saleTransactionsProvider =
    StreamProvider.family<List<Transaction>, String>((ref, saleId) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.transactions).watch().asyncMap((allTxs) async {
    final saleInsts = await (db.select(db.installments)
          ..where((i) => i.saleId.equals(saleId)))
        .get();
    final instIds = saleInsts.map((i) => i.id).toSet();

    final txs = allTxs.where((t) {
      if (t.isVoided) return false;
      return t.installmentId != null && instIds.contains(t.installmentId);
    }).toList()
      ..sort((a, b) {
        final cmp = b.paymentDate.compareTo(a.paymentDate);
        if (cmp != 0) return cmp;
        return b.createdAt.compareTo(a.createdAt);
      });

    return txs;
  });
});

/// Transactions for the buyer.
final buyerTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.transactions)
        ..orderBy([
          (t) => drift.OrderingTerm.desc(t.paymentDate),
        ]))
      .watch();
});

/// Payment Transactions for a specific purchase agreement (or project).
final agreementTransactionsProvider =
    StreamProvider.family<List<Transaction>, String>((ref, agreementId) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.transactions).watch().asyncMap((allTxs) async {
    final allInsts = await db.select(db.installments).get();
    final matchingInstIds = allInsts
        .where((i) => i.purchaseAgreementId == agreementId)
        .map((i) => i.id)
        .toSet();

    String? projectId;
    if (agreementId.startsWith('AUTO_')) {
      projectId = agreementId.replaceFirst('AUTO_', '');
    } else {
      final pa = await (db.select(db.purchaseAgreements)
            ..where((tbl) => tbl.id.equals(agreementId)))
        .getSingleOrNull();
      projectId = pa?.projectId;
    }

    if (projectId != null) {
      final projectPas = await (db.select(db.purchaseAgreements)
            ..where((tbl) => tbl.projectId.equals(projectId!)))
          .get();
      final projectPaIds = projectPas.map((p) => p.id).toSet();
      projectPaIds.add('AUTO_$projectId');

      final projectInstIds = allInsts
          .where((i) =>
              i.purchaseAgreementId != null &&
              projectPaIds.contains(i.purchaseAgreementId))
          .map((i) => i.id);
      matchingInstIds.addAll(projectInstIds);
    }

    final txs = allTxs.where((t) {
      if (t.isVoided) return false;
      if (t.installmentId != null && matchingInstIds.contains(t.installmentId)) {
        return true;
      }
      if (projectId != null && t.projectId == projectId && t.installmentId == null) {
        return true;
      }
      return false;
    }).toList()
      ..sort((a, b) {
        final cmp = b.paymentDate.compareTo(a.paymentDate);
        if (cmp != 0) return cmp;
        return b.createdAt.compareTo(a.createdAt);
      });

    return txs;
  });
});

// ── Landowner Dashboard ──────────────────────────────────────────────────────

/// Resolved Landowner IDs for the logged-in user.
final currentLandownerIdsProvider = StreamProvider<List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  final db = ref.watch(appDatabaseProvider);

  return db.select(db.landowners).watch().map((landowners) {
    final ids = <String>{};
    if (user.linkedEntityId != null) {
      ids.add(user.linkedEntityId!);
    }
    final uName = user.name.trim().toLowerCase();
    for (final l in landowners) {
      final lName = l.name.trim().toLowerCase();
      if (_phoneMatches(l.phone, user.mobileNo) ||
          lName == uName ||
          lName.contains(uName) ||
          uName.contains(lName)) {
        ids.add(l.id);
      }
    }
    return ids.toList();
  });
});

/// Projects linked to the logged-in landowner.
final landownerProjectsProvider = StreamProvider<List<Project>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  final idsAsync = ref.watch(currentLandownerIdsProvider);
  final ids = idsAsync.value ?? [];
  final db = ref.watch(appDatabaseProvider);

  return db.select(db.projects).watch().map((projects) {
    return projects.where((p) {
      if (p.landownerId != null && ids.contains(p.landownerId)) return true;
      return false;
    }).toList();
  });
});

/// Purchase agreements for the logged-in landowner.
final landownerAgreementsProvider =
    StreamProvider<List<PurchaseAgreement>>((ref) {
  final idsAsync = ref.watch(currentLandownerIdsProvider);
  final ids = idsAsync.value ?? [];
  final projectsAsync = ref.watch(landownerProjectsProvider);
  final projectIds = (projectsAsync.value ?? []).map((p) => p.id).toSet();

  if (ids.isEmpty && projectIds.isEmpty) return Stream.value([]);
  final db = ref.watch(appDatabaseProvider);

  return db.select(db.purchaseAgreements).watch().map((agreements) {
    return agreements.where((a) {
      return ids.contains(a.landownerId) || projectIds.contains(a.projectId);
    }).toList();
  });
});

/// Installments for a specific purchase agreement (and fallback matching by project).
final agreementInstallmentsProvider =
    StreamProvider.family<List<Installment>, String>((ref, agreementId) {
  final db = ref.watch(appDatabaseProvider);

  return db.select(db.installments).watch().asyncMap((allInsts) async {
    // 1. Direct match by agreement ID
    final directMatches = allInsts
        .where((i) => i.purchaseAgreementId == agreementId)
        .toList()
      ..sort((a, b) => a.installmentNumber.compareTo(b.installmentNumber));

    if (directMatches.isNotEmpty) {
      return directMatches;
    }

    // 2. Fallback: match by project agreements or project ID
    final pa = await (db.select(db.purchaseAgreements)
          ..where((tbl) => tbl.id.equals(agreementId)))
        .getSingleOrNull();

    if (pa != null) {
      final projectPas = await (db.select(db.purchaseAgreements)
            ..where((tbl) => tbl.projectId.equals(pa.projectId)))
          .get();
      final projectPaIds = projectPas.map((p) => p.id).toSet();
      projectPaIds.add('AUTO_${pa.projectId}');

      final projectMatches = allInsts
          .where((i) =>
              i.purchaseAgreementId != null &&
              projectPaIds.contains(i.purchaseAgreementId))
          .toList()
        ..sort((a, b) => a.installmentNumber.compareTo(b.installmentNumber));

      if (projectMatches.isNotEmpty) {
        return projectMatches;
      }
    } else if (agreementId.startsWith('AUTO_')) {
      final prjId = agreementId.replaceFirst('AUTO_', '');
      final projectPas = await (db.select(db.purchaseAgreements)
            ..where((tbl) => tbl.projectId.equals(prjId)))
          .get();
      final projectPaIds = projectPas.map((p) => p.id).toSet();
      projectPaIds.add(agreementId);

      final projectMatches = allInsts
          .where((i) =>
              i.purchaseAgreementId != null &&
              projectPaIds.contains(i.purchaseAgreementId))
          .toList()
        ..sort((a, b) => a.installmentNumber.compareTo(b.installmentNumber));

      if (projectMatches.isNotEmpty) {
        return projectMatches;
      }
    }

    return directMatches;
  });
});

// ── Investor Dashboard ───────────────────────────────────────────────────────

/// Resolved Investor IDs for the logged-in user.
final currentInvestorIdsProvider = StreamProvider<List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  final db = ref.watch(appDatabaseProvider);

  return db.select(db.investors).watch().map((investors) {
    final ids = <String>{};
    if (user.linkedEntityId != null) {
      ids.add(user.linkedEntityId!);
    }
    final uName = user.name.trim().toLowerCase();
    for (final i in investors) {
      final iName = i.name.trim().toLowerCase();
      if (_phoneMatches(i.phone, user.mobileNo) ||
          iName == uName ||
          iName.contains(uName) ||
          uName.contains(iName)) {
        ids.add(i.id);
      }
    }
    return ids.toList();
  });
});

/// Project-investor records for the logged-in investor.
final investorProjectsProvider =
    StreamProvider<List<ProjectInvestor>>((ref) {
  final idsAsync = ref.watch(currentInvestorIdsProvider);
  final ids = idsAsync.value ?? [];
  if (ids.isEmpty) return Stream.value([]);
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.projectInvestors)
        ..where((pi) => pi.investorId.isIn(ids)))
      .watch();
});

/// Distributions (withdrawals) for the logged-in investor.
/// Gathers both formal distributions table and audit log payouts.
final investorDistributionsProvider =
    StreamProvider<List<Distribution>>((ref) {
  final idsAsync = ref.watch(currentInvestorIdsProvider);
  final ids = idsAsync.value ?? [];
  if (ids.isEmpty) return Stream.value([]);
  final db = ref.watch(appDatabaseProvider);

  return db.select(db.auditLogs).watch().asyncMap((logs) async {
    // 1. Explicit rows in distributions table
    final explicit = await (db.select(db.distributions)
          ..where((d) => d.investorId.isIn(ids))
          ..orderBy([(d) => drift.OrderingTerm.desc(d.distributionDate)]))
        .get();

    final result = <Distribution>[...explicit];
    final explicitIds = explicit.map((e) => e.id).toSet();

    // 2. Project investor records for this investor
    final projectInvestors = await (db.select(db.projectInvestors)
          ..where((pi) => pi.investorId.isIn(ids)))
        .get();
    final piMap = {for (final pi in projectInvestors) pi.id: pi};

    // 3. Scan audit logs for DISBURSE_INVESTOR_PAYOUT
    for (final log in logs) {
      if (log.action == 'DISBURSE_INVESTOR_PAYOUT') {
        ProjectInvestor? matchedPi = piMap[log.entityId];
        if (matchedPi == null) {
          for (final pi in projectInvestors) {
            if (log.details.contains(pi.id)) {
              matchedPi = pi;
              break;
            }
          }
        }

        if (matchedPi != null && !explicitIds.contains(log.id)) {
          final match = RegExp(r'₹([0-9.,]+)').firstMatch(log.details);
          if (match != null) {
            final amtStr = match.group(1)!.replaceAll(',', '');
            final amt = double.tryParse(amtStr) ?? 0.0;
            if (amt > 0) {
              result.add(
                Distribution(
                  id: log.id,
                  projectId: matchedPi.projectId,
                  investorId: matchedPi.investorId,
                  amount: amt,
                  distributionDate: log.timestamp,
                  notes: log.details,
                  createdBy: log.userId,
                  createdAt: log.timestamp,
                ),
              );
            }
          }
        }
      }
    }

    result.sort((a, b) => b.distributionDate.compareTo(a.distributionDate));
    return result;
  });
});

/// Project name lookup by id.
final projectByIdProvider =
    FutureProvider.family<Project?, String>((ref, projectId) async {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.projects)
        ..where((p) => p.id.equals(projectId)))
      .getSingleOrNull();
});
