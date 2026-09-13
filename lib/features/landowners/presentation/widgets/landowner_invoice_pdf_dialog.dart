import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/pdf/landowner_invoice_pdf_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../../projects/domain/project_model.dart';
import '../../domain/landowner_model.dart';
import '../../domain/purchase_agreement_model.dart';

class LandownerInvoicePdfDialog extends StatefulWidget {
  final ProjectModel project;
  final PurchaseAgreementModel agreement;
  final LandownerModel? landowner;
  final List<Transaction> transactions;

  const LandownerInvoicePdfDialog({
    super.key,
    required this.project,
    required this.agreement,
    this.landowner,
    required this.transactions,
  });

  static Future<void> show(
    BuildContext context, {
    required ProjectModel project,
    required PurchaseAgreementModel agreement,
    LandownerModel? landowner,
    required List<Transaction> transactions,
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
            width: 920,
            height: 750,
            child: LandownerInvoicePdfDialog(
              project: project,
              agreement: agreement,
              landowner: landowner,
              transactions: transactions,
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<LandownerInvoicePdfDialog> createState() =>
      _LandownerInvoicePdfDialogState();
}

class _LandownerInvoicePdfDialogState extends State<LandownerInvoicePdfDialog> {
  final ValueNotifier<Uint8List?> _pdfBytesNotifier =
      ValueNotifier<Uint8List?>(null);
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
    LandownerModel? landowner = widget.landowner;
    final landownerId = widget.project.landownerId ?? widget.agreement.landownerId;
    if (landowner == null || landowner.phone.isEmpty) {
      final db = AppDatabase();
      final lRow = await (db.select(db.landowners)..where((l) => l.id.equals(landownerId))).getSingleOrNull();
      if (lRow != null) {
        landowner = LandownerModel(
          id: lRow.id,
          name: lRow.name,
          phone: lRow.phone,
          email: lRow.email,
          pan: lRow.pan,
          address: lRow.address,
          createdAt: lRow.createdAt,
        );
      }
    }

    final bytes = await LandownerInvoicePdfService.generateStatementPdf(
      project: widget.project,
      agreement: widget.agreement,
      landowner: landowner,
      transactions: widget.transactions,
    );

    if (mounted) {
      _pdfBytesNotifier.value = bytes;
      _isGeneratingNotifier.value = false;
    }
  }

  Future<void> _downloadPdfFile() async {
    final pdfBytes = _pdfBytesNotifier.value;
    if (pdfBytes == null) return;
    final landownerName = widget.project.landownerName ?? widget.landowner?.name ?? 'Landowner';
    final filename =
        'Landowner_Statement_${widget.project.code}_${landownerName.replaceAll(' ', '_')}.pdf';
    final savedPath = await LandownerInvoicePdfService.savePdfToDownloads(
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
    final landownerName = widget.project.landownerName ?? widget.landowner?.name ?? 'Landowner';
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename:
          'Landowner_Statement_${widget.project.code}_${landownerName.replaceAll(' ', '_')}.pdf',
    );
  }

  Future<void> _shareWhatsApp() async {
    final phone = widget.landowner?.phone;
    final landownerName = widget.project.landownerName ?? widget.landowner?.name ?? 'Landowner';
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number recorded for landowner.')),
      );
      return;
    }

    final totalPaid = widget.transactions.fold(0.0, (s, t) => s + t.amount);
    final dues = (widget.agreement.totalPrice - totalPaid).clamp(0.0, double.infinity);

    final message = '''
🧾 *PAMZ PlotPro - LANDOWNER PAYMENT STATEMENT*
---------------------------------------
👤 *Landowner:* $landownerName
📞 *Phone:* $phone
🏗️ *Project:* ${widget.project.name} (${widget.project.code})
💰 *Total Agreed Purchase Price:* ${CalculationEngine.formatCurrency(widget.agreement.totalPrice)}
✅ *Total Paid to Date:* ${CalculationEngine.formatCurrency(totalPaid)}
⚠️ *Remaining Dues:* ${CalculationEngine.formatCurrency(dues)}
📊 *Total Payment Records:* ${widget.transactions.length}

_Generated via ${AppConstants.appName}_
'''.trim();

    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.isNotEmpty && !cleanPhone.startsWith('91') && cleanPhone.length == 10) {
      cleanPhone = '91$cleanPhone';
    }

    final encodedText = Uri.encodeComponent(message);
    final whatsappAppUri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encodedText');
    final whatsappWebUri = Uri.parse('https://api.whatsapp.com/send?phone=$cleanPhone&text=$encodedText');

    try {
      if (await canLaunchUrl(whatsappAppUri)) {
        await launchUrl(whatsappAppUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(whatsappWebUri)) {
        await launchUrl(whatsappWebUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final landownerName = widget.project.landownerName ?? widget.landowner?.name ?? 'Landowner';

    return ValueListenableBuilder<Uint8List?>(
      valueListenable: _pdfBytesNotifier,
      builder: (context, pdfBytes, _) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Text(
              'Landowner Payment Statement PDF ($landownerName)',
              style: AppTypography.cardTitle,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
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
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(Icons.send, size: 16, color: Colors.white),
                label: const Text(
                  'Share via WhatsApp',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: pdfBytes == null ? null : _shareWhatsApp,
              ),
              const SizedBox(width: 16),
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
                useActions: true,
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                initialPageFormat: PdfPageFormat.a4,
                pdfFileName:
                    'Landowner_Statement_${widget.project.code}_${landownerName.replaceAll(' ', '_')}.pdf',
              );
            },
          ),
        );
      },
    );
  }
}
