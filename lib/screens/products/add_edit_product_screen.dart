import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/factory_data_provider.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _tamilNameCtrl;
  late TextEditingController _codeCtrl;
  late TextEditingController _fruitCtrl;
  late TextEditingController _sellingPriceCtrl;
  late TextEditingController _costPriceCtrl;
  late TextEditingController _gstCtrl;
  late TextEditingController _minStockCtrl;
  late TextEditingController _stockCtrl;

  String _category = AppConstants.productCategories.first;
  String _bottleSize = AppConstants.bottleSizes[2]; // 500ml
  String _packagingType = 'PET Bottle';

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _tamilNameCtrl = TextEditingController(text: p?.tamilName ?? '');
    _codeCtrl = TextEditingController(text: p?.code ?? 'JF-NEW-500');
    _fruitCtrl = TextEditingController(text: p?.fruit ?? '');
    _sellingPriceCtrl = TextEditingController(text: p != null ? '${p.sellingPrice}' : '45.0');
    _costPriceCtrl = TextEditingController(text: p != null ? '${p.costPrice}' : '22.0');
    _gstCtrl = TextEditingController(text: p != null ? '${p.gstRate}' : '12.0');
    _minStockCtrl = TextEditingController(text: p != null ? '${p.minStockLevel}' : '80');
    _stockCtrl = TextEditingController(text: p != null ? '${p.currentStock}' : '150');

    if (p != null) {
      _category = p.category;
      _bottleSize = p.bottleSize;
      _packagingType = p.packagingType;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<FactoryDataProvider>(context, listen: false);
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    final product = Product(
      id: widget.product?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      tamilName: _tamilNameCtrl.text.trim(),
      code: _codeCtrl.text.trim().toUpperCase(),
      category: _category,
      fruit: _fruitCtrl.text.trim(),
      bottleSize: _bottleSize,
      packagingType: _packagingType,
      sellingPrice: double.tryParse(_sellingPriceCtrl.text) ?? 45.0,
      costPrice: double.tryParse(_costPriceCtrl.text) ?? 22.0,
      gstRate: double.tryParse(_gstCtrl.text) ?? 12.0,
      minStockLevel: int.tryParse(_minStockCtrl.text) ?? 80,
      currentStock: int.tryParse(_stockCtrl.text) ?? 150,
      isActive: true,
    );

    if (widget.product == null) {
      provider.addProduct(product, appState.currentUserName, appState.currentRole);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} created successfully!')),
      );
    } else {
      provider.updateProduct(product, appState.currentUserName, appState.currentRole);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} updated!')),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Juice Product' : 'Add New Juice Product'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () {
                final provider = Provider.of<FactoryDataProvider>(context, listen: false);
                final appState = Provider.of<AppStateProvider>(context, listen: false);
                provider.deleteProduct(widget.product!.id, appState.currentUserName, appState.currentRole);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Product Name (English) *',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _tamilNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'தயாரிப்பு பெயர் (Tamil Name) *',
                  prefixIcon: Icon(Icons.translate),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'SKU / Code *',
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _fruitCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Primary Fruit *',
                        prefixIcon: Icon(Icons.eco_outlined),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: AppConstants.productCategories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (val) => setState(() => _category = val!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _bottleSize,
                      decoration: const InputDecoration(labelText: 'Bottle Size'),
                      items: AppConstants.bottleSizes
                          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (val) => setState(() => _bottleSize = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sellingPriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Selling Price (₹) *',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _costPriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Cost Price (₹) *',
                        prefixIcon: Icon(Icons.price_change_outlined),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minStockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min Stock Level',
                        prefixIcon: Icon(Icons.warning_amber),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Current Stock',
                        prefixIcon: Icon(Icons.inventory),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.save),
                label: Text(
                  isEditing ? 'UPDATE PRODUCT' : 'CREATE PRODUCT',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
