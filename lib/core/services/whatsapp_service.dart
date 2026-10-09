import 'package:share_plus/share_plus.dart';
import '../../models/order.dart';
import '../utils/formatters.dart';

class WhatsAppDispatchService {
  static Future<void> shareOrderDispatch(SalesOrder order) async {
    final buffer = StringBuffer();
    buffer.writeln('🍹 *JUICEFLOW FACTORY DISPATCH NOTICE* 🍹');
    buffer.writeln('------------------------------------------');
    buffer.writeln('👤 *Customer:* ${order.customerName}');
    buffer.writeln('📦 *Order Number:* ${order.orderNumber}');
    buffer.writeln('📅 *Date:* ${Formatters.date(order.orderDate)}');
    buffer.writeln('🚚 *Status:* ${order.deliveryStatus.toUpperCase()}');
    buffer.writeln('💳 *Payment:* ${order.paymentStatus.toUpperCase()}');
    buffer.writeln('------------------------------------------');
    buffer.writeln('🛒 *ITEMS DISPATCHED:*');

    for (final item in order.items) {
      buffer.writeln('  • ${item.productName} (${item.bottleSize}) × ${item.quantity} bottles = ${Formatters.currency(item.totalPrice)}');
    }

    buffer.writeln('------------------------------------------');
    buffer.writeln('💰 *Total Amount:* ${Formatters.currency(order.grandTotal)}');
    buffer.writeln('');
    buffer.writeln('✨ 100% Pure Cold-Pressed Juice • FSSAI License: 10022042000189');
    buffer.writeln('Thank you for choosing JuiceFlow Factory!');

    await Share.share(
      buffer.toString(),
      subject: 'JuiceFlow Dispatch Note - ${order.orderNumber}',
    );
  }

  static Future<void> sharePaymentReminder({
    required String customerName,
    required String businessName,
    required double outstandingBalance,
    required double overdueAmount,
    required int daysOverdue,
    required String upiId,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('⚠️ *PAYMENT REMINDER • JUICEFLOW FACTORY* ⚠️');
    buffer.writeln('------------------------------------------');
    buffer.writeln('Dear *$customerName* ($businessName),');
    buffer.writeln('');
    buffer.writeln('This is a gentle reminder regarding your outstanding invoice balance with *JuiceFlow Cold-Pressed Juices*.');
    buffer.writeln('');
    buffer.writeln('💰 *Total Outstanding Balance:* ${Formatters.currency(outstandingBalance)}');
    if (overdueAmount > 0) {
      buffer.writeln('⏳ *Overdue Amount:* ${Formatters.currency(overdueAmount)} ($daysOverdue days overdue)');
    }
    buffer.writeln('------------------------------------------');
    buffer.writeln('🏦 *Payment Details:*');
    buffer.writeln('  • UPI ID: $upiId');
    buffer.writeln('  • Bank: HDFC Bank - JuiceFlow Factory A/C');
    buffer.writeln('  • IFSC: HDFC0001892');
    buffer.writeln('------------------------------------------');
    buffer.writeln('Kindly process the payment at your earliest convenience to maintain an uninterrupted juice delivery schedule.');
    buffer.writeln('Thank you for your valued partnership!');

    await Share.share(
      buffer.toString(),
      subject: 'JuiceFlow Payment Reminder - $businessName',
    );
  }

  static Future<void> shareFleetManifest({
    required String vehiclePlate,
    required String driverName,
    required String routeName,
    required int totalCrates,
    required int totalStops,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('🚚 *JUICEFLOW FLEET DISPATCH MANIFEST* 🚚');
    buffer.writeln('------------------------------------------');
    buffer.writeln('🚐 *Vehicle:* $vehiclePlate');
    buffer.writeln('👨‍✈️ *Driver:* $driverName');
    buffer.writeln('📍 *Route:* $routeName');
    buffer.writeln('📦 *Total Crates:* $totalCrates crates');
    buffer.writeln('🛑 *Delivery Stops:* $totalStops retailers');
    buffer.writeln('❄️ *Cold-Chain Temperature:* 3.8°C (Optimal)');
    buffer.writeln('------------------------------------------');
    buffer.writeln('Drive safely and ensure cold-chain integrity at all delivery drop-offs!');

    await Share.share(
      buffer.toString(),
      subject: 'JuiceFlow Dispatch Manifest - $vehiclePlate',
    );
  }

  static Future<void> sendOrderReceipt({
    required SalesOrder order,
    dynamic profile,
  }) async {
    await shareOrderDispatch(order);
  }
}

class WhatsAppService {
  static Future<void> sendOrderReceipt({
    required SalesOrder order,
    dynamic profile,
  }) async {
    await WhatsAppDispatchService.shareOrderDispatch(order);
  }

  static Future<void> shareOrderDispatch(SalesOrder order) async {
    await WhatsAppDispatchService.shareOrderDispatch(order);
  }
}
