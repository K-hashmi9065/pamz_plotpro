import 'package:flutter_test/flutter_test.dart';
import 'package:land_investment_and_sales_management/core/services/whatsapp_share_service.dart';

void main() {
  group('WhatsAppShareService Tests', () {
    test('generateWhatsAppUri formats clean wa.me link', () {
      final uri = WhatsAppShareService.generateWhatsAppUri(
        phone: '+91 98220 11223',
        message: 'Hello World',
      );

      expect(uri.toString(), startsWith('https://wa.me/919822011223?text=Hello'));
    });

    test('formatPaymentReceiptMessage matches expected format', () {
      final msg = WhatsAppShareService.formatPaymentReceiptMessage(
        projectName: 'Kishanganj Green Valley',
        customerName: 'Rahul Kumar',
        plotNumber: 'A-12',
        salePrice: 2500000.0,
        totalPaid: 1500000.0,
        outstanding: 1000000.0,
        paymentReceived: 500000.0,
        paymentDate: DateTime(2026, 9, 5),
        referenceNumber: 'TXN-2026-00125',
      );

      expect(msg, contains('Payment Receipt'));
      expect(msg, contains('Project: Kishanganj Green Valley'));
      expect(msg, contains('Customer: Rahul Kumar'));
      expect(msg, contains('Plot No: A-12'));
      expect(msg, contains('₹25,00,000'));
      expect(msg, contains('₹5,00,000'));
      expect(msg, contains('05 Sep 2026'));
      expect(msg, contains('TXN-2026-00125'));
    });

    test('formatPaymentReminderMessage matches expected format', () {
      final msg = WhatsAppShareService.formatPaymentReminderMessage(
        projectName: 'Green Acres Township',
        customerName: 'Suresh Deshmukh',
        plotNumber: 'Plot #103',
        installmentNumber: 2,
        dueAmount: 300000.0,
        dueDate: DateTime(2026, 9, 20),
        totalOutstanding: 600000.0,
      );

      expect(msg, contains('Payment Reminder'));
      expect(msg, contains('Installment #2 Due Amount:'));
      expect(msg, contains('₹3,00,000'));
      expect(msg, contains('20 Sep 2026'));
    });
  });
}
