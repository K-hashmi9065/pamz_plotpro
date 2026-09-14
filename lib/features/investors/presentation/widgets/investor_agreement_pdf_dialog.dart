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
import '../../../../core/utils/land_unit_converter.dart';

class InvestorAgreementPdfDialog extends StatefulWidget {
  final String investorName;
  final String investorPhone;
  final String? investorPan;
  final String? investorEmail;
  final String projectName;
  final String projectCode;
  final String projectLocation;
  final double projectLandAreaSqFt;
  final double investedAmount;
  final double ownershipPercent;
  final OwnershipMethod ownershipMethod;
  final DateTime agreementDate;

  const InvestorAgreementPdfDialog({
    super.key,
    required this.investorName,
    required this.investorPhone,
    this.investorPan,
    this.investorEmail,
    required this.projectName,
    required this.projectCode,
    required this.projectLocation,
    required this.projectLandAreaSqFt,
    required this.investedAmount,
    required this.ownershipPercent,
    required this.ownershipMethod,
    required this.agreementDate,
  });

  static Future<void> show(
    BuildContext context, {
    required String investorName,
    required String investorPhone,
    String? investorPan,
    String? investorEmail,
    required String projectName,
    required String projectCode,
    required String projectLocation,
    required double projectLandAreaSqFt,
    required double investedAmount,
    required double ownershipPercent,
    required OwnershipMethod ownershipMethod,
    DateTime? agreementDate,
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
            child: InvestorAgreementPdfDialog(
              investorName: investorName,
              investorPhone: investorPhone,
              investorPan: investorPan,
              investorEmail: investorEmail,
              projectName: projectName,
              projectCode: projectCode,
              projectLocation: projectLocation,
              projectLandAreaSqFt: projectLandAreaSqFt,
              investedAmount: investedAmount,
              ownershipPercent: ownershipPercent,
              ownershipMethod: ownershipMethod,
              agreementDate: agreementDate ?? DateTime.now(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<InvestorAgreementPdfDialog> createState() => _InvestorAgreementPdfDialogState();
}

class _InvestorAgreementPdfDialogState extends State<InvestorAgreementPdfDialog> {
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
    final bytes = await InvestorAgreementPdfService.generateInvestorAgreementPdf(
      investorName: widget.investorName,
      investorPhone: widget.investorPhone,
      investorPan: widget.investorPan,
      investorEmail: widget.investorEmail,
      projectName: widget.projectName,
      projectCode: widget.projectCode,
      projectLocation: widget.projectLocation,
      projectLandAreaSqFt: widget.projectLandAreaSqFt,
      investedAmount: widget.investedAmount,
      ownershipPercent: widget.ownershipPercent,
      ownershipMethod: widget.ownershipMethod,
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
    final filename = 'Investor_Agreement_${widget.projectCode}_${widget.investorName.replaceAll(' ', '_')}.pdf';
    final savedPath = await InvestorAgreementPdfService.savePdfToDownloads(
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
      final filename = 'Investor_Agreement_${widget.projectCode}_${widget.investorName.replaceAll(' ', '_')}.pdf';
      final savedPath = await InvestorAgreementPdfService.savePdfToDownloads(
        pdfBytes: pdfBytes,
        filename: filename,
      );

      if (mounted && savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF saved to Downloads! Opening WhatsApp... Attach the saved PDF from Downloads.'),
            backgroundColor: AppColors.accent,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }

    await InvestorAgreementPdfService.shareViaWhatsApp(
      phone: widget.investorPhone,
      investorName: widget.investorName,
      projectName: widget.projectName,
      projectCode: widget.projectCode,
      projectLocation: widget.projectLocation,
      projectLandAreaSqFt: widget.projectLandAreaSqFt,
      investedAmount: widget.investedAmount,
      ownershipPercent: widget.ownershipPercent,
      ownershipMethod: widget.ownershipMethod,
    );
  }

  Future<void> _sharePdfFile() async {
    final pdfBytes = _pdfBytesNotifier.value;
    if (pdfBytes == null) return;
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Investor_Agreement_${widget.projectCode}_${widget.investorName.replaceAll(' ', '_')}.pdf',
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
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Text('Investor Capital Agreement PDF (${widget.projectCode})', style: AppTypography.cardTitle),
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: const Icon(Icons.send, size: 16, color: Colors.white),
                label: const Text('Share via WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                pdfFileName: 'Investor_Agreement_${widget.projectCode}_${widget.investorName.replaceAll(' ', '_')}.pdf',
              );
            },
          ),
        );
      },
    );
  }
}

