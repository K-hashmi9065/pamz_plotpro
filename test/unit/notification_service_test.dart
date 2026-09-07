import 'package:flutter_test/flutter_test.dart';
import 'package:land_investment_and_sales_management/core/services/notification_service.dart';

void main() {
  group('NotificationService Tests', () {
    test('Configurable notification settings update', () {
      const customSettings = NotificationSettingsModel(
        enableWhatsApp: true,
        enableSms: true,
        smsSenderId: 'KISHANLAND',
        overdueDaysThreshold: 5,
      );

      NotificationService.updateSettings(customSettings);
      expect(NotificationService.currentSettings.smsSenderId, equals('KISHANLAND'));
      expect(NotificationService.currentSettings.overdueDaysThreshold, equals(5));
    });

    test('Payment reminder message dispatch', () async {
      final success = await NotificationService.sendPaymentReminder(
        recipientName: 'Suresh Deshmukh',
        phone: '+919422188990',
        installmentNumber: 2,
        dueAmount: 300000.0,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        projectName: 'Green Acres Township',
        channel: NotificationChannel.whatsApp,
      );

      expect(success, isTrue);
    });

    test('Overdue notice message dispatch', () async {
      final success = await NotificationService.sendOverdueNotice(
        recipientName: 'Suresh Deshmukh',
        phone: '+919422188990',
        installmentNumber: 2,
        dueAmount: 300000.0,
        daysOverdue: 10,
        projectName: 'Green Acres Township',
        channel: NotificationChannel.sms,
      );

      expect(success, isTrue);
    });
  });
}
