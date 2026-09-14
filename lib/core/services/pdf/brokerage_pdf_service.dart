import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';
import '../../../features/plots/domain/plot_model.dart';
import '../../storage/hive_service.dart';
import '../../utils/calculation_engine.dart';
import '../../utils/land_unit_converter.dart';

class BrokeragePdfService {
  static final _dateTimeFmt = DateFormat('dd MMMM yyyy, hh:mm a');

  static Future<Uint8List> generateBrokerageVoucherPdf({
    required PlotModel plot,
    required String projectName,
    required String projectCode,
    required String projectLocation,
  }) async {
    final pdf = pw.Document();
    final brandingTitle = HiveService.getPdfHeaderTitle();
    final generatedAt = _dateTimeFmt.format(DateTime.now());

    final totalKatta = LandUnitConverter.sqFtToKatta(plot.areaSqFt);
    final totalKattaStr = totalKatta == totalKatta.roundToDouble()
        ? totalKatta.toInt().toString()
        : double.parse(totalKatta.toStringAsFixed(3)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final totalDhur = LandUnitConverter.sqFtToDhur(plot.areaSqFt);
    final totalDhurStr = totalDhur == totalDhur.roundToDouble()
        ? totalDhur.toInt().toString()
        : double.parse(totalDhur.toStringAsFixed(2)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final totalDec = LandUnitConverter.sqFtToDecimal(plot.areaSqFt);
    final totalDecStr = totalDec == totalDec.roundToDouble()
        ? totalDec.toInt().toString()
        : double.parse(totalDec.toStringAsFixed(2)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');

    final formattedSqFt = CalculationEngine.indianNumberFormat.format(plot.areaSqFt.round());
    final formattedCharge = 'Rs. ${CalculationEngine.indianNumberFormat.format(plot.brokerageCharge.round())}';

    final hasDimensions = plot.lengthFt != null &&
        plot.breadthFt != null &&
        (plot.lengthFt! > 0 || plot.breadthFt! > 0);
    final dimensionsStr = hasDimensions
        ? '${plot.formattedLength} × ${plot.formattedBreadth}'
        : 'NA';

    final voucherNo = 'BRK-${plot.plotNumber.replaceAll(' ', '_')}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Banner
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PLOT BROKERAGE VOUCHER / RECEIPT',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        brandingTitle,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.Text(
                        'Official Commission & Brokerage Fee Record',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue100,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          border: pw.Border.all(color: PdfColors.blue700, width: 0.5),
                        ),
                        child: pw.Text(
                          'RECORDED & ALLOCATED',
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Date: $generatedAt', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.Text('Voucher Ref: $voucherNo', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1, color: PdfColors.blue900),
              pw.SizedBox(height: 12),

              // Section 1: Project & Plot Master Identification
              _buildSectionTitle('1. PROJECT & PLOT IDENTIFICATION'),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildPdfKeyValue('Project Name:', projectName),
                          _buildPdfKeyValue('Project Code / ID:', projectCode),
                          _buildPdfKeyValue('Project Location:', projectLocation),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildPdfKeyValue('Plot Number / ID:', plot.plotNumber),
                          _buildPdfKeyValue('Dimensions (L × B):', dimensionsStr),
                          _buildPdfKeyValue('Plot Area:', '$formattedSqFt Sq. Ft. ($totalKattaStr Kattha | $totalDhurStr Dhur | $totalDecStr Dec)'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              // Section 2: Broker & Agent Information
              _buildSectionTitle('2. BROKER / AGENT INFORMATION'),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildPdfKeyValue('Broker / Agent Name:', plot.brokerName?.trim().isNotEmpty == true ? plot.brokerName! : 'Not Specified'),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildPdfKeyValue('Mobile Number / Phone:', plot.brokerPhone?.trim().isNotEmpty == true ? plot.brokerPhone! : 'Not Specified'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              // Section 3: Brokerage Fee & Accounting Terms
              _buildSectionTitle('3. BROKERAGE CHARGE & FINANCIAL SPECIFICATION'),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: ['Particulars / Parameter', 'Allocation & Amount'],
                data: [
                  ['Plot Identification', 'Plot #${plot.plotNumber} ($projectName)'],
                  ['Broker Assigned', plot.brokerName ?? '—'],
                  ['Contact Phone', plot.brokerPhone ?? '—'],
                  ['Total Brokerage Charge', formattedCharge],
                  ['Accounting Treatment', 'Capitalized Project Expense & Added to Plot Cost Base'],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                cellStyle: const pw.TextStyle(fontSize: 8.5),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              ),
              pw.SizedBox(height: 12),

              // Declarations Box
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('DECLARATIONS & TERMS:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    pw.SizedBox(height: 3),
                    pw.Bullet(text: 'This voucher serves as the official transaction record for the brokerage commission assigned to the specified plot.', style: const pw.TextStyle(fontSize: 7.5)),
                    pw.Bullet(text: 'The commission has been integrated into the project accounting ledger and allocated directly to the plot cost base.', style: const pw.TextStyle(fontSize: 7.5)),
                  ],
                ),
              ),

              pw.Spacer(),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 3),
                      pw.Text('Broker / Agent Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
                      pw.Text('Name: ${plot.brokerName ?? "—"}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 3),
                      pw.Text('Authorized Project Signatory', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
                      pw.Text('Entity: $brandingTitle', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Generated via $brandingTitle - Official Brokerage Voucher',
                  style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 9.5,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900,
      ),
    );
  }

  static pw.Widget _buildPdfKeyValue(String key, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              key,
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> shareViaWhatsApp({
    required PlotModel plot,
    required String projectName,
    required String projectCode,
    required String projectLocation,
  }) async {
    final brandingTitle = HiveService.getPdfHeaderTitle();
    final formattedCharge = 'Rs. ${CalculationEngine.indianNumberFormat.format(plot.brokerageCharge.round())}';

    final message = '''
🤝 *PLOT BROKERAGE VOUCHER*
---------------------------------------
👤 *Broker Name:* ${plot.brokerName ?? "—"}
📞 *Mobile:* ${plot.brokerPhone ?? "—"}
🏗️ *Project:* $projectName ($projectCode)
📍 *Location:* $projectLocation
📐 *Plot Number:* ${plot.plotNumber}
📏 *Plot Area:* ${plot.formattedArea}
💰 *Brokerage Charge:* $formattedCharge

_Generated via ${brandingTitle}_
'''.trim();

    String cleanPhone = (plot.brokerPhone ?? '').replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.isNotEmpty && !cleanPhone.startsWith('91') && cleanPhone.length == 10) {
      cleanPhone = '91$cleanPhone';
    }

    final encodedText = Uri.encodeComponent(message);
    final whatsappAppUri = Uri.parse(
      cleanPhone.isNotEmpty
          ? 'whatsapp://send?phone=$cleanPhone&text=$encodedText'
          : 'whatsapp://send?text=$encodedText',
    );
    final whatsappWebUri = Uri.parse(
      cleanPhone.isNotEmpty
          ? 'https://api.whatsapp.com/send?phone=$cleanPhone&text=$encodedText'
          : 'https://api.whatsapp.com/send?text=$encodedText',
    );

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
