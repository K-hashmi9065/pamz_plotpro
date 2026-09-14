import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../database/app_database.dart';
import '../../storage/hive_service.dart';
import '../../../features/landowners/domain/landowner_model.dart';
import '../../../features/landowners/domain/purchase_agreement_model.dart';
import '../../../features/projects/domain/project_model.dart';

class LandownerInvoicePdfService {
  static final _currencyFmt =
      NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 0);
  static final _dateTimeFmt = DateFormat('dd MMM yyyy, hh:mm a');
  static final _dateFmt = DateFormat('dd MMM yyyy');

  static String _formatPaymentMode(String rawMode, String? ref) {
    final mode = rawMode.trim().toLowerCase();
    String formattedMode;
    switch (mode) {
      case 'cash':
        formattedMode = 'Cash';
        break;
      case 'banktransfer':
      case 'bank_transfer':
      case 'bank':
      case 'transfer':
        formattedMode = 'Bank Transfer';
        break;
      case 'cheque':
      case 'check':
        formattedMode = 'Cheque';
        break;
      case 'upi':
      case 'online':
        formattedMode = 'UPI / Online';
        break;
      case 'neft':
        formattedMode = 'NEFT';
        break;
      case 'rtgs':
        formattedMode = 'RTGS';
        break;
      case 'imps':
        formattedMode = 'IMPS';
        break;
      default:
        formattedMode = rawMode.isEmpty ? 'Cash' : rawMode;
    }

    final cleanRef = ref?.trim();
    if (cleanRef != null &&
        cleanRef.isNotEmpty &&
        cleanRef != '—' &&
        cleanRef != '-' &&
        cleanRef.toLowerCase() != 'null') {
      return '$formattedMode (Ref: $cleanRef)';
    }
    return formattedMode;
  }

  static Future<Uint8List> generateStatementPdf({
    required ProjectModel project,
    required PurchaseAgreementModel agreement,
    LandownerModel? landowner,
    required List<Transaction> transactions,
  }) async {
    final pdf = pw.Document();

    final totalPaid = transactions.fold(0.0, (s, t) => s + t.amount);
    final remaining = (agreement.totalPrice - totalPaid).clamp(0.0, double.infinity);
    final statementNo = 'LO-STMT-${agreement.id.replaceAll("AUTO_", "").substring(0, agreement.id.replaceAll("AUTO_", "").length.clamp(0, 8)).toUpperCase()}';
    final issueDate = _dateTimeFmt.format(DateTime.now());

    final double landSqFt = project.landAreaSqFt;
    final double kattha = landSqFt / 1125.0;
    final String brandingTitle = HiveService.getPdfHeaderTitle();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header & Branding
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        brandingTitle,
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
                          color: remaining <= 0 ? PdfColors.green50 : PdfColors.blue50,
                          borderRadius: pw.BorderRadius.circular(4),
                          border: pw.Border.all(
                            color: remaining <= 0 ? PdfColors.green700 : PdfColors.blue700,
                            width: 1,
                          ),
                        ),
                        child: pw.Text(
                          remaining <= 0 ? 'LAND PURCHASE VOUCHER (SETTLED)' : 'LANDOWNER PAYMENT STATEMENT',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: remaining <= 0 ? PdfColors.green900 : PdfColors.blue900,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text('Statement #: $statementNo', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Generated: $issueDate', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                      pw.Text('Agreement Date: ${_dateFmt.format(agreement.agreementDate)}', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 8),

              // Landowner & Land Information Row
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Landowner Details Box
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
                            'LANDOWNER INFORMATION',
                            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text('Name: ${project.landownerName ?? landowner?.name ?? "Landowner"}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                            'Phone: ${(landowner?.phone != null && landowner!.phone.trim().isNotEmpty) ? landowner.phone.trim() : "N/A"}',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          if (landowner?.email != null && landowner!.email!.trim().isNotEmpty)
                            pw.Text('Email: ${landowner.email!.trim()}', style: const pw.TextStyle(fontSize: 9)),
                          if (landowner?.pan != null && landowner!.pan!.trim().isNotEmpty)
                            pw.Text('PAN: ${landowner.pan!.trim()}', style: const pw.TextStyle(fontSize: 9)),
                          if (landowner?.address != null && landowner!.address!.trim().isNotEmpty)
                            pw.Text('Address: ${landowner.address!.trim()}', style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  // Land / Project Details Box
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
                            'LAND & PROJECT SPECIFICATIONS',
                            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text('Project Name: ${project.name}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Project Code: ${project.code}', style: const pw.TextStyle(fontSize: 9)),
                          pw.Text('Total Land Area: ${NumberFormat("#,##,###.##").format(landSqFt)} sq ft (${kattha.toStringAsFixed(2)} Kattha)', style: const pw.TextStyle(fontSize: 9)),
                          pw.Text('Project Status: ${project.status.name.toUpperCase()}', style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),

              // Financial Summary Cards
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
                        pw.Text('TOTAL AGREED PURCHASE PRICE', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                        pw.SizedBox(height: 2),
                        pw.Text(_currencyFmt.format(agreement.totalPrice), style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('TOTAL PAID TO LANDOWNER', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                        pw.SizedBox(height: 2),
                        pw.Text(_currencyFmt.format(totalPaid), style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('REMAINING DUES / BALANCE', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          _currencyFmt.format(remaining),
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            color: remaining > 0 ? PdfColors.red800 : PdfColors.green800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Itemized Transaction History List
              pw.Text(
                'ITEMIZED PAYMENT TRANSACTION HISTORY (${transactions.length} Records)',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
              ),
              pw.SizedBox(height: 6),

              if (transactions.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(4)),
                  child: pw.Center(child: pw.Text('No payments disbursed to landowner yet.', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700))),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
                  children: [
                    // Table Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('#', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Payment Date & Timestamp', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Payment Mode & Reference', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Disbursed By', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Status', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Amount Disbursed', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Table Rows
                    ...transactions.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final tx = entry.value;
                      final txDateStr = _dateTimeFmt.format(tx.paymentDate);

                      return pw.TableRow(
                        decoration: pw.BoxDecoration(color: entry.key.isEven ? PdfColors.white : PdfColors.grey50),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('$idx', style: const pw.TextStyle(fontSize: 8.5)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(txDateStr, style: const pw.TextStyle(fontSize: 8.5)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(_formatPaymentMode(tx.paymentMethod, tx.referenceNumber), style: const pw.TextStyle(fontSize: 8.5)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(tx.createdBy, style: const pw.TextStyle(fontSize: 8.5)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('DISBURSED', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(_currencyFmt.format(tx.amount), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                          ),
                        ],
                      );
                    }),
                    // Total Row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Total Disbursed to Date', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(_currencyFmt.format(totalPaid), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                        ),
                      ],
                    ),
                  ],
                ),

              pw.Spacer(),

              // Terms & Signatures
              pw.Divider(thickness: 0.8, color: PdfColors.grey400),
              pw.SizedBox(height: 4),
              pw.Text(
                'Official land purchase disbursement record. Confirmed and recorded by $brandingTitle management pursuant to the executed land acquisition agreement.',
                style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 24),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey600),
                      pw.SizedBox(height: 4),
                      pw.Text('Landowner Signature', style: const pw.TextStyle(fontSize: 8.5)),
                      pw.Text(project.landownerName ?? landowner?.name ?? 'Landowner', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(width: 160, height: 1, color: PdfColors.grey600),
                      pw.SizedBox(height: 4),
                      pw.Text('Authorized Signatory & Seal', style: const pw.TextStyle(fontSize: 8.5)),
                      pw.Text('$brandingTitle Management', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          );
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
