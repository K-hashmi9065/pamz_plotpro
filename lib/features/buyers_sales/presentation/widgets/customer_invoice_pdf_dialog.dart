import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/services/pdf/customer_invoice_pdf_service.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../../plots/domain/plot_model.dart';
import '../../domain/buyer_model.dart';
import '../../domain/sale_model.dart';

class CustomerInvoicePdfDialog extends ConsumerStatefulWidget {
  final SaleModel sale;
  final BuyerModel? buyer;
  final String projectName;
  final String projectCode;
  final String projectLocation;
  final List<PlotModel> plots;
  final List<Transaction> transactions;

  const CustomerInvoicePdfDialog({
    super.key,
    required this.sale,
    this.buyer,
    required this.projectName,
    required this.projectCode,
    required this.projectLocation,
    this.plots = const [],
    required this.transactions,
  });

  static Future<void> show(
    BuildContext context, {
    required SaleModel sale,
    BuyerModel? buyer,
    required String projectName,
    required String projectCode,
    required String projectLocation,
    List<PlotModel> plots = const [],
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
            child: CustomerInvoicePdfDialog(
              sale: sale,
              buyer: buyer,
              projectName: projectName,
              projectCode: projectCode,
              projectLocation: projectLocation,
              plots: plots,
              transactions: transactions,
            ),
          ),
        ),
      ),
    );
  }

  @override
  ConsumerState<CustomerInvoicePdfDialog> createState() =>
      _CustomerInvoicePdfDialogState();
}

class _CustomerInvoicePdfDialogState
    extends ConsumerState<CustomerInvoicePdfDialog> {
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
    BuyerModel? buyer = widget.buyer;
    if (buyer == null || buyer.phone.isEmpty) {
      final db = ref.read(appDatabaseProvider);
      final bRow = await (db.select(db.buyers)..where((b) => b.id.equals(widget.sale.buyerId))).getSingleOrNull();
      if (bRow != null) {
        buyer = BuyerModel(
          id: bRow.id,
          name: bRow.name,
          phone: bRow.phone,
          email: bRow.email,
          pan: bRow.pan,
          aadhar: bRow.aadhar,
          createdAt: bRow.createdAt,
        );
      }
    }

    final bytes = await CustomerInvoicePdfService.generateInvoicePdf(
      sale: widget.sale,
      buyer: buyer,
      projectName: widget.projectName,
      projectCode: widget.projectCode,
      projectLocation: widget.projectLocation,
      plots: widget.plots,
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
    final filename =
        'Customer_Invoice_${widget.projectCode}_${widget.sale.buyerName.replaceAll(' ', '_')}.pdf';
    final savedPath = await CustomerInvoicePdfService.savePdfToDownloads(
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
      filename:
          'Customer_Invoice_${widget.projectCode}_${widget.sale.buyerName.replaceAll(' ', '_')}.pdf',
    );
  }

  Future<void> _shareWhatsApp() async {
    final phone = widget.buyer?.phone;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number recorded for customer.')),
      );
      return;
    }

    final totalPaid = widget.transactions.fold(0.0, (s, t) => s + t.amount);
    final dues = (widget.sale.agreedPrice - totalPaid).clamp(0.0, double.infinity);
    final plotNumbers = widget.plots.isNotEmpty
        ? widget.plots.map((p) => p.plotNumber).join(', ')
        : 'Whole Land Unit';
    final brandingTitle = HiveService.getPdfHeaderTitle();

    final message = '''
🧾 *$brandingTitle - SALES & PAYMENT INVOICE*
---------------------------------------
👤 *Customer:* ${widget.sale.buyerName}
📞 *Phone:* $phone
🏗️ *Project:* ${widget.projectName} (${widget.projectCode})
📍 *Plot Number:* $plotNumbers
💰 *Agreed Price:* ${CalculationEngine.formatCurrency(widget.sale.agreedPrice)}
✅ *Total Paid to Date:* ${CalculationEngine.formatCurrency(totalPaid)}
⚠️ *Remaining Dues:* ${CalculationEngine.formatCurrency(dues)}
📊 *Total Payments Logged:* ${widget.transactions.length}

_Generated via ${brandingTitle}_
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
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: _pdfBytesNotifier,
      builder: (context, pdfBytes, _) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Text(
              'Sales & Payment Invoice PDF (${widget.sale.buyerName})',
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
                    'Customer_Invoice_${widget.projectCode}_${widget.sale.buyerName.replaceAll(' ', '_')}.pdf',
              );
            },
          ),
        );
      },
    );
  }
}
