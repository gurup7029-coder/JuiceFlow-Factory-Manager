import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/factory_data_provider.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCustomerId;
  final List<OrderItem> _selectedItems = [];
  double _discount = 0.0;
  final _discountCtrl = TextEditingController(text: '0');
  final _paidAmountCtrl = TextEditingController(text: '0');
  final String _paymentStatus = AppConstants.paymentStatusUnpaid;
  final _notesCtrl = TextEditingController();

  Product? _pickedProduct;
  int _pickedQty = 20;

  double get _subtotal => _selectedItems.fold(0.0, (sum, i) => sum + i.totalPrice);
  double get _taxAmount => (_subtotal - _discount) * 0.12;
  double get _grandTotal => (_subtotal - _discount) + _taxAmount;

  void _addItem() {
    if (_pickedProduct == null) return;
    setState(() {
      _selectedItems.add(
        OrderItem(
          productId: _pickedProduct!.id,
          productName: _pickedProduct!.name,
          bottleSize: _pickedProduct!.bottleSize,
          quantity: _pickedQty,
          unitPrice: _pickedProduct!.sellingPrice,
        ),
      );
      _pickedProduct = null;
      _pickedQty = 20;
    });
  }

  void _saveOrder() {
    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer!')),
      );
      return;
    }
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one product item!')),
      );
      return;
    }

    final provider = Provider.of<FactoryDataProvider>(context, listen: false);
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final customer = provider.customers.firstWhere((c) => c.id == _selectedCustomerId);

    final now = DateTime.now();
    final orderNum = 'JF-ORD-${now.year}-${(now.millisecond % 899) + 100}';
    final paid = double.tryParse(_paidAmountCtrl.text) ?? 0.0;

    String calculatedPaymentStatus = _paymentStatus;
    if (paid >= _grandTotal && _grandTotal > 0) {
      calculatedPaymentStatus = AppConstants.paymentStatusPaid;
    } else if (paid > 0 && paid < _grandTotal) {
      calculatedPaymentStatus = AppConstants.paymentStatusPartial;
    }

    final order = SalesOrder(
      id: const Uuid().v4(),
      orderNumber: orderNum,
      customerId: customer.id,
      customerName: customer.name,
      customerPhone: customer.phone,
      customerAddress: customer.address,
      items: _selectedItems,
      subtotal: _subtotal,
      discount: _discount,
      taxAmount: _taxAmount,
      grandTotal: _grandTotal,
      paidAmount: paid,
      paymentStatus: calculatedPaymentStatus,
      deliveryStatus: AppConstants.orderStatusNew,
      orderDate: now,
      deliveryDate: now.add(const Duration(days: 1)),
      notes: _notesCtrl.text.trim(),
    );

    provider.createOrder(order, appState.currentUserName, appState.currentRole);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order ${order.orderNumber} created! Stock automatically updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = Provider.of<FactoryDataProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('newOrder')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Select Customer
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Customer *',
                  prefixIcon: Icon(Icons.person),
                ),
                value: _selectedCustomerId,
                items: provider.customers.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text('${c.name} (${c.customerType})', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCustomerId = val),
              ),
              const SizedBox(height: 16),

              // Add Juice Items Section
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Add Products to Order',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<Product>(
                      decoration: const InputDecoration(
                        labelText: 'Select Juice Variety',
                        prefixIcon: Icon(Icons.local_drink),
                        isDense: true,
                      ),
                      value: _pickedProduct,
                      items: provider.products.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text('${p.name} - ₹${p.sellingPrice} (Stock: ${p.currentStock})'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _pickedProduct = val),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: '20',
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Bottle Quantity',
                              prefixIcon: Icon(Icons.pin),
                              isDense: true,
                            ),
                            onChanged: (val) => _pickedQty = int.tryParse(val) ?? 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Item'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Items Table / List
              if (_selectedItems.isNotEmpty) ...[
                const Text('Order Cart Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._selectedItems.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                              Text('${item.quantity} bottles @ ₹${item.unitPrice}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Text(
                          '₹${item.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 18),
                          onPressed: () => setState(() => _selectedItems.removeAt(idx)),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
              ],

              // Pricing Details
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _discountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Discount (₹)',
                        prefixIcon: Icon(Icons.discount_outlined),
                      ),
                      onChanged: (val) {
                        setState(() => _discount = double.tryParse(val) ?? 0.0);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _paidAmountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Advance Paid (₹)',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Summary card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _billRow('Subtotal', Formatters.currency(_subtotal)),
                    _billRow('Discount', '-${Formatters.currency(_discount)}'),
                    _billRow('GST (12%)', Formatters.currency(_taxAmount)),
                    const Divider(height: 16),
                    _billRow('Grand Total', Formatters.currency(_grandTotal), isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Delivery Instructions / Notes',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _saveOrder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'CONFIRM ORDER & GENERATE INVOICE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _billRow(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isBold ? 14 : 12,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(val,
              style: TextStyle(
                  fontSize: isBold ? 15 : 12,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isBold ? AppColors.primary : null)),
        ],
      ),
    );
  }
}
