import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../../core/services/pdf/brokerage_pdf_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/plot_model.dart';

class BrokeragePdfDialog extends StatefulWidget {
  final PlotModel plot;
  final String projectName;
  final String projectCode;
  final String projectLocation;

  const BrokeragePdfDialog({
    super.key,
    required this.plot,
    required this.projectName,
    required this.projectCode,
    required this.projectLocation,
  });

  static Future<void> show(
    BuildContext context, {
    required PlotModel plot,
    required String projectName,
    required String projectCode,
    required String projectLocation,
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
            width: 850,
            height: 720,
            child: BrokeragePdfDialog(
              plot: plot,
              projectName: projectName,
              projectCode: projectCode,
              projectLocation: projectLocation,
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<BrokeragePdfDialog> createState() => _BrokeragePdfDialogState();
}

class _BrokeragePdfDialogState extends State<BrokeragePdfDialog> {
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
    final bytes = await BrokeragePdfService.generateBrokerageVoucherPdf(
      plot: widget.plot,
      projectName: widget.projectName,
      projectCode: widget.projectCode,
      projectLocation: widget.projectLocation,
    );

    if (mounted) {
      _pdfBytesNotifier.value = bytes;
      _isGeneratingNotifier.value = false;
    }
  }

  Future<void> _downloadPdfFile() async {
    final pdfBytes = _pdfBytesNotifier.value;
    if (pdfBytes == null) return;
    final brokerSlug = (widget.plot.brokerName ?? 'Broker').replaceAll(' ', '_');
    final filename = 'Brokerage_Voucher_${widget.projectCode}_Plot_${widget.plot.plotNumber}_$brokerSlug.pdf';
    final savedPath = await BrokeragePdfService.savePdfToDownloads(
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
    final brokerSlug = (widget.plot.brokerName ?? 'Broker').replaceAll(' ', '_');
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Brokerage_${widget.projectCode}_Plot_${widget.plot.plotNumber}_$brokerSlug.pdf',
    );
  }

  Future<void> _shareWhatsApp() async {
    final pdfBytes = _pdfBytesNotifier.value;
    if (pdfBytes != null) {
      final brokerSlug = (widget.plot.brokerName ?? 'Broker').replaceAll(' ', '_');
      final filename = 'Brokerage_Voucher_${widget.projectCode}_Plot_${widget.plot.plotNumber}_$brokerSlug.pdf';
      final savedPath = await BrokeragePdfService.savePdfToDownloads(
        pdfBytes: pdfBytes,
        filename: filename,
      );
      if (mounted && savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF saved to Downloads! Opening WhatsApp... Attach the saved PDF from Downloads.'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }

    await BrokeragePdfService.shareViaWhatsApp(
      plot: widget.plot,
      projectName: widget.projectName,
      projectCode: widget.projectCode,
      projectLocation: widget.projectLocation,
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
              'Plot Brokerage Voucher PDF (Plot #${widget.plot.plotNumber})',
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
