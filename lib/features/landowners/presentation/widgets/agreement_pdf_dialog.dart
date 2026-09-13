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
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../../../core/utils/land_unit_converter.dart';

class AgreementPdfDialog extends StatefulWidget {
  final String landownerName;
  final String landownerPhone;
  final String? landownerPan;
  final String? landownerEmail;
  final String? landownerAddress;
  final String projectName;
  final String projectCode;
  final String projectLocation;
  final double landAreaSqFt;
  final double totalPrice;
  final int installmentCount;
  final DateTime agreementDate;

  const AgreementPdfDialog({
    super.key,
    required this.landownerName,
    required this.landownerPhone,
    this.landownerPan,
    this.landownerEmail,
    this.landownerAddress,
    required this.projectName,
    required this.projectCode,
    required this.projectLocation,
    required this.landAreaSqFt,
    required this.totalPrice,
    required this.installmentCount,
    required this.agreementDate,
  });

  static Future<void> show(
    BuildContext context, {
    required String landownerName,
    required String landownerPhone,
    String? landownerPan,
    String? landownerEmail,
    String? landownerAddress,
    required String projectName,
    required String projectCode,
    required String projectLocation,
    required double landAreaSqFt,
    required double totalPrice,
    required int installmentCount,
    required DateTime agreementDate,
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
            child: AgreementPdfDialog(
              landownerName: landownerName,
              landownerPhone: landownerPhone,
              landownerPan: landownerPan,
              landownerEmail: landownerEmail,
              landownerAddress: landownerAddress,
              projectName: projectName,
              projectCode: projectCode,
              projectLocation: projectLocation,
              landAreaSqFt: landAreaSqFt,
              totalPrice: totalPrice,
              installmentCount: installmentCount,
              agreementDate: agreementDate,
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<AgreementPdfDialog> createState() => _AgreementPdfDialogState();
}

class _AgreementPdfDialogState extends State<AgreementPdfDialog> {
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
    final bytes = await AgreementPdfService.generatePurchaseAgreementPdf(
      landownerName: widget.landownerName,
      landownerPhone: widget.landownerPhone,
      landownerPan: widget.landownerPan,
      landownerEmail: widget.landownerEmail,
      landownerAddress: widget.landownerAddress,
      projectName: widget.projectName,
      projectCode: widget.projectCode,
      projectLocation: widget.projectLocation,
      landAreaSqFt: widget.landAreaSqFt,
      totalPrice: widget.totalPrice,
      installmentCount: widget.installmentCount,
      agreementDate: widget.agreementDate,
    );

    if (mounted) {
      _pdfBytesNotifier.value = bytes;
      _isGeneratingNotifier.value = false;
    }
  }

  Future<void> _downloadPdfFile() async {
    final pdfBytes = _pdfBytesNotifier.value;
    if (pdfBytes == null) return;
    final filename = 'Land_Purchase_Agreement_${widget.projectCode}_${widget.landownerName.replaceAll(' ', '_')}.pdf';
    final savedPath = await AgreementPdfService.savePdfToDownloads(
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
      final filename = 'Land_Purchase_Agreement_${widget.projectCode}_${widget.landownerName.replaceAll(' ', '_')}.pdf';
      final savedPath = await AgreementPdfService.savePdfToDownloads(
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

    await AgreementPdfService.shareViaWhatsApp(
      phone: widget.landownerPhone,
      landownerName: widget.landownerName,
      projectName: widget.projectName,
      projectCode: widget.projectCode,
      projectLocation: widget.projectLocation,
      landAreaSqFt: widget.landAreaSqFt,
      totalPrice: widget.totalPrice,
      installmentCount: widget.installmentCount,
    );
  }

  Future<void> _sharePdfFile() async {
    final pdfBytes = _pdfBytesNotifier.value;
    if (pdfBytes == null) return;
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Agreement_${widget.projectCode}_${widget.landownerName.replaceAll(' ', '_')}.pdf',
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
            title: Text('Land Purchase Agreement PDF (${widget.projectCode})', style: AppTypography.cardTitle),
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

class AgreementPdfService {
  static Future<Uint8List> generatePurchaseAgreementPdf({
    required String landownerName,
    required String landownerPhone,
    String? landownerPan,
    String? landownerEmail,
    String? landownerAddress,
    required String projectName,
    required String projectCode,
    required String projectLocation,
    required double landAreaSqFt,
    required double totalPrice,
    required int installmentCount,
    required DateTime agreementDate,
  }) async {
    final pdf = pw.Document();
    final formattedDate = DateFormat('dd MMMM yyyy').format(agreementDate);
    final totalKatta = LandUnitConverter.sqFtToKatta(landAreaSqFt);
    final totalKattaStr = totalKatta == totalKatta.roundToDouble()
        ? totalKatta.toInt().toString()
        : double.parse(totalKatta.toStringAsFixed(3)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final totalDhur = LandUnitConverter.sqFtToDhur(landAreaSqFt);
    final totalDhurStr = totalDhur == totalDhur.roundToDouble()
        ? totalDhur.toInt().toString()
        : double.parse(totalDhur.toStringAsFixed(2)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final totalDec = LandUnitConverter.sqFtToDecimal(landAreaSqFt);
    final totalDecStr = totalDec == totalDec.roundToDouble()
        ? totalDec.toInt().toString()
        : double.parse(totalDec.toStringAsFixed(2)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final formattedSqFt = CalculationEngine.indianNumberFormat.format(landAreaSqFt.round());
    final formattedPrice = 'Rs. ${CalculationEngine.indianNumberFormat.format(totalPrice.round())}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'LAND PURCHASE AGREEMENT',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        AppConstants.appName,
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date: $formattedDate', style: const pw.TextStyle(fontSize: 11)),
                      pw.Text('Ref #: AGR-$projectCode', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, color: PdfColors.blue800),
              pw.SizedBox(height: 16),

              // Section 1: Parties
              pw.Text('1. PARTIES TO THE AGREEMENT', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
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
                          pw.Text('LANDOWNER / SELLER:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                          pw.Text('Name: $landownerName', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Phone: $landownerPhone', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('PAN: ${landownerPan ?? "N/A"}', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Email: ${landownerEmail ?? "N/A"}', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('PURCHASER / DEVELOPER:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
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

              // Section 2: Property & Financial Terms
              pw.Text('2. LAND DETAILS & FINANCIAL TERMS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: ['Property Parameter', 'Details / Specification'],
                data: [
                  ['Project Name & Code', '$projectName ($projectCode)'],
                  ['Project Location', projectLocation],
                  ['Total Land Area', '$formattedSqFt Sq. Ft. ($totalKattaStr Kattha | $totalDhurStr Dhur | $totalDecStr Dec)'],
                  ['Total Purchase Price', formattedPrice],
                  ['Payment Schedule', '$installmentCount Scheduled Installment Payments'],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              ),
              pw.SizedBox(height: 16),

              // Section 3: Statutory Clauses
              pw.Text('3. TERMS & DECLARATIONS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Bullet(text: 'The Seller confirms unencumbered, clear title of ownership over the specified land parcel.', style: const pw.TextStyle(fontSize: 9)),
              pw.Bullet(text: 'The Purchaser agrees to disburse payments strictly as per the agreed schedule.', style: const pw.TextStyle(fontSize: 9)),
              pw.Bullet(text: 'Possession and mutation process shall commence upon complete settlement of total purchase price.', style: const pw.TextStyle(fontSize: 9)),
              pw.Bullet(text: 'Both parties agree to execute statutory deed registration under local jurisdiction.', style: const pw.TextStyle(fontSize: 9)),

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
                      pw.Text('Seller / Landowner Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('Name: $landownerName', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 160, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('Authorized Purchaser Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('Entity: ${AppConstants.appName}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text(
                  'Generated via ${AppConstants.appName} - Confidential',
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
    required String landownerName,
    required String projectName,
    required String projectCode,
    required String projectLocation,
    required double landAreaSqFt,
    required double totalPrice,
    required int installmentCount,
  }) async {
    final formattedPrice = 'Rs. ${CalculationEngine.indianNumberFormat.format(totalPrice.round())}';
    final totalKatta = LandUnitConverter.sqFtToKatta(landAreaSqFt);
    final totalKattaStr = totalKatta == totalKatta.roundToDouble()
        ? totalKatta.toInt().toString()
        : double.parse(totalKatta.toStringAsFixed(3)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final totalDhur = LandUnitConverter.sqFtToDhur(landAreaSqFt);
    final totalDhurStr = totalDhur == totalDhur.roundToDouble()
        ? totalDhur.toInt().toString()
        : double.parse(totalDhur.toStringAsFixed(2)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final totalDec = LandUnitConverter.sqFtToDecimal(landAreaSqFt);
    final totalDecStr = totalDec == totalDec.roundToDouble()
        ? totalDec.toInt().toString()
        : double.parse(totalDec.toStringAsFixed(2)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final formattedSqFt = CalculationEngine.indianNumberFormat.format(landAreaSqFt.round());
    final formattedArea = '$formattedSqFt Sq. Ft. ($totalKattaStr Kattha | $totalDhurStr Dhur | $totalDecStr Dec)';

    final message = '''
📜 *LAND PURCHASE AGREEMENT*
---------------------------------------
👤 *Landowner:* $landownerName
📞 *Phone:* $phone
🏗️ *Project:* $projectName ($projectCode)
📍 *Location:* $projectLocation
📐 *Land Area:* $formattedArea
💰 *Agreed Purchase Price:* $formattedPrice
📅 *Payment Schedule:* $installmentCount Installments

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