class InvestorAgreementPdfService {
  static Future<Uint8List> generateInvestorAgreementPdf({
    required String investorName,
    required String investorPhone,
    String? investorPan,
    String? investorEmail,
    required String projectName,
    required String projectCode,
    required String projectLocation,
    required double projectLandAreaSqFt,
    required double investedAmount,
    required double ownershipPercent,
    required OwnershipMethod ownershipMethod,
    required DateTime agreementDate,
  }) async {
    final pdf = pw.Document();
    final brandingTitle = HiveService.getPdfHeaderTitle();
    final formattedDate = DateFormat('dd MMMM yyyy').format(agreementDate);

    final totalKatta = LandUnitConverter.sqFtToKatta(projectLandAreaSqFt);
    final totalKattaStr = totalKatta == totalKatta.roundToDouble()
        ? totalKatta.toInt().toString()
        : double.parse(totalKatta.toStringAsFixed(3)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final totalDhur = LandUnitConverter.sqFtToDhur(projectLandAreaSqFt);
    final totalDhurStr = totalDhur == totalDhur.roundToDouble()
        ? totalDhur.toInt().toString()
        : double.parse(totalDhur.toStringAsFixed(2)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final totalDec = LandUnitConverter.sqFtToDecimal(projectLandAreaSqFt);
    final totalDecStr = totalDec == totalDec.roundToDouble()
        ? totalDec.toInt().toString()
        : double.parse(totalDec.toStringAsFixed(2)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final formattedSqFt = CalculationEngine.indianNumberFormat.format(projectLandAreaSqFt.round());
    final formattedCapital = 'Rs. ${CalculationEngine.indianNumberFormat.format(investedAmount.round())}';

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
                        'INVESTOR CAPITAL & OWNERSHIP AGREEMENT',
                        style: pw.TextStyle(
                          fontSize: 18,
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
                      pw.Text('Ref #: INV-AGR-$projectCode', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
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
                          pw.Text('INVESTOR / EQUITY PARTNER:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                          pw.Text('Name: $investorName', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Phone: $investorPhone', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('PAN: ${investorPan ?? "N/A"}', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Email: ${investorEmail ?? "N/A"}', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('DEVELOPER / MANAGING ENTITY:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
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

              // Section 2: Investment & Ownership Allocation
              pw.Text('2. CAPITAL CONTRIBUTION & OWNERSHIP TERMS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: ['Parameter', 'Details / Specification'],
                data: [
                  ['Project Name & Code', '$projectName ($projectCode)'],
                  ['Project Location', projectLocation],
                  ['Total Project Land Area', '$formattedSqFt Sq. Ft. ($totalKattaStr Kattha | $totalDhurStr Dhur | $totalDecStr Dec)'],
                  ['Contributed Capital Amount', formattedCapital],
                  ['Allocated Ownership Share', '${ownershipPercent.toStringAsFixed(2)}%'],
                  ['Allocation Method', ownershipMethod == OwnershipMethod.capitalBased ? 'CAPITAL_BASED (Pro-rata share calculation)' : 'MANUAL (Agreed ownership share)'],
                  ['Profit & Loss Distribution', 'Proportional to ${ownershipPercent.toStringAsFixed(2)}% equity share'],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              ),
              pw.SizedBox(height: 16),

              // Section 3: Statutory & Investment Declarations
              pw.Text('3. TERMS & OPERATING DECLARATIONS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Bullet(text: 'The Investor commits capital contribution towards project acquisition, development, and operating execution.', style: const pw.TextStyle(fontSize: 9)),
              pw.Bullet(text: 'Ownership percentage confers proportional rights to net realized profits and asset appreciation upon inventory liquidation.', style: const pw.TextStyle(fontSize: 9)),
              pw.Bullet(text: 'Disbursement of returns, capital repayments, and dividends shall follow phased milestone realizations from plot sales.', style: const pw.TextStyle(fontSize: 9)),
              pw.Bullet(text: 'Both parties agree to statutory audit compliance, tax withholding (TDS), and applicable partnership protocols.', style: const pw.TextStyle(fontSize: 9)),

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
                      pw.Text('Investor / Partner Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('Name: $investorName', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 160, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 4),
                      pw.Text('Authorized Entity Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('Entity: ${AppConstants.appName}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text(
                  'Generated via $brandingTitle - Confidential Investor Document',
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
    required String investorName,
    required String projectName,
    required String projectCode,
    required String projectLocation,
    required double projectLandAreaSqFt,
    required double investedAmount,
    required double ownershipPercent,
    required OwnershipMethod ownershipMethod,
  }) async {
    final formattedCapital = 'Rs. ${CalculationEngine.indianNumberFormat.format(investedAmount.round())}';
    final totalKatta = LandUnitConverter.sqFtToKatta(projectLandAreaSqFt);
    final totalKattaStr = totalKatta == totalKatta.roundToDouble()
        ? totalKatta.toInt().toString()
        : double.parse(totalKatta.toStringAsFixed(3)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final totalDhur = LandUnitConverter.sqFtToDhur(projectLandAreaSqFt);
    final totalDhurStr = totalDhur == totalDhur.roundToDouble()
        ? totalDhur.toInt().toString()
        : double.parse(totalDhur.toStringAsFixed(2)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final totalDec = LandUnitConverter.sqFtToDecimal(projectLandAreaSqFt);
    final totalDecStr = totalDec == totalDec.roundToDouble()
        ? totalDec.toInt().toString()
        : double.parse(totalDec.toStringAsFixed(2)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final formattedSqFt = CalculationEngine.indianNumberFormat.format(projectLandAreaSqFt.round());
    final formattedArea = '$formattedSqFt Sq. Ft. ($totalKattaStr Kattha | $totalDhurStr Dhur | $totalDecStr Dec)';

    final message = '''
📜 *INVESTOR CAPITAL & OWNERSHIP AGREEMENT*
---------------------------------------
👤 *Investor:* $investorName
📞 *Phone:* $phone
🏗️ *Project:* $projectName ($projectCode)
📍 *Location:* $projectLocation
📐 *Project Land Area:* $formattedArea
💰 *Capital Contribution:* $formattedCapital
📊 *Allocated Ownership:* ${ownershipPercent.toStringAsFixed(2)}% (${ownershipMethod.name.toUpperCase()})

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

  static Future<String?> savePdfToDownloads({
    required Uint8List pdfBytes,
    required String filename,
  }) async {
    try {
      Directory? dir;
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        dir = await getDownloadsDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      if (dir == null) return null;
      final filePath = '${dir.path}${Platform.pathSeparator}$filename';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      return filePath;
    } catch (e) {
      return null;
    }
  }
}
