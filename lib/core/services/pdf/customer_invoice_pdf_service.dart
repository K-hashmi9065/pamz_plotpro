import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../database/app_database.dart';
import '../../storage/hive_service.dart';
import '../../../features/plots/domain/plot_model.dart';
import '../../../features/buyers_sales/domain/buyer_model.dart';
import '../../../features/buyers_sales/domain/sale_model.dart';

class CustomerInvoicePdfService {
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

  static Future<Uint8List> generateInvoicePdf({
    required SaleModel sale,
    BuyerModel? buyer,
    required String projectName,
    required String projectCode,
    required String projectLocation,
    List<PlotModel> plots = const [],
    required List<Transaction> transactions,
  }) async {
    final pdf = pw.Document();

    final totalPaid = transactions.fold(0.0, (s, t) => s + t.amount);
    final remaining = (sale.agreedPrice - totalPaid).clamp(0.0, double.infinity);
    final invoiceNo = 'INV-${sale.id.substring(0, 8).toUpperCase()}';
    final issueDate = _dateTimeFmt.format(DateTime.now());

    // Calculate total plot area
    final double totalSqFt = plots.fold(0.0, (sum, p) => sum + p.areaSqFt);
    final String plotNumbers = plots.isNotEmpty
        ? plots.map((p) => p.plotNumber).join(', ')
        : 'Whole Land / Project Unit';
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
                        'Project: $projectName ($projectCode)',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                      if (projectLocation.isNotEmpty)
                        pw.Text(
                          'Location: $projectLocation',
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
                          remaining <= 0 ? 'PAYMENT RECEIPT (PAID IN FULL)' : 'TAX INVOICE / PAYMENT RECEIPT',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: remaining <= 0 ? PdfColors.green900 : PdfColors.blue900,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text('Invoice #: $invoiceNo', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Generated: $issueDate', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                      pw.Text('Agreement Date: ${_dateFmt.format(sale.saleDate)}', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 8),

              // Customer & Property Information Row
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Customer Details Box
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
                            'CUSTOMER / BUYER DETAILS',
                            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text('Name: ${sale.buyerName}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                            'Phone: ${(buyer?.phone != null && buyer!.phone.trim().isNotEmpty) ? buyer.phone.trim() : "N/A"}',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          if (buyer?.email != null && buyer!.email!.trim().isNotEmpty)
                            pw.Text('Email: ${buyer.email!.trim()}', style: const pw.TextStyle(fontSize: 9)),
                          if (buyer?.pan != null && buyer!.pan!.trim().isNotEmpty)
                            pw.Text('PAN: ${buyer.pan!.trim()}', style: const pw.TextStyle(fontSize: 9)),
                          if (buyer?.aadhar != null && buyer!.aadhar!.trim().isNotEmpty)
                            pw.Text('Aadhar: ${buyer.aadhar!.trim()}', style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  // Property / Plot Details Box
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
                            'PLOT & PROPERTY SPECIFICATIONS',
                            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text('Plot ID / Number: $plotNumbers', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          if (plots.isNotEmpty) ...[
                            if (plots.length == 1) ...[
                              pw.Text('Dimensions: ${plots.first.formattedLength} x ${plots.first.formattedBreadth}', style: const pw.TextStyle(fontSize: 9)),
                              pw.Text('Area: ${plots.first.formattedArea}', style: const pw.TextStyle(fontSize: 9)),
                            ] else ...[
                              pw.Text('Total Area: ${NumberFormat("#,##,###.##").format(totalSqFt)} sq ft (${(totalSqFt / 1125.0).toStringAsFixed(2)} Kattha)', style: const pw.TextStyle(fontSize: 9)),
                              pw.Text('Total Plots: ${plots.length}', style: const pw.TextStyle(fontSize: 9)),
                            ],
                          ] else
                            pw.Text('Sale Type: ${sale.saleType.name.toUpperCase()}', style: const pw.TextStyle(fontSize: 9)),
                          pw.Text('Project Code: $projectCode', style: const pw.TextStyle(fontSize: 9)),
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
                        pw.Text('TOTAL AGREED PRICE', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                        pw.SizedBox(height: 2),
                        pw.Text(_currencyFmt.format(sale.agreedPrice), style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('TOTAL PAID AMOUNT', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
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
                  child: pw.Center(child: pw.Text('No payment transactions recorded yet.', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700))),
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
                          child: pw.Text('Status', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Amount Paid', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
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
                            child: pw.Text('CLEARED / PAID', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
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
                          child: pw.Text('Total Paid to Date', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
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

              // Terms & Verification Signatures
              pw.Divider(thickness: 0.8, color: PdfColors.grey400),
              pw.SizedBox(height: 4),
              pw.Text(
                'Note: This document serves as an official payment receipt & sales invoice. All payments recorded herein are verified and credited toward the designated plot agreement.',
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
                      pw.Text('Customer Signature', style: const pw.TextStyle(fontSize: 8.5)),
                      pw.Text(sale.buyerName, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
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
