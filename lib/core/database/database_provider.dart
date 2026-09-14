import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

/// Single source of truth for AppDatabase instance across the entire app.
/// Ensures single open SQLite connection, avoids race conditions and memory leaks.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
