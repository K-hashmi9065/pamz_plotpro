import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/constants/app_constants.dart';
import '../help_guide_screen.dart';

abstract class UserGuidePdfService {
  /// Generates a professional multi-page PDF document for the User Manual & Operating Guide.
  static Future<Uint8List> generateUserGuidePdf({
    required List<HelpTopic> topics,
    required bool isAdmin,
    HelpTopic? singleTopic,
  }) async {
    final doc = pw.Document(
      title: singleTopic != null
          ? 'User Guide - ${singleTopic.title}'
          : '${AppConstants.appName} - User Manual & Operating Guide',
      author: AppConstants.appName,
    );

    final fontBold = await PdfGoogleFonts.interBold();
    final fontRegular = await PdfGoogleFonts.interRegular();
    final fontMedium = await PdfGoogleFonts.interMedium();

    final primaryColor = PdfColor.fromHex('#0F172A');
    final accentColor = PdfColor.fromHex('#2563EB');
    final surfaceColor = PdfColor.fromHex('#F8FAFC');
    final borderColor = PdfColor.fromHex('#E2E8F0');
    final textColor = PdfColor.fromHex('#0F172A');
    final textMuted = PdfColor.fromHex('#64748B');
    final warningColor = PdfColor.fromHex('#D97706');

    final exportDateStr = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    final exportTopics = singleTopic != null ? [singleTopic] : topics;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        header: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      AppConstants.appName,
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 14,
                        color: primaryColor,
                      ),
                    ),
                    pw.Text(
                      ' | System Documentation',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 12,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  'Generated: $exportDateStr',
                  style: pw.TextStyle(
                    font: fontRegular,
                    fontSize: 9,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 1),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '${AppConstants.appName} v${AppConstants.appVersion} • Confidential Operational Manual',
                  style: pw.TextStyle(
                    font: fontRegular,
                    fontSize: 8,
                    color: textMuted,
                  ),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.TextStyle(
                    font: fontMedium,
                    fontSize: 9,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // Banner & Document Title Section
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              margin: const pw.EdgeInsets.only(bottom: 20),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        singleTopic != null
                            ? 'OPERATIONAL GUIDE'
                            : 'SYSTEM USER MANUAL & OPERATING GUIDE',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 14,
                          color: PdfColors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: accentColor,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          isAdmin ? 'ADMIN & MEMBER MANUAL' : 'OPERATOR MANUAL',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 8,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    singleTopic != null
                        ? singleTopic.title
                        : 'Official Standard Operating Procedures (SOP) for Land Acquisition, Plot Subdivision, Sales, and Financial Accounting.',
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 10,
                      color: PdfColors.grey300,
                    ),
                  ),
                ],
              ),
            ),

            // Table of Contents Summary (If full guide)
            if (singleTopic == null) ...[
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: surfaceColor,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: borderColor),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'TABLE OF CONTENTS',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 10,
                        color: primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    ...exportTopics.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final t = entry.value;
                      return pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 3),
                        child: pw.Row(
                          children: [
                            pw.Text(
                              '$idx. ',
                              style: pw.TextStyle(font: fontBold, fontSize: 9, color: accentColor),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                t.title,
                                style: pw.TextStyle(font: fontMedium, fontSize: 9, color: textColor),
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: pw.BoxDecoration(
                                color: t.adminOnly ? PdfColor.fromHex('#FFFBEB') : PdfColor.fromHex('#EFF6FF'),
                                borderRadius: pw.BorderRadius.circular(3),
                              ),
                              child: pw.Text(
                                t.category.toUpperCase(),
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: 7,
                                  color: t.adminOnly ? warningColor : accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            // Topics Breakdown
            ...exportTopics.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final topic = entry.value;

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: borderColor),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Topic Header Row
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            '$idx. ${topic.title}',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 13,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        pw.Row(
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#EFF6FF'),
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Text(
                                topic.category.toUpperCase(),
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: 8,
                                  color: accentColor,
                                ),
                              ),
                            ),
                            if (topic.adminOnly) ...[
                              pw.SizedBox(width: 6),
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: pw.BoxDecoration(
                                  color: PdfColor.fromHex('#FFFBEB'),
                                  borderRadius: pw.BorderRadius.circular(4),
                                  border: pw.Border.all(color: PdfColor.fromHex('#FCD34D')),
                                ),
                                child: pw.Text(
                                  'ADMIN ONLY',
                                  style: pw.TextStyle(
                                    font: fontBold,
                                    fontSize: 8,
                                    color: warningColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),

                    // Description
                    pw.Text(
                      topic.description,
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 9.5,
                        color: textColor,
                        lineSpacing: 2,
                      ),
                    ),
                    pw.SizedBox(height: 12),

                    // Operational Steps Container
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: surfaceColor,
                        borderRadius: pw.BorderRadius.circular(4),
                        border: pw.Border.all(color: borderColor),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'OPERATIONAL WALKTHROUGH & STEPS',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 8.5,
                              color: primaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            topic.steps,
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 9,
                              color: textColor,
                              lineSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 10),

                    // Why it matters
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Business Governance Impact: ',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 8.5,
                            color: accentColor,
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            topic.whyItMatters,
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 8.5,
                              color: textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    return doc.save();
  }

  /// Downloads and saves the generated PDF to the user's Downloads folder on Windows / Desktop.
  static Future<String?> savePdfToDownloads({
    required Uint8List pdfBytes,
    required String filename,
  }) async {
    try {
      Directory? downloadsDir;
      if (Platform.isWindows) {
        downloadsDir = Directory('${Platform.environment['USERPROFILE']}\\Downloads');
      }
      downloadsDir ??= await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final file = File('${downloadsDir.path}\\$filename');
      await file.writeAsBytes(pdfBytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }
}
