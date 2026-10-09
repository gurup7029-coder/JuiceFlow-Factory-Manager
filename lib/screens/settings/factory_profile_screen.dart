import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/factory_profile.dart';
import '../../providers/app_state_provider.dart';

class FactoryProfileScreen extends StatefulWidget {
  const FactoryProfileScreen({super.key});

  @override
  State<FactoryProfileScreen> createState() => _FactoryProfileScreenState();
}

class _FactoryProfileScreenState extends State<FactoryProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _factoryNameCtrl;
  late TextEditingController _companyNameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _websiteCtrl;
  late TextEditingController _gstCtrl;
  late TextEditingController _fssaiCtrl;
  late TextEditingController _invoicePrefixCtrl;

  @override
  void initState() {
    super.initState();
    final p = Provider.of<AppStateProvider>(context, listen: false).factoryProfile;
    _factoryNameCtrl = TextEditingController(text: p.factoryName);
    _companyNameCtrl = TextEditingController(text: p.companyName);
    _addressCtrl = TextEditingController(text: p.address);
    _phoneCtrl = TextEditingController(text: p.phone);
    _emailCtrl = TextEditingController(text: p.email);
    _websiteCtrl = TextEditingController(text: p.website);
    _gstCtrl = TextEditingController(text: p.gstNumber);
    _fssaiCtrl = TextEditingController(text: p.fssaiLicense);
    _invoicePrefixCtrl = TextEditingController(text: p.invoicePrefix);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    final updated = FactoryProfile(
      factoryName: _factoryNameCtrl.text.trim(),
      companyName: _companyNameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      website: _websiteCtrl.text.trim(),
      gstNumber: _gstCtrl.text.trim(),
      fssaiLicense: _fssaiCtrl.text.trim(),
      invoicePrefix: _invoicePrefixCtrl.text.trim(),
    );

    appState.updateFactoryProfile(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Factory Profile and Tax/FSSAI settings saved!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('factoryProfile')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _factoryNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Factory / Plant Name *',
                  prefixIcon: Icon(Icons.factory_outlined),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _companyNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Registered Corporate Name *',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Factory Physical Address *',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Plant Phone *',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email Address *',
                        prefixIcon: Icon(Icons.email_outlined),
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
                      controller: _gstCtrl,
                      decoration: const InputDecoration(
                        labelText: 'GSTIN Number *',
                        prefixIcon: Icon(Icons.receipt_outlined),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _fssaiCtrl,
                      decoration: const InputDecoration(
                        labelText: 'FSSAI License # *',
                        prefixIcon: Icon(Icons.verified_user_outlined),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _invoicePrefixCtrl,
                decoration: const InputDecoration(
                  labelText: 'Invoice Number Prefix',
                  prefixIcon: Icon(Icons.tag),
                  hintText: 'e.g. JF-INV-',
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.save),
                label: const Text(
                  'SAVE FACTORY PROFILE',
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
