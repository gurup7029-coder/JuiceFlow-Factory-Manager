import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/services/pdf_invoice_service.dart';
import '../../core/services/whatsapp_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/factory_profile.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/factory_data_provider.dart';
import 'customer_orders_screen.dart';

class CustomerCheckoutScreen extends StatefulWidget {
  final Map<Product, int> selectedItems;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final VoidCallback? onOrderPlaced;

  const CustomerCheckoutScreen({
    super.key,
    required this.selectedItems,
    this.customerName = 'Valued Customer',
    this.customerPhone = '9876543210',
    this.customerAddress = 'Shop #12, Market Road, Chennai',
    this.onOrderPlaced,
  });

  @override
  State<CustomerCheckoutScreen> createState() => _CustomerCheckoutScreenState();
}

class _CustomerCheckoutScreenState extends State<CustomerCheckoutScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  final TextEditingController _couponController = TextEditingController();

  late Map<Product, int> _items;
  String _selectedPaymentMethod = 'UPI'; // UPI, Card, NetBanking, COD
  String _appliedCoupon = '';
  double _couponDiscount = 0.0;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _items = Map.from(widget.selectedItems);
    _nameController = TextEditingController(text: widget.customerName);
    _phoneController = TextEditingController(text: widget.customerPhone);
    _addressController = TextEditingController(text: widget.customerAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  double get _subtotal {
    double sum = 0.0;
    _items.forEach((product, qty) {
      sum += product.sellingPrice * qty;
    });
    return sum;
  }

  double get _taxAmount => _subtotal * 0.05; // 5% GST on cold-pressed beverages
  double get _deliveryFee => _subtotal >= 250.0 || _subtotal == 0 ? 0.0 : 30.0;
  double get _grandTotal => (_subtotal - _couponDiscount + _taxAmount + _deliveryFee).clamp(0.0, 999999.0);

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    if (code == 'FRESH10' || code == 'JUICEFLOW10') {
      setState(() {
        _appliedCoupon = code;
        _couponDiscount = _subtotal * 0.10; // 10% off
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Promo Code Applied! 10% Instant Discount'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid promo code. Try "FRESH10"'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _processPaymentAndPlaceOrder() async {
    if (_items.isEmpty) return;

    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter customer name and phone number')),
      );
      return;
    }

    setState(() => _isProcessingPayment = true);

    // Simulated authentic payment processing delay
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final provider = Provider.of<FactoryDataProvider>(context, listen: false);
    final now = DateTime.now();
    final randomSuffix = (now.millisecondsSinceEpoch % 9000) + 1000;
    final orderNumber = 'JF-ORD-${now.year}-$randomSuffix';

    // Build order items
    final orderItems = _items.entries.map((e) {
      return OrderItem(
        productId: e.key.id,
        productName: e.key.name,
        bottleSize: e.key.bottleSize,
        quantity: e.value,
        unitPrice: e.key.sellingPrice,
      );
    }).toList();

    final isPaid = _selectedPaymentMethod != 'COD';

    final order = SalesOrder(
      id: 'ORD-${now.millisecondsSinceEpoch}',
      orderNumber: orderNumber,
      customerId: 'CUST-DIRECT',
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      customerAddress: _addressController.text.trim(),
      items: orderItems,
      subtotal: _subtotal,
      discount: _couponDiscount,
      taxAmount: _taxAmount,
      grandTotal: _grandTotal,
      paidAmount: isPaid ? _grandTotal : 0.0,
      paymentStatus: isPaid ? 'Paid' : 'Unpaid',
      deliveryStatus: 'Confirmed',
      orderDate: now,
      notes: 'Direct Customer Order via Mobile Store. Payment: $_selectedPaymentMethod',
    );

    // Save order in SQLite, update stocks & fire native notifications!
    await provider.createOrder(
      order,
      _nameController.text.trim(),
      'Customer',
    );

    widget.onOrderPlaced?.call();

    setState(() => _isProcessingPayment = false);

    // Show Confirmation & Bill Dialog
    if (mounted) {
      _showSuccessDialog(order);
    }
  }

  void _showSuccessDialog(SalesOrder order) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final isTa = appState.locale.languageCode == 'ta';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Success Checkmark
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 48),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isTa ? 'ஆர்டர் & பில் உறுதியானது!' : 'Order & Bill Confirmed!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '${isTa ? 'ஆர்டர் எண்' : 'Order ID'}: ${order.orderNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                Text(
                  isTa
                      ? 'தொழிற்சாலையில் தயாரிப்பு மற்றும் பேக்கிங் தொடங்கியது. அறிவிப்பு உங்கள் மொபைலுக்கு அனுப்பப்பட்டுள்ளது.'
                      : 'Production & packaging has commenced at plant. Push notification sent to your phone!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Scannable Bill QR Code
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: 'JUICEFLOW:${order.orderNumber}:${order.grandTotal.toInt()}:${order.customerPhone}',
                        version: QrVersions.auto,
                        size: 140,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Total: ₹${order.grandTotal.toStringAsFixed(0)} • ${order.paymentStatus}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons
                ElevatedButton.icon(
                  onPressed: () async {
                    await PdfInvoiceService.printOrShareInvoice(
                      order: order,
                      profile: FactoryProfile(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: Text(isTa ? 'அதிகாரப்பூர்வ PDF பில் பதிவிறக்கம்' : 'Download / Print Tax Invoice PDF'),
                ),
                const SizedBox(height: 8),

                OutlinedButton.icon(
                  onPressed: () {
                    WhatsAppService.sendOrderReceipt(
                      order: order,
                      profile: FactoryProfile(),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: Text(isTa ? 'வாட்ஸ்அப்பில் பில் பகிர்' : 'Share Bill on WhatsApp'),
                ),
                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(); // Close dialog
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const CustomerOrdersScreen()),
                    );
                  },
                  child: Text(
                    isTa ? 'ஆர்டர் நிலையை கண்காணிக்க ->' : 'Track Order Status ->',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTa = appState.locale.languageCode == 'ta';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(isTa ? 'தானியங்கி பில் & பணம் செலுத்துதல்' : 'Auto-Bill & Payment'),
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(isTa ? 'கார்ட் காலியாக உள்ளது' : 'Your cart is empty'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(isTa ? 'பழச்சாறுகளை தேர்வு செய்க' : 'Browse Juices'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Customer & Delivery Information Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person_pin_circle_rounded,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                isTa ? 'வாடிக்கையாளர் & விநியோக விவரங்கள்' : 'Customer & Delivery Details',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: isTa ? 'வாடிக்கையாளர் பெயர்' : 'Customer Name',
                              prefixIcon: const Icon(Icons.person_outline, size: 20),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: isTa ? 'மொபைல் எண் (WhatsApp பில்)' : 'Mobile Number (WhatsApp Bill)',
                              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: isTa ? 'டெலிவரி முகவரி / கடை' : 'Delivery Address / Outlet',
                              prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Generated Bill Invoice Section
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.receipt_long_rounded,
                                      color: Color(0xFF10B981), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    isTa ? 'உடனடி தானியங்கி பில்' : 'Live Itemized Bill',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isTa ? 'தானியங்கி கணக்கீடு' : 'AUTO-CALCULATED',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 8),

                          // Item list
                          ..._items.entries.map((entry) {
                            final product = entry.key;
                            final qty = entry.value;
                            final itemTotal = product.sellingPrice * qty;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isTa ? product.tamilName : product.name,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${product.bottleSize} • ₹${product.sellingPrice.toStringAsFixed(0)} each',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark ? Colors.white60 : Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Stepper right in bill
                                  Row(
                                    children: [
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(Icons.remove_circle_outline, size: 18),
                                        onPressed: () {
                                          setState(() {
                                            if (qty > 1) {
                                              _items[product] = qty - 1;
                                            } else {
                                              _items.remove(product);
                                            }
                                          });
                                        },
                                      ),
                                      Text(
                                        '$qty',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(Icons.add_circle_outline, size: 18),
                                        onPressed: () {
                                          setState(() {
                                            _items[product] = qty + 1;
                                          });
                                        },
                                      ),
                                    ],
                                  ),

                                  // Total
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      '₹${itemTotal.toStringAsFixed(0)}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 10),

                          // Promo code bar
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _couponController,
                                  textCapitalization: TextCapitalization.characters,
                                  decoration: InputDecoration(
                                    hintText: isTa ? 'கூப்பன் (எ.கா: FRESH10)' : 'Coupon (e.g. FRESH10)',
                                    prefixIcon: const Icon(Icons.local_offer_outlined, size: 18),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _applyCoupon,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                                child: Text(isTa ? 'பயன்படுத்து' : 'Apply'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Calculation Breakdown
                          _billSummaryRow(isTa ? 'பழச்சாறு மொத்தம் (Subtotal)' : 'Juice Subtotal',
                              '₹${_subtotal.toStringAsFixed(2)}', isDark),
                          if (_couponDiscount > 0)
                            _billSummaryRow(
                              isTa ? 'சிறப்பு தள்ளுபடி (Coupon)' : 'Promo Discount ($_appliedCoupon)',
                              '-₹${_couponDiscount.toStringAsFixed(2)}',
                              isDark,
                              color: const Color(0xFF10B981),
                            ),
                          _billSummaryRow(
                            isTa ? 'குளிர்சாதன டெலிவரி' : 'Chilled Delivery',
                            _deliveryFee == 0 ? (isTa ? 'இலவசம்' : 'FREE') : '₹${_deliveryFee.toStringAsFixed(2)}',
                            isDark,
                            color: _deliveryFee == 0 ? const Color(0xFF10B981) : null,
                          ),
                          _billSummaryRow(isTa ? 'ஜி.எஸ்.டி / வரிகள் (5% GST)' : 'Taxes (5% GST)',
                              '₹${_taxAmount.toStringAsFixed(2)}', isDark),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isTa ? 'செலுத்த வேண்டிய மொத்த தொகை' : 'Grand Total Payable',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '₹${_grandTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Payment Mode Selection
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.payment_rounded, color: Colors.blueAccent, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                isTa ? 'பணம் செலுத்தும் முறை (Payment Method)' : 'Select Payment Method',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          _paymentRadioTile(
                            'UPI',
                            '⚡ UPI / Google Pay / PhonePe / Paytm',
                            isTa ? 'உடனடி QR மற்றும் UPI மூலம் பணம் செலுத்தலாம்' : 'Instant 1-Click UPI Payment',
                            Icons.qr_code_2_rounded,
                          ),
                          _paymentRadioTile(
                            'Card',
                            '💳 Credit / Debit Card',
                            'Visa, MasterCard, RuPay Card',
                            Icons.credit_card_rounded,
                          ),
                          _paymentRadioTile(
                            'NetBanking',
                            '🏦 Net Banking',
                            'SBI, HDFC, ICICI, Axis Bank',
                            Icons.account_balance_rounded,
                          ),
                          _paymentRadioTile(
                            'COD',
                            '💵 Cash on Delivery (COD)',
                            isTa ? 'பழச்சாறு பெற்றவுடன் பணம் கொடுக்கலாம்' : 'Pay cash upon chilled delivery',
                            Icons.money_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. Pay & Confirm Button
                  ElevatedButton(
                    onPressed: _isProcessingPayment ? null : _processPaymentAndPlaceOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: _isProcessingPayment
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 14),
                              Text(
                                'Processing Secure Payment...',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : Text(
                            isTa
                                ? '₹${_grandTotal.toStringAsFixed(0)} செலுத்தி ஆர்டர் செய்க'
                                : 'PAY ₹${_grandTotal.toStringAsFixed(0)} & CONFIRM ORDER',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.security_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          isTa
                              ? '100% பாதுகாப்பான பில் & எஃப்எஸ்எஸ்ஏஐ சான்றிதழ் பெற்ற தரம்'
                              : '100% Secure Transaction • FSSAI Certified Plant Quality',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _billSummaryRow(String label, String value, bool isDark, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color ?? (isDark ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentRadioTile(String value, String title, String subtitle, IconData icon) {
    final isSelected = _selectedPaymentMethod == value;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.2),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedPaymentMethod,
        activeColor: AppColors.primary,
        onChanged: (val) {
          if (val != null) setState(() => _selectedPaymentMethod = val);
        },
        secondary: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      ),
    );
  }
}
