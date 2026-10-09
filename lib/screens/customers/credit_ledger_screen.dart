import 'package:flutter/material.dart';
import '../../core/services/whatsapp_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/glass_card.dart';

class CreditLedgerScreen extends StatefulWidget {
  const CreditLedgerScreen({super.key});

  @override
  State<CreditLedgerScreen> createState() => _CreditLedgerScreenState();
}

class _CreditLedgerScreenState extends State<CreditLedgerScreen> {
  String _selectedFilter = 'all'; // all, overdue, critical
  String _searchQuery = '';

  final List<Map<String, dynamic>> _debtors = [
    {
      'id': 'CUST-01',
      'business': 'Nilgiris Supermarket (RS Puram)',
      'contact': 'Ramesh Kumar',
      'phone': '+91 98421 23456',
      'creditLimit': 100000.0,
      'outstanding': 68500.0,
      'overdue': 34200.0,
      'daysOverdue': 18,
      'lastPayment': '01 Oct 2026',
    },
    {
      'id': 'CUST-02',
      'business': 'Green Leaf Juice Lounge & Cafe',
      'contact': 'Praveen Chandran',
      'phone': '+91 98421 67890',
      'creditLimit': 50000.0,
      'outstanding': 52000.0,
      'overdue': 52000.0,
      'daysOverdue': 38,
      'lastPayment': '12 Sep 2026',
    },
    {
      'id': 'CUST-03',
      'business': 'Le Meridien Breakfast Pantry',
      'contact': 'Chef Anand',
      'phone': '+91 98421 11223',
      'creditLimit': 150000.0,
      'outstanding': 86000.0,
      'overdue': 0.0,
      'daysOverdue': 6,
      'lastPayment': '04 Oct 2026',
    },
    {
      'id': 'CUST-04',
      'business': 'Annapoorna Beverage Junction',
      'contact': 'Vignesh S.',
      'phone': '+91 98421 99887',
      'creditLimit': 60000.0,
      'outstanding': 42000.0,
      'overdue': 28000.0,
      'daysOverdue': 22,
      'lastPayment': '24 Sep 2026',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double totalOutstanding = 0;
    double currentAging = 0;
    double overdueAging = 0;
    double criticalAging = 0;

    for (final d in _debtors) {
      final bal = d['outstanding'] as double;
      final days = d['daysOverdue'] as int;
      totalOutstanding += bal;
      if (days <= 15) {
        currentAging += bal;
      } else if (days <= 30) {
        overdueAging += bal;
      } else {
        criticalAging += bal;
      }
    }

    final filtered = _debtors.where((d) {
      final biz = (d['business'] as String).toLowerCase();
      final contact = (d['contact'] as String).toLowerCase();
      final matchesSearch = biz.contains(_searchQuery.toLowerCase()) || contact.contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      final days = d['daysOverdue'] as int;
      if (_selectedFilter == 'overdue') return days > 15;
      if (_selectedFilter == 'critical') return days > 30;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Credit & Aging Ledger'),
        actions: [
          IconButton(
            tooltip: 'Export Statement PDF',
            icon: const Icon(Icons.picture_as_pdf_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Customer Aging Summary exported as PDF')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Aging Summary Top Board
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131826) : Colors.white,
              border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Receivables Outstanding', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      Formatters.currency(totalOutstanding),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildAgingBox('0-15 Days', Formatters.currency(currentAging), Colors.green),
                    const SizedBox(width: 8),
                    _buildAgingBox('16-30 Days', Formatters.currency(overdueAging), Colors.amber),
                    const SizedBox(width: 8),
                    _buildAgingBox('30+ Days', Formatters.currency(criticalAging), Colors.redAccent),
                  ],
                ),
              ],
            ),
          ),

          // Search & Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search business or contact...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip('all', 'All'),
                const SizedBox(width: 4),
                _buildFilterChip('overdue', '>15d'),
                const SizedBox(width: 4),
                _buildFilterChip('critical', '>30d'),
              ],
            ),
          ),

          // Debtors List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final d = filtered[index];
                return _buildDebtorCard(context, d, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgingBox(String title, String amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(fontSize: 9, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.grey)),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      onSelected: (_) => setState(() => _selectedFilter = filter),
    );
  }

  Widget _buildDebtorCard(BuildContext context, Map<String, dynamic> d, bool isDark) {
    final bal = d['outstanding'] as double;
    final limit = d['creditLimit'] as double;
    final days = d['daysOverdue'] as int;
    final ratio = (bal / limit).clamp(0.0, 1.0);

    Color badgeColor = Colors.green;
    String badgeText = 'Normal';
    if (days > 30) {
      badgeColor = Colors.redAccent;
      badgeText = '$days Days Overdue (Critical)';
    } else if (days > 15) {
      badgeColor = Colors.amber;
      badgeText = '$days Days Overdue';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    d['business'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${d['contact']} • ${d['phone']}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Balances & Limit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('OUTSTANDING BALANCE', style: TextStyle(color: Colors.grey, fontSize: 9)),
                    Text(
                      Formatters.currency(bal),
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: days > 15 ? Colors.redAccent : Colors.white),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('CREDIT LIMIT', style: TextStyle(color: Colors.grey, fontSize: 9)),
                    Text(
                      Formatters.currency(limit),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Limit utilization bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ratio > 0.9 ? Colors.redAccent : (ratio > 0.7 ? Colors.amber : AppTheme.primaryColor),
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 14),

            // Actions: WhatsApp Reminder + Record Payment
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: Colors.green),
                    ),
                    icon: const Icon(Icons.chat_rounded, color: Colors.green, size: 16),
                    label: const Text('WhatsApp Reminder', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      WhatsAppDispatchService.sharePaymentReminder(
                        customerName: d['contact'] as String,
                        businessName: d['business'] as String,
                        outstandingBalance: bal,
                        overdueAmount: d['overdue'] as double,
                        daysOverdue: days,
                        upiId: 'juiceflow.factory@hdfcbank',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.payment_rounded, size: 16),
                    label: const Text('Record Payment', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () => _showRecordPaymentModal(d),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRecordPaymentModal(Map<String, dynamic> d) {
    final amountCtrl = TextEditingController();
    String method = 'UPI';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Record Payment from ${d['business']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text('Current Balance: ${Formatters.currency(d['outstanding'] as double)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount Received (₹)', prefixIcon: Icon(Icons.currency_rupee_rounded)),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: method,
                    decoration: const InputDecoration(labelText: 'Payment Channel'),
                    items: const [
                      DropdownMenuItem(value: 'UPI', child: Text('UPI (GPay / PhonePe)')),
                      DropdownMenuItem(value: 'NEFT', child: Text('Bank Transfer (NEFT/RTGS)')),
                      DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                      DropdownMenuItem(value: 'Cash', child: Text('Cash at Factory Dock')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => method = val);
                    },
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: () {
                      final val = double.tryParse(amountCtrl.text);
                      if (val != null && val > 0) {
                        setState(() {
                          final currentBal = d['outstanding'] as double;
                          final newBal = (currentBal - val).clamp(0.0, double.infinity);
                          d['outstanding'] = newBal;
                          final currentOverdue = d['overdue'] as double;
                          final newOverdue = (currentOverdue - val).clamp(0.0, double.infinity);
                          d['overdue'] = newOverdue;
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Received ${Formatters.currency(val)} via $method. Balance updated!')),
                        );
                      }
                    },
                    child: const Text('Confirm Payment Entry'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
