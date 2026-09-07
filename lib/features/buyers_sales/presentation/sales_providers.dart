import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../projects/presentation/projects_providers.dart';
import '../data/sales_repository.dart';
import '../domain/buyer_model.dart';
import '../domain/sale_model.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SalesRepository(db);
});

final buyersListStreamProvider = StreamProvider<List<BuyerModel>>((ref) {
  final repo = ref.watch(salesRepositoryProvider);
  return repo.watchAllBuyers();
});

final salesListStreamProvider = StreamProvider<List<SaleModel>>((ref) {
  final repo = ref.watch(salesRepositoryProvider);
  return repo.watchAllSales();
});
