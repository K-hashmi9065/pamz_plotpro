import 'package:flutter/foundation.dart';

/// Notification Channel Type
enum NotificationChannel {
  whatsApp,
  sms,
}

/// Notification Settings Model (Configurable Provider Settings)
class NotificationSettingsModel {
  final bool enableWhatsApp;
  final bool enableSms;
  final String whatsAppApiToken;
  final String whatsAppBusinessPhone;
  final String smsApiKey;
  final String smsSenderId;
  final int overdueDaysThreshold;

  const NotificationSettingsModel({
    this.enableWhatsApp = true,
    this.enableSms = true,
    this.whatsAppApiToken = '',
    this.whatsAppBusinessPhone = '',
    this.smsApiKey = '',
    this.smsSenderId = 'LANDSYS',
    this.overdueDaysThreshold = 7,
  });

  NotificationSettingsModel copyWith({
    bool? enableWhatsApp,
    bool? enableSms,
    String? whatsAppApiToken,
    String? whatsAppBusinessPhone,
    String? smsApiKey,
    String? smsSenderId,
    int? overdueDaysThreshold,
  }) {
    return NotificationSettingsModel(
      enableWhatsApp: enableWhatsApp ?? this.enableWhatsApp,
      enableSms: enableSms ?? this.enableSms,
      whatsAppApiToken: whatsAppApiToken ?? this.whatsAppApiToken,
      whatsAppBusinessPhone: whatsAppBusinessPhone ?? this.whatsAppBusinessPhone,
      smsApiKey: smsApiKey ?? this.smsApiKey,
      smsSenderId: smsSenderId ?? this.smsSenderId,
      overdueDaysThreshold: overdueDaysThreshold ?? this.overdueDaysThreshold,
    );
  }
}

/// Centralized Configurable Notification Architecture for WhatsApp & SMS (PRD §19)
class NotificationService {
  static NotificationSettingsModel _settings = const NotificationSettingsModel();

  static NotificationSettingsModel get currentSettings => _settings;

  static void updateSettings(NotificationSettingsModel newSettings) {
    _settings = newSettings;
  }

  /// Generate & Send Payment Reminder Message
  static Future<bool> sendPaymentReminder({
    required String recipientName,
    required String phone,
    required int installmentNumber,
    required double dueAmount,
    required DateTime dueDate,
    required String projectName,
    required NotificationChannel channel,
  }) async {
    final formattedDate = '${dueDate.day}/${dueDate.month}/${dueDate.year}';
    final message = 'Dear $recipientName, your Installment #$installmentNumber of ₹${dueAmount.toStringAsFixed(2)} for project "$projectName" is due on $formattedDate. Please make payment to avoid overdue charges. Thank you!';

    return _dispatch(phone: phone, message: message, channel: channel);
  }

  /// Generate & Send Overdue Payment Alert
  static Future<bool> sendOverdueNotice({
    required String recipientName,
    required String phone,
    required int installmentNumber,
    required double dueAmount,
    required int daysOverdue,
    required String projectName,
    required NotificationChannel channel,
  }) async {
    final message = 'URGENT NOTICE: Dear $recipientName, your Installment #$installmentNumber of ₹${dueAmount.toStringAsFixed(2)} for project "$projectName" is OVERDUE by $daysOverdue days. Please clear outstanding dues immediately.';

    return _dispatch(phone: phone, message: message, channel: channel);
  }

  /// Generate & Send Payment Receipt Notification
  static Future<bool> sendPaymentReceipt({
    required String recipientName,
    required String phone,
    required double amountPaid,
    required String referenceNumber,
    required String projectName,
    required NotificationChannel channel,
  }) async {
    final message = 'PAYMENT RECEIVED: Dear $recipientName, we have received ₹${amountPaid.toStringAsFixed(2)} for project "$projectName" (Ref: $referenceNumber). Receipt saved successfully.';

    return _dispatch(phone: phone, message: message, channel: channel);
  }

  /// Generate & Send Investor Profit Distribution Update
  static Future<bool> sendInvestorProfitNotice({
    required String investorName,
    required String phone,
    required String projectName,
    required double profitShareAmount,
    required NotificationChannel channel,
  }) async {
    final message = 'INVESTOR UPDATE: Dear $investorName, profit settlement of ₹${profitShareAmount.toStringAsFixed(2)} for project "$projectName" has been approved and processed. Thank you for your partnership!';

    return _dispatch(phone: phone, message: message, channel: channel);
  }

  static Future<bool> _dispatch({
    required String phone,
    required String message,
    required NotificationChannel channel,
  }) async {
    if (channel == NotificationChannel.whatsApp && !_settings.enableWhatsApp) {
      if (kDebugMode) print('WhatsApp notifications currently disabled in settings.');
      return false;
    }
    if (channel == NotificationChannel.sms && !_settings.enableSms) {
      if (kDebugMode) print('SMS notifications currently disabled in settings.');
      return false;
    }

    if (kDebugMode) {
      print('--- [NOTIFICATION DISPATCHED] ---');
      print('Channel: ${channel.name.toUpperCase()}');
      print('To Phone: $phone');
      print('Payload: $message');
      print('----------------------------------');
    }

    // Standardized payload dispatch architecture ready for external API webhooks / SDKs
    return true;
  }
}
