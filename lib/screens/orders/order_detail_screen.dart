import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/pdf_invoice_service.dart';
import '../../core/services/whatsapp_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/order.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/factory_data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_badge.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  void _showUpdateDeliveryDialog(BuildContext context, SalesOrder order) {
    String current = order.deliveryStatus;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Update Delivery Status'),
            content: DropdownButtonFormField<String>(
              value: current,
              items: [
                AppConstants.orderStatusNew,
                AppConstants.orderStatusConfirmed,
                AppConstants.orderStatusProcessing,
                AppConstants.orderStatusPacked,
                AppConstants.orderStatusDispatched,
                AppConstants.orderStatusDelivered,
                AppConstants.orderStatusCancelled,
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => current = val!),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final provider = Provider.of<FactoryDataProvider>(context, listen: false);
                  final appState = Provider.of<AppStateProvider>(context, listen: false);
                  provider.updateOrderStatus(
                    order.id,
                    current,
                    order.paymentStatus,
                    order.paidAmount,
                    appState.currentUserName,
                    appState.currentRole,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRecordPaymentDialog(BuildContext context, SalesOrder order) {
    final paidCtrl = TextEditingController(text: '${order.grandTotal}');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Record Customer Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Grand Total: ₹${order.grandTotal.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            TextField(
              controller: paidCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount Paid (₹)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final paid = double.tryParse(paidCtrl.text) ?? order.paidAmount;
              String paymentStatus = AppConstants.paymentStatusUnpaid;
              if (paid >= order.grandTotal) {
                paymentStatus = AppConstants.paymentStatusPaid;
              } else if (paid > 0) {
                paymentStatus = AppConstants.paymentStatusPartial;
              }

              final provider = Provider.of<FactoryDataProvider>(context, listen: false);
              final appState = Provider.of<AppStateProvider>(context, listen: false);

              provider.updateOrderStatus(
                order.id,
                order.deliveryStatus,
                paymentStatus,
                paid,
                appState.currentUserName,
                appState.currentRole,
              );
              Navigator.pop(context);
            },
            child: const Text('Save Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final provider = Provider.of<FactoryDataProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final order = provider.orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => provider.orders.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(order.orderNumber),
        actions: [
          IconButton(
            tooltip: 'WhatsApp Dispatch Notice',
            icon: const Icon(Icons.send_rounded, color: Color(0xFF25D366)),
            onPressed: () {
              WhatsAppDispatchService.shareOrderDispatch(order);
            },
          ),
          IconButton(
            tooltip: 'Share / Print PDF Invoice',
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
            onPressed: () {
              PdfInvoiceService.printOrShareInvoice(
                order: order,
                profile: appState.factoryProfile,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status and Customer Card
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      StatBadge(label: order.deliveryStatus, color: order.statusColor),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    order.customerName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.customerAddress} • ${order.customerPhone}',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order Date: ${Formatters.date(order.orderDate)}',
                          style: const TextStyle(fontSize: 11)),
                      StatBadge(
                        label: order.paymentStatus.toUpperCase(),
                        color: order.paymentColor,
                        fontSize: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Itemized Bill Table
            SectionHeader(title: 'Ordered Juice Products'),
            CustomCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ...order.items.asMap().entries.map((entry) {
                    final item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(Icons.local_drink, size: 16, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                                ),
                                Text(
                                  '${item.quantity} bottles × ₹${item.unitPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            Formatters.currency(item.totalPrice),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 20),
                  _summaryRow('Subtotal', Formatters.currency(order.subtotal)),
                  if (order.discount > 0)
                    _summaryRow('Discount', '-${Formatters.currency(order.discount)}'),
                  _summaryRow('GST / Tax (12%)', Formatters.currency(order.taxAmount)),
                  const SizedBox(height: 6),
                  _summaryRow('Grand Total', Formatters.currency(order.grandTotal), isBold: true),
                  _summaryRow('Paid Amount', Formatters.currency(order.paidAmount),
                      color: AppColors.success),
                  if (order.balanceAmount > 0)
                    _summaryRow('Balance Due', Formatters.currency(order.balanceAmount),
                        isBold: true, color: AppColors.error),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // PDF Tax Invoice Action
            ElevatedButton.icon(
              onPressed: () {
                PdfInvoiceService.printOrShareInvoice(
                  order: order,
                  profile: appState.factoryProfile,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text(
                'GENERATE & PRINT TAX INVOICE (PDF)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),

            // Order Actions Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showUpdateDeliveryDialog(context, order),
                    icon: const Icon(Icons.local_shipping_outlined),
                    label: const Text('Update Delivery'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRecordPaymentDialog(context, order),
                    icon: const Icon(Icons.payment),
                    label: const Text('Record Payment'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isBold ? 13 : 11.5,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: isBold ? 14 : 11.5,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
        ],
      ),
    );
  }
}
