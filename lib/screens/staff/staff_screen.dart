import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../models/staff.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/factory_data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/stat_badge.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  void _showAddStaffDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController(text: 'EMP-PRD-${(DateTime.now().millisecond % 89) + 10}');
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final deptCtrl = TextEditingController(text: 'Production & Packaging');
    String role = AppConstants.roleProduction;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Factory Worker / Staff'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Staff Name *'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: codeCtrl,
                    decoration: const InputDecoration(labelText: 'Employee ID / Code *'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: 'Assigned Role'),
                    items: [
                      DropdownMenuItem(value: AppConstants.roleAdmin, child: const Text('Owner / Admin')),
                      DropdownMenuItem(value: AppConstants.roleManager, child: const Text('Factory Manager')),
                      DropdownMenuItem(value: AppConstants.roleProduction, child: const Text('Production Operator')),
                      DropdownMenuItem(value: AppConstants.roleInventory, child: const Text('Inventory Keeper')),
                      DropdownMenuItem(value: AppConstants.roleSales, child: const Text('Sales Representative')),
                    ],
                    onChanged: (val) => setState(() => role = val!),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone Number *'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: deptCtrl,
                    decoration: const InputDecoration(labelText: 'Department'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
                  final provider = Provider.of<FactoryDataProvider>(context, listen: false);
                  final appState = Provider.of<AppStateProvider>(context, listen: false);

                  final staff = Staff(
                    id: const Uuid().v4(),
                    name: nameCtrl.text.trim(),
                    employeeCode: codeCtrl.text.trim(),
                    role: role,
                    phone: phoneCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    joiningDate: DateTime.now(),
                    department: deptCtrl.text.trim(),
                    batchesHandled: 0,
                    ordersHandled: 0,
                  );

                  provider.addStaff(staff, appState.currentUserName, appState.currentRole);
                  Navigator.pop(context);
                },
                child: const Text('Enrol Staff'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('staff')),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: AppColors.primary),
            onPressed: () => _showAddStaffDialog(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: provider.staffList.length,
        itemBuilder: (context, index) {
          final s = provider.staffList[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CustomCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: Text(
                      s.name.isNotEmpty ? s.name[0] : 'S',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(
                          '${s.employeeCode} • ${s.department}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '📞 ${s.phone} • Batches: ${s.batchesHandled} • Orders: ${s.ordersHandled}',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatBadge(
                    label: _formatRoleBadge(s.role),
                    color: _roleColor(s.role),
                    fontSize: 10,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_staff',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showAddStaffDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Staff'),
      ),
    );
  }

  String _formatRoleBadge(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'manager':
        return 'Manager';
      case 'production_staff':
        return 'Production';
      case 'inventory_staff':
        return 'Inventory';
      case 'sales_staff':
        return 'Sales';
      default:
        return role;
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'manager':
        return Colors.indigo;
      case 'production_staff':
        return AppColors.primary;
      case 'inventory_staff':
        return AppColors.accent;
      case 'sales_staff':
        return AppColors.secondary;
      default:
        return Colors.grey;
    }
  }
}
