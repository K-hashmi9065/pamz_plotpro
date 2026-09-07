import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/calculation_engine.dart';

class WhatsAppShareService {
  /// Generates standard wa.me Uri for WhatsApp Web / Desktop sharing
  static Uri generateWhatsAppUri({required String phone, required String message}) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final encodedMsg = Uri.encodeComponent(message);
    return Uri.parse('https://wa.me/$cleanPhone?text=$encodedMsg');
  }

  /// Launch WhatsApp Desktop / Browser with pre-filled message, or fallback to Copy
  static Future<bool> launchWhatsAppShare({
    required BuildContext context,
    required String phone,
    required String message,
  }) async {
    try {
      final uri = generateWhatsAppUri(phone: phone, message: message);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) return true;

      // Fallback if url_launcher could not open WhatsApp
      if (context.mounted) {
        showFallbackCopyDialog(context, message);
      }
      return false;
    } catch (_) {
      if (context.mounted) {
        showFallbackCopyDialog(context, message);
      }
      return false;
    }
  }

  /// Show standard Fallback Copy Dialog if WhatsApp Desktop / Web cannot be opened
  static void showFallbackCopyDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.border),
        ),
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.accent, size: 22),
            const SizedBox(width: 8),
            Text('Share Message', style: AppTypography.cardTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WhatsApp could not be opened. You can copy the message and share it manually.',
              style: AppTypography.body,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  message,
                  style: AppTypography.secondary.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy_outlined, size: 16),
            label: const Text('Copy Message'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: message));
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied to clipboard!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// Show standard interactive Share Dialog with [ Share via WhatsApp ] and [ Copy Message ]
  static void showShareOptionsModal({
    required BuildContext context,
    required String title,
    required String phone,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            const Icon(Icons.share_outlined, color: AppColors.accent, size: 22),
            const SizedBox(width: 8),
            Text('Share $title', style: AppTypography.cardTitle),
          ],
        ),
        content: Container(
          width: 480,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Message Preview:', style: AppTypography.secondary.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SelectableText(
                message,
                style: AppTypography.body.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.copy_outlined, size: 16),
            label: const Text('Copy Message'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: message));
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied to clipboard!')),
                );
              }
            },
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
            icon: const Icon(Icons.send_outlined, size: 16, color: Colors.white),
            label: const Text('Share via WhatsApp', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.of(ctx).pop();
              launchWhatsAppShare(context: context, phone: phone, message: message);
            },
          ),
        ],
      ),
    );
  }

  // --- PRE-FORMATTED MESSAGES FROM REAL DATA ---

  static String formatPaymentReceiptMessage({
    required String projectName,
    required String customerName,
    required String plotNumber,
    required double salePrice,
    required double totalPaid,
    required double outstanding,
    required double paymentReceived,
    required DateTime paymentDate,
    required String referenceNumber,
  }) {
    final dateStr = '${paymentDate.day.toString().padLeft(2, '0')} ${_getMonthName(paymentDate.month)} ${paymentDate.year}';
    return '''
Payment Receipt

Project: $projectName
Customer: $customerName
Plot No: $plotNumber

Sale Amount: ${CalculationEngine.formatCurrency(salePrice)}
Total Paid: ${CalculationEngine.formatCurrency(totalPaid)}
Outstanding: ${CalculationEngine.formatCurrency(outstanding)}

Payment Received:
${CalculationEngine.formatCurrency(paymentReceived)}

Payment Date:
$dateStr

Transaction Reference:
$referenceNumber

Thank you.
''';
  }

  static String formatPaymentReminderMessage({
    required String projectName,
    required String customerName,
    required String plotNumber,
    required int installmentNumber,
    required double dueAmount,
    required DateTime dueDate,
    required double totalOutstanding,
  }) {
    final dateStr = '${dueDate.day.toString().padLeft(2, '0')} ${_getMonthName(dueDate.month)} ${dueDate.year}';
    return '''
Payment Reminder

Project: $projectName
Customer: $customerName
Plot No: $plotNumber

Installment #$installmentNumber Due Amount:
${CalculationEngine.formatCurrency(dueAmount)}

Due Date:
$dateStr

Total Outstanding:
${CalculationEngine.formatCurrency(totalOutstanding)}

Please clear the installment on or before the due date. Thank you.
''';
  }

  static String formatInvestorStatementMessage({
    required String projectName,
    required String investorName,
    required double capitalInvested,
    required double ownershipPercent,
    required double profitEarned,
    required double totalDistributed,
    required double netSettlement,
  }) {
    return '''
Investor Statement

Project: $projectName
Investor: $investorName

Capital Invested: ${CalculationEngine.formatCurrency(capitalInvested)}
Ownership Share: ${ownershipPercent.toStringAsFixed(1)}%

Total Profit Earned: ${CalculationEngine.formatCurrency(profitEarned)}
Distributions Paid: ${CalculationEngine.formatCurrency(totalDistributed)}

Net Settlement Balance:
${CalculationEngine.formatCurrency(netSettlement)}

Thank you.
''';
  }

  static String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1).clamp(0, 11)];
  }
}
