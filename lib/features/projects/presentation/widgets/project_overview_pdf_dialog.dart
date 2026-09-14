import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../../core/services/pdf/project_overview_pdf_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../expenses/domain/expense_model.dart';
import '../../../plots/domain/plot_model.dart';
import '../../../profit_loss_settlement/domain/profit_loss_models.dart';
import '../../domain/project_model.dart';

class ProjectOverviewPdfDialog extends StatefulWidget {
  final ProjectModel project;
  final List<PlotModel> plots;
  final List<ExpenseModel> expenses;
  final List<ProjectProfitLossModel> pnlList;

  const ProjectOverviewPdfDialog({
    super.key,
    required this.project,
    required this.plots,
    required this.expenses,
    this.pnlList = const [],
  });

  static Future<void> show(
    BuildContext context, {
    required ProjectModel project,
    required List<PlotModel> plots,
    required List<ExpenseModel> expenses,
    List<ProjectProfitLossModel> pnlList = const [],
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        backgroundColor: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 900,
            height: 750,
            child: ProjectOverviewPdfDialog(
              project: project,
              plots: plots,
              expenses: expenses,
              pnlList: pnlList,
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<ProjectOverviewPdfDialog> createState() => _ProjectOverviewPdfDialogState();
}

class _ProjectOverviewPdfDialogState extends State<ProjectOverviewPdfDialog> {
  final ValueNotifier<Uint8List?> _pdfBytesNotifier = ValueNotifier<Uint8List?>(null);
  final ValueNotifier<bool> _isGeneratingNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  @override
  void dispose() {
    _pdfBytesNotifier.dispose();
    _isGeneratingNotifier.dispose();
    super.dispose();
  }

  Future<void> _generatePdf() async {
    final bytes = await ProjectOverviewPdfService.generateProjectOverviewPdf(
      project: widget.project,
      plots: widget.plots,
      expenses: widget.expenses,
      pnlList: widget.pnlList,
    );

    if (mounted) {
      _pdfBytesNotifier.value = bytes;
      _isGeneratingNotifier.value = false;
    }
  }

  Future<void> _downloadPdfFile() async {
    final pdfBytes = _pdfBytesNotifier.value;
    if (pdfBytes == null) return;
    final filename = 'Project_Overview_${widget.project.code}_${widget.project.name.replaceAll(' ', '_')}.pdf';
    final savedPath = await ProjectOverviewPdfService.savePdfToDownloads(
      pdfBytes: pdfBytes,
      filename: filename,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            savedPath != null
                ? 'PDF saved to Downloads: $savedPath'
                : 'PDF downloaded successfully!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _sharePdfFile() async {
    final pdfBytes = _pdfBytesNotifier.value;
    if (pdfBytes == null) return;
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Project_Overview_${widget.project.code}_${widget.project.name.replaceAll(' ', '_')}.pdf',
    );
  }

  Future<void> _shareWhatsApp() async {
    final pdfBytes = _pdfBytesNotifier.value;
    if (pdfBytes != null) {
      final filename = 'Project_Overview_${widget.project.code}_${widget.project.name.replaceAll(' ', '_')}.pdf';
      final savedPath = await ProjectOverviewPdfService.savePdfToDownloads(
        pdfBytes: pdfBytes,
        filename: filename,
      );
      if (mounted && savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF saved to Downloads! Opening WhatsApp... Attach the saved PDF from Downloads.'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }

    await ProjectOverviewPdfService.shareViaWhatsApp(
      project: widget.project,
      plots: widget.plots,
      expenses: widget.expenses,
      pnlList: widget.pnlList,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: _pdfBytesNotifier,
      builder: (context, pdfBytes, _) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            title: Text(
              'Project Master & Land Overview PDF (${widget.project.code})',
              style: AppTypography.cardTitle,
            ),
            backgroundColor: AppColors.surface,
            elevation: 1,
            actions: [
              IconButton(
                icon: const Icon(Icons.download, color: AppColors.accent),
                tooltip: 'Download / Save PDF',
                onPressed: pdfBytes == null ? null : _downloadPdfFile,
              ),
              IconButton(
                icon: const Icon(Icons.share, color: AppColors.accent),
                tooltip: 'Share PDF Document',
                onPressed: pdfBytes == null ? null : _sharePdfFile,
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: pdfBytes == null ? null : _shareWhatsApp,
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text('Share via WhatsApp'),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: ValueListenableBuilder<bool>(
            valueListenable: _isGeneratingNotifier,
            builder: (context, isGenerating, _) {
              if (isGenerating || pdfBytes == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return PdfPreview(
                build: (format) => pdfBytes,
                allowPrinting: true,
                allowSharing: true,
                canChangeOrientation: false,
                canChangePageFormat: false,
              );
            },
          ),
        );
      },
    );
  }
}
