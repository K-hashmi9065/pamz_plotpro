import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../domain/buyer_model.dart';
import '../../domain/sale_model.dart';

class BuyerSalePdfDialog extends StatefulWidget {
  final SaleModel sale;
  final BuyerModel? buyer;
  final String projectName;
  final String projectCode;
  final String projectLocation;

  const BuyerSalePdfDialog({
    super.key,
    required this.sale,
    this.buyer,
    required this.projectName,
    required this.projectCode,
    required this.projectLocation,
  });

  static Future<void> show(
    BuildContext context, {
    required SaleModel sale,
    BuyerModel? buyer,
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
            width: 900,
            height: 750,
            child: BuyerSalePdfDialog(
              sale: sale,
              buyer: buyer,
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
  State<BuyerSalePdfDialog> createState() => _BuyerSalePdfDialogState();
}

class _BuyerSalePdfDialogState extends State<BuyerSalePdfDialog> {
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
    final bytes = await BuyerSalePdfService.generateBuyerSalePdf(
      sale: widget.sale,
      buyer: widget.buyer,
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
    final filename = 'Sale_Agreement_${widget.projectCode}_${widget.sale.buyerName.replaceAll(' ', '_')}.pdf';
    final savedPath = await BuyerSalePdfService.savePdfToDownloads(
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

  Future<void> _shareWhatsApp() async {
    final pdfBytes = _pdfBytesNotifier.value;
    if (pdfBytes != null) {
      final filename = 'Sale_Agreement_${widget.projectCode}_${widget.sale.buyerName.replaceAll(' ', '_')}.pdf';
      final savedPath = await BuyerSalePdfService.savePdfToDownloads(
        pdfBytes: pdfBytes,
        filename: filename,
      );
      if (mounted && savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to Downloads! Opening WhatsApp... Attach the saved PDF from Downloads.'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }

    await BuyerSalePdfService.shareViaWhatsApp(
      phone: widget.buyer?.phone ?? '',
      buyerName: widget.sale.buyerName,
      projectName: widget.projectName,
      projectCode: widget.projectCode,
      projectLocation: widget.projectLocation,
      agreedPrice: widget.sale.agreedPrice,
      saleExpenses: widget.sale.saleExpenses,
      saleDate: widget.sale.saleDate,
    );
  }

  Future<void> _sharePdfFile() async {
    final pdfBytes = _pdfBytesNotifier.value;
    if (pdfBytes == null) return;
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Sale_Agreement_${widget.projectCode}_${widget.sale.buyerName.replaceAll(' ', '_')}.pdf',
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
            title: Text('Customer Sale Agreement PDF (${widget.projectCode})', style: AppTypography.cardTitle),
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

class BuyerSalePdfService {
  static Future<Uint8List> generateBuyerSalePdf({
    required SaleModel sale,
    BuyerModel? buyer,
    required String projectName,
    required String projectCode,
    required String projectLocation,
  }) async {
    final pdf = pw.Document();
    final brandingTitle = HiveService.getPdfHeaderTitle();
    final formattedDate = DateFormat('dd MMMM yyyy').format(sale.saleDate);
    final formattedPrice = 'Rs. ${CalculationEngine.indianNumberFormat.format(sale.agreedPrice.round())}';
    final netProceeds = CalculationEngine.calculateNetSaleProceeds(
      agreedSalePrice: sale.agreedPrice,
      directSaleExpenses: sale.saleExpenses,
    );
    final formattedNet = 'Rs. ${CalculationEngine.indianNumberFormat.format(netProceeds.round())}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CUSTOMER SALES AGREEMENT',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        brandingTitle,
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date: $formattedDate', style: const pw.TextStyle(fontSize: 11)),
                      pw.Text('Ref #: SALE-$projectCode-${(sale.id.length > 6 ? sale.id.substring(0, 6) : sale.id).toUpperCase()}', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, color: PdfColors.blue800),
              pw.SizedBox(height: 16),

              // Section 1: Parties
              pw.Text('1. PARTIES TO THE SALE AGREEMENT', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('CUSTOMER / PURCHASER:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                          pw.Text('Name: ${sale.buyerName}', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Phone: ${buyer?.phone ?? "N/A"}', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('PAN: ${buyer?.pan ?? "N/A"}', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Aadhar: ${buyer?.aadhar ?? "N/A"}', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('DEVELOPER / SELLER:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                          pw.Text('Entity: ${AppConstants.appName}', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Project Code: $projectCode', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Project Name: $projectName', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Location: $projectLocation', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Section 2: Financials & Sale Terms
              pw.Text('2. SALE TERMS & FINANCIAL DETAILS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: ['Sale Parameter', 'Details / Specification'],
                data: [
                  ['Project Name & Code', '$projectName ($projectCode)'],
                  ['Sale Structure / Type', sale.saleType.name.toUpperCase()],
                  ['Agreed Sale Price', formattedPrice],
                  ['Direct Sale Expenses', 'Rs. ${CalculationEngine.indianNumberFormat.format(sale.saleExpenses.round())}'],
                  ['Net Sale Proceeds', formattedNet],
                  ['DLC / Circle Rate Status', sale.isBelowCircleRate ? 'WARNING: Below DLC Threshold (Sec 43CA Flag)' : 'COMPLIANT (Passes DLC rate check)'],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              ),
              pw.SizedBox(height: 16),

              // Section 3: Legal Terms & Compliance
              pw.Text('3. TERMS & COMPLIANCE DECLARATION', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Bullet(text: 'The Customer agrees to pay total agreed price as per scheduled installment milestones.', style: const pw.TextStyle(fontSize: 9)),
              pw.Bullet(text: 'Title transfer and final deed execution shall be completed upon 100% receipt of agreed sale proceeds.', style: const pw.TextStyle(fontSize: 9)),
              pw.Bullet(text: 'Compliance under Income Tax Act Section 43CA / 50C is enforced for circle rate benchmark.', style: const pw.TextStyle(fontSize: 9)),
              pw.Bullet(text: 'Failure to clear due installments within specified grace period may incur statutory interest.', style: const pw.TextStyle(fontSize: 9)),

              pw.Spacer(),

              // Signature Blocks
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 160, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('Customer / Purchaser Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('Name: ${sale.buyerName}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 160, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('Authorized Developer Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('Entity: $brandingTitle', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text(
                  'Generated via $brandingTitle - Confidential',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> shareViaWhatsApp({
    required String phone,
    required String buyerName,
    required String projectName,
    required String projectCode,
    required String projectLocation,
    required double agreedPrice,
    required double saleExpenses,
    required DateTime saleDate,
  }) async {
    final formattedPrice = 'Rs. ${CalculationEngine.indianNumberFormat.format(agreedPrice.round())}';
    final netProceeds = CalculationEngine.calculateNetSaleProceeds(
      agreedSalePrice: agreedPrice,
      directSaleExpenses: saleExpenses,
    );
    final formattedNet = 'Rs. ${CalculationEngine.indianNumberFormat.format(netProceeds.round())}';
    final formattedDate = DateFormat('dd MMM yyyy').format(saleDate);
    final brandingTitle = HiveService.getPdfHeaderTitle();

    final message = '''
📜 *BUYER SALES AGREEMENT*
---------------------------------------
👤 *Buyer Name:* $buyerName
📞 *Phone:* ${phone.isNotEmpty ? phone : "N/A"}
🏗️ *Project:* $projectName ($projectCode)
📍 *Location:* $projectLocation
📅 *Sale Date:* $formattedDate
💰 *Agreed Sale Price:* $formattedPrice
💵 *Net Sale Proceeds:* $formattedNet

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
        return;
      }
    } catch (_) {}

    await launchUrl(whatsappWebUri, mode: LaunchMode.externalApplication);
  }

  static Future<String?> savePdfToDownloads({
    required Uint8List pdfBytes,
    required String filename,
  }) async {
    try {
      Directory? downloadsDir;
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        downloadsDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      final file = File('${downloadsDir.path}/$filename');
      await file.writeAsBytes(pdfBytes);
      return file.path;
    } catch (e) {
      debugPrint('Error saving PDF: $e');
      return null;
    }
  }
}
