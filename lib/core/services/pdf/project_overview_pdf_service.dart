import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';
import '../../../features/expenses/domain/expense_model.dart';
import '../../../features/plots/domain/plot_model.dart';
import '../../../features/profit_loss_settlement/domain/profit_loss_models.dart';
import '../../../features/projects/domain/project_model.dart';
import '../../constants/app_constants.dart';
import '../../storage/hive_service.dart';
import '../../utils/calculation_engine.dart';
import '../../utils/land_unit_converter.dart';

class ProjectOverviewPdfService {
  static final _dateTimeFmt = DateFormat('dd MMMM yyyy, hh:mm a');
  static final _dateFmt = DateFormat('dd MMMM yyyy');

  static Future<Uint8List> generateProjectOverviewPdf({
    required ProjectModel project,
    required List<PlotModel> plots,
    required List<ExpenseModel> expenses,
    List<ProjectProfitLossModel> pnlList = const [],
  }) async {
    final pdf = pw.Document();
    final brandingTitle = HiveService.getPdfHeaderTitle();
    final generatedAt = _dateTimeFmt.format(DateTime.now());

    // Land & Area Calculations
    final bool hasDimensions = project.lengthFt != null &&
        project.breadthFt != null &&
        (project.lengthFt! > 0 || project.breadthFt! > 0);
    final double calculatedSqFt = hasDimensions
        ? LandUnitConverter.dimensionsToSqFt(
            lengthFt: project.lengthFt!,
            lengthIn: project.lengthIn ?? 0.0,
            breadthFt: project.breadthFt!,
            breadthIn: project.breadthIn ?? 0.0,
          )
        : 0.0;
    final String calculatedAreaText = hasDimensions
        ? '${CalculationEngine.indianNumberFormat.format(calculatedSqFt.round())} Sq. Ft. (${project.lengthFt?.toInt() ?? 0} ft ${project.lengthIn?.toInt() ?? 0} in × ${project.breadthFt?.toInt() ?? 0} ft ${project.breadthIn?.toInt() ?? 0} in)'
        : 'NA';

    final totalKatta = LandUnitConverter.sqFtToKatta(project.landAreaSqFt);
    final totalKattaStr = totalKatta == totalKatta.roundToDouble()
        ? totalKatta.toInt().toString()
        : double.parse(totalKatta.toStringAsFixed(3)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final totalDhur = LandUnitConverter.sqFtToDhur(project.landAreaSqFt);
    final totalDhurStr = totalDhur == totalDhur.roundToDouble()
        ? totalDhur.toInt().toString()
        : double.parse(totalDhur.toStringAsFixed(2)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final totalDec = LandUnitConverter.sqFtToDecimal(project.landAreaSqFt);
    final totalDecStr = totalDec == totalDec.roundToDouble()
        ? totalDec.toInt().toString()
        : double.parse(totalDec.toStringAsFixed(2)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');

    final bool hasActualArea = project.displayArea != null && project.displayArea! > 0;
    final String actualAreaText = hasActualArea
        ? '${CalculationEngine.indianNumberFormat.format(project.landAreaSqFt.round())} Sq. Ft. ($totalKattaStr Kattha | $totalDhurStr Dhur | $totalDecStr Dec)'
        : '${CalculationEngine.indianNumberFormat.format(project.landAreaSqFt.round())} Sq. Ft. ($totalKattaStr Kattha)';

    // Land Area Breakdown calculations
    double soldAreaSqFt = 0.0;
    double roadAreaSqFt = 0.0;
    int roadCount = 0;

    for (final plot in plots) {
      if (plot.isRoad) {
        roadCount++;
        roadAreaSqFt += plot.areaSqFt;
        continue;
      }
      if (plot.status == PlotStatus.booked ||
          plot.status == PlotStatus.reserved ||
          plot.status == PlotStatus.sold) {
        soldAreaSqFt += plot.areaSqFt;
      }
    }

    final remainingAreaSqFt = (project.landAreaSqFt - soldAreaSqFt - roadAreaSqFt).clamp(0.0, double.infinity);
    final soldKatthaStr = LandUnitConverter.sqFtToKatta(soldAreaSqFt).toStringAsFixed(2);
    final remKatthaStr = LandUnitConverter.sqFtToKatta(remainingAreaSqFt).toStringAsFixed(2);
    final roadKatthaStr = LandUnitConverter.sqFtToKatta(roadAreaSqFt).toStringAsFixed(2);

    // Financial calculations
    final totalExpenseAmount = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final capitalizedExpenseAmount = expenses.where((e) => e.isCapitalized).fold(0.0, (sum, e) => sum + e.amount);
    final realActualCost = project.purchasePrice + capitalizedExpenseAmount;

    final pnl = pnlList.cast<ProjectProfitLossModel?>().firstWhere(
      (p) => p?.projectId == project.id,
      orElse: () => null,
    );

    final cashCollected = pnl?.cashCollected ?? 0.0;
    final totalAgreedSales = pnl?.totalAgreedSales ?? 0.0;
    final netCashProfit = cashCollected - realActualCost;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
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
                        'PROJECT MASTER & LAND OVERVIEW',
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
                        'Comprehensive Master Plan & Land Allocation Summary',
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
                          color: project.status == ProjectStatus.active
                              ? PdfColors.green100
                              : PdfColors.blue100,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          border: pw.Border.all(
                            color: project.status == ProjectStatus.active
                                ? PdfColors.green700
                                : PdfColors.blue700,
                            width: 0.5,
                          ),
                        ),
                        child: pw.Text(
                          project.status.name.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: project.status == ProjectStatus.active
                                ? PdfColors.green900
                                : PdfColors.blue900,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Date: $generatedAt', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.Text('Doc Ref: PMR-${project.code}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1, color: PdfColors.blue900),
              pw.SizedBox(height: 8),

              // Section 1: Project Master Information
              _buildSectionTitle('1. PROJECT MASTER INFORMATION'),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
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
                          _buildPdfKeyValue('Project Code:', project.code),
                          _buildPdfKeyValue('Project Name:', project.name),
                          _buildPdfKeyValue('Location:', project.location),
                          _buildPdfKeyValue('Assigned Landowner:', project.landownerName ?? 'Not Assigned'),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildPdfKeyValue(
                            'Land Purchase Price:',
                            'Rs. ${CalculationEngine.indianNumberFormat.format(project.purchasePrice.round())}',
                          ),
                          _buildPdfKeyValue(
                            'Created Date:',
                            _dateFmt.format(project.createdAt),
                          ),
                          _buildPdfKeyValue(
                            'Description:',
                            (project.description != null && project.description!.trim().isNotEmpty)
                                ? project.description!
                                : 'No description provided.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // Section 2: Land Measurement & Area Breakdown
              _buildSectionTitle('2. LAND MEASUREMENT & AREA BREAKDOWN'),
              pw.SizedBox(height: 4),
              pw.TableHelper.fromTextArray(
                headers: ['Measurement Parameter', 'Area & Dimensions (Imperial & Regional Unit)'],
                data: [
                  ['Calculated Dimensions (L x B)', calculatedAreaText],
                  ['Total Registered Land Area', actualAreaText],
                  [
                    'Total Land Sold Area',
                    '${CalculationEngine.indianNumberFormat.format(soldAreaSqFt.round())} Sq. Ft. ($soldKatthaStr Kattha)',
                  ],
                  if (roadAreaSqFt > 0)
                    [
                      'Roads / Pathway Allocation',
                      '${CalculationEngine.indianNumberFormat.format(roadAreaSqFt.round())} Sq. Ft. ($roadKatthaStr Kattha) [$roadCount Road${roadCount > 1 ? "s" : ""}]',
                    ],
                  [
                    'Remaining Available Land',
                    '${CalculationEngine.indianNumberFormat.format(remainingAreaSqFt.round())} Sq. Ft. ($remKatthaStr Kattha)',
                  ],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                cellStyle: const pw.TextStyle(fontSize: 8.5),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              ),
              pw.SizedBox(height: 10),

              // Section 3: Financial & Commercial Summary
              _buildSectionTitle('3. FINANCIAL & COMMERCIAL SUMMARY'),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildPdfKeyValue(
                            'Total Sales Revenue (Agreed):',
                            'Rs. ${CalculationEngine.indianNumberFormat.format(totalAgreedSales.round())}',
                          ),
                          _buildPdfKeyValue(
                            'Cash Collected (Realized Income):',
                            'Rs. ${CalculationEngine.indianNumberFormat.format(cashCollected.round())}',
                          ),
                          _buildPdfKeyValue(
                            'Total Recorded Expenses:',
                            'Rs. ${CalculationEngine.indianNumberFormat.format(totalExpenseAmount.round())}',
                          ),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildPdfKeyValue(
                            'Actual Project Cost (Land + Exp):',
                            'Rs. ${CalculationEngine.indianNumberFormat.format(realActualCost.round())}',
                          ),
                          _buildPdfKeyValue(
                            'Net Cash Profit / Loss:',
                            'Rs. ${CalculationEngine.indianNumberFormat.format(netCashProfit.round())}',
                          ),
                          _buildPdfKeyValue(
                            'Capitalized Expenses:',
                            'Rs. ${CalculationEngine.indianNumberFormat.format(capitalizedExpenseAmount.round())}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Signature Blocks
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 3),
                      pw.Text('Prepared By: Project Management', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
                      pw.Text('Entity: $brandingTitle', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 3),
                      pw.Text('Verified & Approved By', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
                      pw.Text('Authorized Land Authority / Partner', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Generated via $brandingTitle - Official Master Land Record',
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
            width: 130,
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
    String? phone,
    required ProjectModel project,
    required List<PlotModel> plots,
    required List<ExpenseModel> expenses,
    List<ProjectProfitLossModel> pnlList = const [],
  }) async {
    final brandingTitle = HiveService.getPdfHeaderTitle();
    final totalKatta = LandUnitConverter.sqFtToKatta(project.landAreaSqFt).toStringAsFixed(2);
    final formattedSqFt = CalculationEngine.indianNumberFormat.format(project.landAreaSqFt.round());

    final pnl = pnlList.cast<ProjectProfitLossModel?>().firstWhere(
      (p) => p?.projectId == project.id,
      orElse: () => null,
    );

    final totalAgreedSales = pnl?.totalAgreedSales ?? 0.0;
    final cashCollected = pnl?.cashCollected ?? 0.0;

    final message = '''
📊 *PROJECT MASTER & LAND OVERVIEW*
---------------------------------------
🏗️ *Project:* ${project.name} (${project.code})
📍 *Location:* ${project.location}
👤 *Landowner:* ${project.landownerName ?? "Not Assigned"}
📐 *Total Land Area:* $formattedSqFt Sq. Ft. ($totalKatta Kattha)
💰 *Purchase Price:* Rs. ${CalculationEngine.indianNumberFormat.format(project.purchasePrice.round())}
💵 *Total Agreed Sales:* ${CalculationEngine.formatCurrency(totalAgreedSales)}
📈 *Cash Collected:* ${CalculationEngine.formatCurrency(cashCollected)}

_Generated via ${brandingTitle}_
'''.trim();

    String cleanPhone = (phone ?? '').replaceAll(RegExp(r'[^\d]'), '');
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
