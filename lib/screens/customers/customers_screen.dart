import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/customer.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/factory_data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/stat_badge.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String _searchQuery = '';

  void _showAddCustomerDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final businessCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    String customerType = AppConstants.customerTypes.first;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add New Customer'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: businessCtrl,
                    decoration: const InputDecoration(labelText: 'Business / Shop Name *'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Contact Person Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone Number *'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email Address'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(labelText: 'Store / Delivery Address'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: customerType,
                    decoration: const InputDecoration(labelText: 'Customer Category'),
                    items: AppConstants.customerTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setState(() => customerType = val!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (businessCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
                  final provider = Provider.of<FactoryDataProvider>(context, listen: false);
                  final appState = Provider.of<AppStateProvider>(context, listen: false);

                  final customer = Customer(
                    id: const Uuid().v4(),
                    name: nameCtrl.text.isEmpty ? businessCtrl.text : nameCtrl.text,
                    businessName: businessCtrl.text,
                    phone: phoneCtrl.text,
                    email: emailCtrl.text,
                    address: addressCtrl.text,
                    customerType: customerType,
                    outstandingBalance: 0.0,
                    createdAt: DateTime.now(),
                  );

                  provider.addCustomer(customer, appState.currentUserName, appState.currentRole);
                  Navigator.pop(context);
                },
                child: const Text('Add Customer'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = Provider.of<FactoryDataProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = provider.customers.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.businessName.toLowerCase().contains(q) ||
          c.phone.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('customers')),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: AppColors.primary),
            onPressed: () => _showAddCustomerDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search customer name, shop, phone...',
                prefixIcon: Icon(Icons.search, size: 20),
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                isDense: true,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final customer = filtered[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CustomCard(
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(Icons.storefront_rounded, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.businessName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${customer.customerType} • Contact: ${customer.name}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${customer.phone} • ${customer.address}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Formatters.currency(customer.outstandingBalance),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: customer.outstandingBalance > 0
                                    ? AppColors.error
                                    : AppColors.success,
                              ),
                            ),
                            const SizedBox(height: 4),
                            StatBadge(
                              label: customer.outstandingBalance > 0 ? 'Pending Due' : 'All Clear',
                              color: customer.outstandingBalance > 0
                                  ? AppColors.error
                                  : AppColors.success,
                              fontSize: 9.5,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_customers',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showAddCustomerDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Customer'),
      ),
    );
  }
}
