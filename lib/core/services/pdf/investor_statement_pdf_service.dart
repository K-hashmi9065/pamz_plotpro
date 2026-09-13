import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../features/investors/domain/investor_model.dart';
import '../../../features/investors/domain/project_investor_model.dart';
import '../../../features/projects/domain/project_model.dart';

class InvestorWithdrawalRecord {
  final DateTime date;
  final double amount;
  final String reference;
  final String disbursedBy;

  const InvestorWithdrawalRecord({
    required this.date,
    required this.amount,
    required this.reference,
    required this.disbursedBy,
  });
}

class InvestorStatementPdfService {
  static final _currencyFmt =
      NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 0);
  static final _dateTimeFmt = DateFormat('dd MMM yyyy, hh:mm a');

  static Future<Uint8List> generateStatementPdf({
    required ProjectModel project,
    required InvestorModel? investor,
    required String investorName,
    required double ownershipPercent,
    required List<ProjectInvestorModel> investments,
    required List<InvestorWithdrawalRecord> withdrawals,
    double profitShare = 0.0,
  }) async {
    final pdf = pw.Document();

    final totalInvested = investments.fold(0.0, (s, i) => s + i.investedAmount);
    final totalWithdrawn = withdrawals.fold(0.0, (s, w) => s + w.amount);
    final totalEntitled = totalInvested + profitShare;
    final remainingBalance = (totalEntitled - totalWithdrawn).clamp(0.0, double.infinity);

    final statementNo = 'INV-STMT-${project.code}-${investments.isNotEmpty ? investments.first.id.substring(0, 6).toUpperCase() : "001"}';
    final issueDate = _dateTimeFmt.format(DateTime.now());

    final double landSqFt = project.landAreaSqFt;
    final double kattha = landSqFt / 1125.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header & Branding
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PAMZ PlotPro',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.Text(
                      'Enterprise Real Estate & Land Development',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Project: ${project.name} (${project.code})',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                    if (project.location.isNotEmpty)
                      pw.Text(
                        'Location: ${project.location}',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: remainingBalance <= 0 ? PdfColors.green50 : PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(4),
                        border: pw.Border.all(
                          color: remainingBalance <= 0 ? PdfColors.green700 : PdfColors.blue700,
                          width: 1,
                        ),
                      ),
                      child: pw.Text(
                        'INVESTOR INVESTMENT & WITHDRAWAL STATEMENT',
                        style: pw.TextStyle(
                          fontSize: 9.5,
                          fontWeight: pw.FontWeight.bold,
                          color: remainingBalance <= 0 ? PdfColors.green900 : PdfColors.blue900,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text('Statement #: $statementNo', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Generated: $issueDate', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                    pw.Text('Ownership Share: ${ownershipPercent.toStringAsFixed(2)}%', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey400),
            pw.SizedBox(height: 8),

            // Investor & Project Details Row
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Investor Details Box
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'INVESTOR PROFILE',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Name: $investorName', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                          'Phone: ${(investor?.phone != null && investor!.phone.trim().isNotEmpty) ? investor.phone.trim() : "N/A"}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                        if (investor?.email != null && investor!.email!.trim().isNotEmpty)
                          pw.Text('Email: ${investor.email!.trim()}', style: const pw.TextStyle(fontSize: 9)),
                        if (investor?.pan != null && investor!.pan!.trim().isNotEmpty)
                          pw.Text('PAN: ${investor.pan!.trim()}', style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                // Project Details Box
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PROJECT OVERVIEW & LAND DETAILS',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Project Name: ${project.name}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Project Code: ${project.code}', style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('Land Area: ${NumberFormat("#,##,###.##").format(landSqFt)} sq ft (${kattha.toStringAsFixed(2)} Kattha)', style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('Project Status: ${project.status.name.toUpperCase()}', style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),

            // Financial Summary KPI Box
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.blue200),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('TOTAL CONTRIBUTED CAPITAL', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                      pw.SizedBox(height: 2),
                      pw.Text(_currencyFmt.format(totalInvested), style: pw.TextStyle(fontSize: 12.5, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                    ],
                  ),
                  if (profitShare > 0)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('PROFIT SHARE', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                        pw.SizedBox(height: 2),
                        pw.Text(_currencyFmt.format(profitShare), style: pw.TextStyle(fontSize: 12.5, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                      ],
                    ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('TOTAL WITHDRAWN', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                      pw.SizedBox(height: 2),
                      pw.Text(_currencyFmt.format(totalWithdrawn), style: pw.TextStyle(fontSize: 12.5, fontWeight: pw.FontWeight.bold, color: PdfColors.orange800)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('REMAINING BALANCE', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        _currencyFmt.format(remainingBalance),
                        style: pw.TextStyle(
                          fontSize: 12.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // TABLE 1: Capital Investment Transaction History
            pw.Text(
              '1. CAPITAL INVESTMENTS TRANSACTION HISTORY (${investments.length} Records)',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
            ),
            pw.SizedBox(height: 6),

            if (investments.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(4)),
                child: pw.Center(child: pw.Text('No capital investments recorded.', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700))),
              )
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('#', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Investment Date & Timestamp', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Method / Allocation', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Ownership %', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Status', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Invested Capital', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...investments.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final inv = entry.value;
                    final dateStr = _dateTimeFmt.format(inv.createdAt);

                    return pw.TableRow(
                      decoration: pw.BoxDecoration(color: entry.key.isEven ? PdfColors.white : PdfColors.grey50),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('$idx', style: const pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(dateStr, style: const pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(inv.ownershipMethod.name.toUpperCase(), style: const pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('${inv.ownershipPercent.toStringAsFixed(2)}%', style: const pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('ACTIVE CAPITAL', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(_currencyFmt.format(inv.investedAmount), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    );
                  }),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('')),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Total Invested Capital', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('')),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${ownershipPercent.toStringAsFixed(2)}%', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('')),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(_currencyFmt.format(totalInvested), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.green800))),
                    ],
                  ),
                ],
              ),
            pw.SizedBox(height: 16),

            // TABLE 2: Withdrawals / Payouts Transaction History
            pw.Text(
              '2. WITHDRAWALS & PAYOUTS TRANSACTION HISTORY (${withdrawals.length} Records)',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
            ),
            pw.SizedBox(height: 6),

            if (withdrawals.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(4)),
                child: pw.Center(child: pw.Text('No withdrawals or payouts recorded yet.', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700))),
              )
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('#', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Withdrawal Date & Timestamp', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Payment Reference / UTR', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Disbursed By', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Status', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Withdrawn Amount', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...withdrawals.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final w = entry.value;
                    final dateStr = _dateTimeFmt.format(w.date);

                    return pw.TableRow(
                      decoration: pw.BoxDecoration(color: entry.key.isEven ? PdfColors.white : PdfColors.grey50),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('$idx', style: const pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(dateStr, style: const pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(w.reference, style: const pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(w.disbursedBy, style: const pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('DISBURSED', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(_currencyFmt.format(w.amount), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    );
                  }),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('')),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Total Withdrawn to Date', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('')),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('')),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('')),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(_currencyFmt.format(totalWithdrawn), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.orange800))),
                    ],
                  ),
                ],
              ),
            pw.SizedBox(height: 24),

            // Terms & Signatures
            pw.Divider(thickness: 0.8, color: PdfColors.grey400),
            pw.SizedBox(height: 4),
            pw.Text(
              'Official capital & withdrawal statement. Verified and issued by PAMZ PlotPro management.',
              style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(width: 140, height: 1, color: PdfColors.grey600),
                    pw.SizedBox(height: 4),
                    pw.Text('Investor Signature', style: const pw.TextStyle(fontSize: 8.5)),
                    pw.Text(investorName, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(width: 160, height: 1, color: PdfColors.grey600),
                    pw.SizedBox(height: 4),
                    pw.Text('Authorized Signatory & Seal', style: const pw.TextStyle(fontSize: 8.5)),
                    pw.Text('PAMZ PlotPro Management', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static Future<String?> savePdfToDownloads({
    required Uint8List pdfBytes,
    required String filename,
  }) async {
    try {
      Directory? downloadsDir;
      if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'];
        if (userProfile != null) {
          downloadsDir = Directory('$userProfile\\Downloads');
        }
      }
      downloadsDir ??= await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();

      final file = File('${downloadsDir.path}${Platform.pathSeparator}$filename');
      await file.writeAsBytes(pdfBytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }
}
