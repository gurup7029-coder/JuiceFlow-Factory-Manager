import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/factory_data_provider.dart';

class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({super.key});

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedMaterialId;
  String _adjustmentType = 'Purchase In'; // 'Purchase In', 'Wastage / Spoiled', 'Manual Audit'
  final _qtyCtrl = TextEditingController(text: '100');
  final _reasonCtrl = TextEditingController(text: 'Supplier delivery received at warehouse.');

  void _submitAdjustment() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMaterialId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an item!')),
      );
      return;
    }

    final provider = Provider.of<FactoryDataProvider>(context, listen: false);
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    final item = provider.rawMaterials.firstWhere((m) => m.id == _selectedMaterialId);
    final double changeQty = double.tryParse(_qtyCtrl.text) ?? 0.0;
    final double newTotal = _adjustmentType == 'Purchase In'
        ? item.quantity + changeQty
        : (item.quantity - changeQty).clamp(0.0, 999999.0);

    provider.updateRawMaterialStock(
      item.id,
      newTotal,
      appState.currentUserName,
      appState.currentRole,
      '$_adjustmentType: ${_reasonCtrl.text}',
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stock updated for ${item.name}! New Level: $newTotal ${item.unit}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = Provider.of<FactoryDataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('addStock')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Material / Inventory Item *',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                value: _selectedMaterialId,
                items: provider.rawMaterials.map((m) {
                  return DropdownMenuItem(
                    value: m.id,
                    child: Text('${m.name} (Current: ${m.quantity} ${m.unit})',
                        overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedMaterialId = val),
                validator: (val) => val == null ? 'Please select an item' : null,
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Transaction Type *',
                  prefixIcon: Icon(Icons.swap_horiz),
                ),
                value: _adjustmentType,
                items: [
                  'Purchase In',
                  'Wastage / Spoiled',
                  'Manual Audit',
                ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _adjustmentType = val!),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity to Add / Adjust *',
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _reasonCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Invoice / Batch / Adjustment Reason',
                  prefixIcon: Icon(Icons.comment),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _submitAdjustment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.check),
                label: const Text(
                  'CONFIRM STOCK UPDATE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
