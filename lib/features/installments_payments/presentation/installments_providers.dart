import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../projects/presentation/projects_providers.dart';
import '../data/installments_repository.dart';
import '../domain/installment_model.dart';
import '../domain/transaction_model.dart';

final installmentsRepositoryProvider = Provider<InstallmentsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return InstallmentsRepository(db);
});

final installmentsListStreamProvider = StreamProvider<List<InstallmentModel>>((ref) {
  final repo = ref.watch(installmentsRepositoryProvider);
  return repo.watchAllInstallments();
});

final transactionsListStreamProvider = StreamProvider<List<TransactionModel>>((ref) {
  final repo = ref.watch(installmentsRepositoryProvider);
  return repo.watchAllTransactions();
});

final saleInstallmentsStreamProvider =
    StreamProvider.family<List<InstallmentModel>, String>((ref, saleId) {
  final repo = ref.watch(installmentsRepositoryProvider);
  return repo.watchInstallmentsForSale(saleId);
});
