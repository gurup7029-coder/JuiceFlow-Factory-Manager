import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/factory_data_provider.dart';
import '../main_navigation_screen.dart';

class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  int _currentStep = 0;

  // Controllers
  final _factoryNameCtrl = TextEditingController(text: 'FreshVibe Juice Industries');
  final _companyNameCtrl = TextEditingController(text: 'FreshVibe Agro & Beverages Pvt Ltd');
  final _addressCtrl = TextEditingController(text: 'Food Processing Park, Theni, Tamil Nadu');
  final _phoneCtrl = TextEditingController(text: '+91 98421 55678');
  final _gstCtrl = TextEditingController(text: '33AABCF9876Q1Z3');
  final _fssaiCtrl = TextEditingController(text: '12423999000145');

  final _adminNameCtrl = TextEditingController(text: 'Ramasamy Kumar');
  final _adminPhoneCtrl = TextEditingController(text: '+91 98421 55678');

  final List<String> _selectedProducts = ['Mango Juice', 'Orange Juice', 'Apple Juice', 'Pineapple Juice'];

  void _completeSetup() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final dataProvider = Provider.of<FactoryDataProvider>(context, listen: false);

    final updatedProfile = appState.factoryProfile.copyWith(
      factoryName: _factoryNameCtrl.text,
      companyName: _companyNameCtrl.text,
      address: _addressCtrl.text,
      phone: _phoneCtrl.text,
      gstNumber: _gstCtrl.text,
      fssaiLicense: _fssaiCtrl.text,
    );
    appState.updateFactoryProfile(updatedProfile);
    appState.login(_adminNameCtrl.text, AppConstants.roleAdmin);

    dataProvider.addAuditLog(
      userName: _adminNameCtrl.text,
      userRole: 'admin',
      action: 'SETUP_COMPLETE',
      module: 'Settings',
      recordAffected: _factoryNameCtrl.text,
      details: 'Completed factory onboarding setup wizard.',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Factory Profile configured successfully!')),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Factory Setup Wizard'),
        actions: [
          TextButton(
            onPressed: _completeSetup,
            child: const Text('Skip & Launch'),
          ),
        ],
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 6) {
            setState(() => _currentStep += 1);
          } else {
            _completeSetup();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == 6 ? 'Launch Factory App' : 'Next Step'),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          // Step 1: Factory Info
          Step(
            title: const Text('Factory Profile'),
            subtitle: const Text('Factory name, address, GSTIN, FSSAI'),
            isActive: _currentStep >= 0,
            content: Column(
              children: [
                TextField(
                  controller: _factoryNameCtrl,
                  decoration: const InputDecoration(labelText: 'Factory / Plant Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _companyNameCtrl,
                  decoration: const InputDecoration(labelText: 'Registered Company Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(labelText: 'Factory Address'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _gstCtrl,
                        decoration: const InputDecoration(labelText: 'GSTIN'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _fssaiCtrl,
                        decoration: const InputDecoration(labelText: 'FSSAI License #'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Step 2: Admin Info
          Step(
            title: const Text('Factory Owner / Administrator'),
            subtitle: const Text('Primary contact details'),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                TextField(
                  controller: _adminNameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _adminPhoneCtrl,
                  decoration: const InputDecoration(labelText: 'Mobile Phone'),
                ),
              ],
            ),
          ),
          // Step 3: Product Setup
          Step(
            title: const Text('Product Lines'),
            subtitle: const Text('Select initial juice varieties to produce'),
            isActive: _currentStep >= 2,
            content: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Mango Juice',
                'Orange Juice',
                'Apple Juice',
                'Pineapple Juice',
                'Salem Guava',
                'Mixed Fruit',
                'Lemon Squash',
              ].map((p) {
                final isSelected = _selectedProducts.contains(p);
                return FilterChip(
                  label: Text(p),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedProducts.add(p);
                      } else {
                        _selectedProducts.remove(p);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          // Step 4: Inventory Setup
          Step(
            title: const Text('Inventory & Packaging'),
            subtitle: const Text('Configure default packaging standards'),
            isActive: _currentStep >= 3,
            content: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• 200ml / 500ml / 1000ml PET Bottles enabled',
                      style: TextStyle(fontSize: 12)),
                  SizedBox(height: 4),
                  Text('• Automatic Low Stock Reorder Threshold: 80 units',
                      style: TextStyle(fontSize: 12)),
                  SizedBox(height: 4),
                  Text('• Cold Storage Room A & Room B active',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
          // Step 5: Language Selection
          Step(
            title: const Text('Language (மொழி)'),
            subtitle: const Text('English or தமிழ்'),
            isActive: _currentStep >= 4,
            content: Row(
              children: [
                ChoiceChip(
                  label: const Text('English'),
                  selected: appState.locale.languageCode == 'en',
                  onSelected: (_) => appState.setLocale(const Locale('en')),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('தமிழ் (Tamil)'),
                  selected: appState.locale.languageCode == 'ta',
                  onSelected: (_) => appState.setLocale(const Locale('ta')),
                ),
              ],
            ),
          ),
          // Step 6: Theme Selection
          Step(
            title: const Text('Theme Mode'),
            subtitle: const Text('Light or Dark Mode'),
            isActive: _currentStep >= 5,
            content: Row(
              children: [
                ChoiceChip(
                  label: const Text('Light Mode'),
                  selected: appState.themeMode == ThemeMode.light,
                  onSelected: (_) => appState.setThemeMode(ThemeMode.light),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Dark Mode'),
                  selected: appState.themeMode == ThemeMode.dark,
                  onSelected: (_) => appState.setThemeMode(ThemeMode.dark),
                ),
              ],
            ),
          ),
          // Step 7: Ready
          Step(
            title: const Text('Ready to Start'),
            subtitle: const Text('Launch factory dashboard with live sample data'),
            isActive: _currentStep >= 6,
            content: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'All factory parameters configured! Tap below to open JuiceFlow.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
