import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/production_batch.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/factory_data_provider.dart';

class NewBatchScreen extends StatefulWidget {
  const NewBatchScreen({super.key});

  @override
  State<NewBatchScreen> createState() => _NewBatchScreenState();
}

class _NewBatchScreenState extends State<NewBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProductId;
  final _plannedQtyCtrl = TextEditingController(text: '500');
  final _batchNumberCtrl = TextEditingController();
  final _ingredientsCtrl = TextEditingController();
  final _staffCtrl = TextEditingController(text: 'Murugan (Supervisor)');
  final _notesCtrl = TextEditingController();
  final DateTime _productionDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _generateBatchNumber();
  }

  void _generateBatchNumber() {
    final year = DateTime.now().year;
    final rand = (100 + (DateTime.now().millisecond % 899));
    _batchNumberCtrl.text = 'BATCH-$year-JF-$rand';
  }

  void _onProductChanged(String? productId) {
    setState(() => _selectedProductId = productId);
    if (productId != null) {
      final provider = Provider.of<FactoryDataProvider>(context, listen: false);
      final product = provider.products.firstWhere((p) => p.id == productId);
      _ingredientsCtrl.text =
          '${product.fruit} Pulp: 150kg, Sugar: 45kg, Treated Water: 320L, Citric/Flavour: 1.2kg';
    }
  }

  void _saveBatch() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a juice product!')),
      );
      return;
    }

    final provider = Provider.of<FactoryDataProvider>(context, listen: false);
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final product = provider.products.firstWhere((p) => p.id == _selectedProductId);

    final batch = ProductionBatch(
      id: const Uuid().v4(),
      batchNumber: _batchNumberCtrl.text.trim(),
      productId: product.id,
      productName: product.name,
      productionDate: _productionDate,
      plannedQty: double.tryParse(_plannedQtyCtrl.text) ?? 500.0,
      actualQty: 0.0,
      wastageQty: 0.0,
      unit: 'Liters',
      ingredientsSummary: _ingredientsCtrl.text.trim(),
      assignedStaff: _staffCtrl.text.trim(),
      startTime: DateTime.now(),
      status: AppConstants.batchStatusPlanned,
      qcStatus: AppConstants.qcStatusPending,
      expiryDate: _productionDate.add(const Duration(days: 90)),
      notes: _notesCtrl.text.trim(),
    );

    provider.createBatch(batch, appState.currentUserName, appState.currentRole);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Production Batch ${batch.batchNumber} created!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = Provider.of<FactoryDataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('createBatch')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Juice Product *',
                  prefixIcon: Icon(Icons.local_drink),
                ),
                value: _selectedProductId,
                items: provider.products.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Text('${p.name} (${p.code})', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: _onProductChanged,
                validator: (val) => val == null ? 'Please select a product' : null,
              ),
              const SizedBox(height: 14),

              // Batch Number & Planned Qty
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _batchNumberCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Batch Number *',
                        prefixIcon: Icon(Icons.tag),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _plannedQtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Planned Volume (L) *',
                        prefixIcon: Icon(Icons.speed),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Ingredients summary
              TextFormField(
                controller: _ingredientsCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Ingredients & Recipe Formula *',
                  prefixIcon: Icon(Icons.receipt),
                  hintText: 'e.g. Mango Pulp: 150kg, Sugar: 45kg, Treated Water: 320L',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // Operator Staff
              TextFormField(
                controller: _staffCtrl,
                decoration: const InputDecoration(
                  labelText: 'Assigned Operator / Supervisor *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // Notes
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Batch Instructions / Notes',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _saveBatch,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'CONFIRM & SCHEDULE BATCH',
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
