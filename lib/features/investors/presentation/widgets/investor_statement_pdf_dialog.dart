import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/pdf/investor_statement_pdf_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../../projects/domain/project_model.dart';
import '../../domain/investor_model.dart';
import '../../domain/project_investor_model.dart';

class InvestorStatementPdfDialog extends StatefulWidget {
  final ProjectModel project;
  final InvestorModel? investor;
  final String investorName;
  final double ownershipPercent;
  final List<ProjectInvestorModel> investments;
  final List<InvestorWithdrawalRecord> withdrawals;
  final double profitShare;

  const InvestorStatementPdfDialog({
    super.key,
    required this.project,
    this.investor,
    required this.investorName,
    required this.ownershipPercent,
    required this.investments,
    required this.withdrawals,
    this.profitShare = 0.0,
  });

  static Future<void> show(
    BuildContext context, {
    required ProjectModel project,
    InvestorModel? investor,
    required String investorName,
    required double ownershipPercent,
    required List<ProjectInvestorModel> investments,
    required List<InvestorWithdrawalRecord> withdrawals,
    double profitShare = 0.0,
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
            child: InvestorStatementPdfDialog(
              project: project,
              investor: investor,
              investorName: investorName,
              ownershipPercent: ownershipPercent,
              investments: investments,
              withdrawals: withdrawals,
              profitShare: profitShare,
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<InvestorStatementPdfDialog> createState() =>
      _InvestorStatementPdfDialogState();
}

class _InvestorStatementPdfDialogState
    extends State<InvestorStatementPdfDialog> {
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
    InvestorModel? investor = widget.investor;
    if ((investor == null || investor.phone.isEmpty) && widget.investments.isNotEmpty) {
      final db = AppDatabase();
      final iRow = await (db.select(db.investors)..where((i) => i.id.equals(widget.investments.first.investorId))).getSingleOrNull();
      if (iRow != null) {
        investor = InvestorModel(
          id: iRow.id,
          name: iRow.name,
          phone: iRow.phone,
          email: iRow.email,
          pan: iRow.pan,
          createdAt: iRow.createdAt,
        );
      }
    }

    final bytes = await InvestorStatementPdfService.generateStatementPdf(
      project: widget.project,
      investor: investor,
      investorName: widget.investorName,
      ownershipPercent: widget.ownershipPercent,
      investments: widget.investments,
      withdrawals: widget.withdrawals,
      profitShare: widget.profitShare,
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
        'Investor_Statement_${widget.project.code}_${widget.investorName.replaceAll(' ', '_')}.pdf';
    final savedPath = await InvestorStatementPdfService.savePdfToDownloads(
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
          'Investor_Statement_${widget.project.code}_${widget.investorName.replaceAll(' ', '_')}.pdf',
    );
  }

  Future<void> _shareWhatsApp() async {
    final phone = widget.investor?.phone;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number recorded for investor.')),
      );
      return;
    }

    final totalInvested =
        widget.investments.fold(0.0, (s, i) => s + i.investedAmount);
    final totalWithdrawn =
        widget.withdrawals.fold(0.0, (s, w) => s + w.amount);
    final remaining = (totalInvested + widget.profitShare - totalWithdrawn)
        .clamp(0.0, double.infinity);

    final message = '''
🧾 *PAMZ PlotPro - INVESTOR STATEMENT*
---------------------------------------
👤 *Investor:* ${widget.investorName}
📞 *Phone:* $phone
🏗️ *Project:* ${widget.project.name} (${widget.project.code})
📊 *Ownership Share:* ${widget.ownershipPercent.toStringAsFixed(2)}%
💰 *Total Invested Capital:* ${CalculationEngine.formatCurrency(totalInvested)}
💸 *Total Withdrawn / Payouts:* ${CalculationEngine.formatCurrency(totalWithdrawn)}
📈 *Remaining Balance:* ${CalculationEngine.formatCurrency(remaining)}

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
              'Investor Statement PDF (${widget.investorName})',
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
                    'Investor_Statement_${widget.project.code}_${widget.investorName.replaceAll(' ', '_')}.pdf',
              );
            },
          ),
        );
      },
    );
  }
}
