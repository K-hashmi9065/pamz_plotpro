import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/hive_service.dart';

class PdfHeaderNotifier extends StateNotifier<String> {
  PdfHeaderNotifier() : super(HiveService.getPdfHeaderTitle());

  Future<void> updateHeaderTitle(String newTitle) async {
    final trimmed = newTitle.trim().isEmpty ? 'PAMZ PlotPro' : newTitle.trim();
    await HiveService.setPdfHeaderTitle(trimmed);
    state = trimmed;
  }

  Future<void> resetToDefault() async {
    await HiveService.setPdfHeaderTitle('PAMZ PlotPro');
    state = 'PAMZ PlotPro';
  }
}

final pdfHeaderTitleProvider = StateNotifierProvider<PdfHeaderNotifier, String>((ref) {
  return PdfHeaderNotifier();
});
