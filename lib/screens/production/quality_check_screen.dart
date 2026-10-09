import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../models/production_batch.dart';
import '../../models/quality_check.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/factory_data_provider.dart';

class QualityCheckScreen extends StatefulWidget {
  final ProductionBatch batch;

  const QualityCheckScreen({super.key, required this.batch});

  @override
  State<QualityCheckScreen> createState() => _QualityCheckScreenState();
}

class _QualityCheckScreenState extends State<QualityCheckScreen> {
  final _formKey = GlobalKey<FormState>();

  String _appearance = 'Clear & Pulpy, No Foreign Particles';
  final String _colour = 'Natural Vibrant Fruit Color';
  String _taste = 'Balanced Sweet & Acidic Profile';
  final String _smell = 'Natural Fresh Fruit Aroma';
  final _phCtrl = TextEditingController(text: '3.8');
  final _tempCtrl = TextEditingController(text: '4.5');
  final _brixCtrl = TextEditingController(text: '13.5');
  final String _pkgCondition = 'Clean, Undamaged PET Bottle';
  String _sealCondition = 'Hermetic Induction Seal Intact';
  final _remarksCtrl = TextEditingController(text: 'All microbiological & sensory tests conform to FSSAI guidelines.');
  final _inspectorCtrl = TextEditingController(text: 'Dr. Anitha (QA Technologist)');
  String _qcDecision = AppConstants.qcStatusPassed;

  void _submitQc() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<FactoryDataProvider>(context, listen: false);
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    final qc = QualityCheck(
      id: const Uuid().v4(),
      batchId: widget.batch.id,
      batchNumber: widget.batch.batchNumber,
      appearance: _appearance,
      colour: _colour,
      taste: _taste,
      smell: _smell,
      phValue: double.tryParse(_phCtrl.text) ?? 3.8,
      temperature: double.tryParse(_tempCtrl.text) ?? 4.0,
      brixSugar: double.tryParse(_brixCtrl.text) ?? 12.0,
      packagingCondition: _pkgCondition,
      sealCondition: _sealCondition,
      remarks: _remarksCtrl.text.trim(),
      inspectorName: _inspectorCtrl.text.trim(),
      checkDate: DateTime.now(),
      status: _qcDecision,
    );

    provider.submitQualityCheck(qc, appState.currentUserName, appState.currentRole);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Quality check recorded! Status: $_qcDecision')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('${loc.translate('qualityControl')} - ${widget.batch.batchNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Batch banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.biotech, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.batch.productName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            'Batch: ${widget.batch.batchNumber} • Output: ${widget.batch.actualQty > 0 ? widget.batch.actualQty : widget.batch.plannedQty} ${widget.batch.unit}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Lab Readings
              Text('Physicochemical Readings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  )),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'pH Level (3.2 - 4.2)',
                        prefixIcon: Icon(Icons.water_drop_outlined),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _brixCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Brix / Sugar (°Bx)',
                        prefixIcon: Icon(Icons.cookie_outlined),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _tempCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Temp (°C)',
                        prefixIcon: Icon(Icons.thermostat_outlined),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sensory Attributes
              Text('Sensory & Organoleptic Tests',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  )),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _appearance,
                decoration: const InputDecoration(labelText: 'Appearance & Clarity'),
                items: [
                  'Clear & Pulpy, No Foreign Particles',
                  'Cloudy / Natural Fruit Haze',
                  'Heavy Sedimentation (Needs Filtration)',
                  'Foreign Particles Detected',
                ].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (val) => setState(() => _appearance = val!),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _taste,
                decoration: const InputDecoration(labelText: 'Taste & Sweetness'),
                items: [
                  'Balanced Sweet & Acidic Profile',
                  'Excessive Sweetness',
                  'Overly Sour / High Acidity',
                  'Off-Flavor / Bitterness Detected',
                ].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (val) => setState(() => _taste = val!),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _sealCondition,
                decoration: const InputDecoration(labelText: 'Bottle Seal Integrity'),
                items: [
                  'Hermetic Induction Seal Intact',
                  'Cap Tightened to Torque Standard',
                  'Minor Cap Leakage Under Vacuum',
                  'Seal Defect / Air Exposure',
                ].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (val) => setState(() => _sealCondition = val!),
              ),
              const SizedBox(height: 16),

              // Inspector Name
              TextFormField(
                controller: _inspectorCtrl,
                decoration: const InputDecoration(
                  labelText: 'QC Inspector / Technologist *',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Remarks
              TextFormField(
                controller: _remarksCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Lab Inspection Remarks & Sign-off',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 16),

              // Final Decision Chips
              Text('QC Verification Decision *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  )),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Passed (Approved)')),
                      selected: _qcDecision == AppConstants.qcStatusPassed,
                      selectedColor: AppColors.primaryContainer,
                      onSelected: (_) => setState(() => _qcDecision = AppConstants.qcStatusPassed),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Needs Review')),
                      selected: _qcDecision == AppConstants.qcStatusNeedsReview,
                      selectedColor: Colors.amber.shade100,
                      onSelected: (_) => setState(() => _qcDecision = AppConstants.qcStatusNeedsReview),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Rejected')),
                      selected: _qcDecision == AppConstants.qcStatusFailed,
                      selectedColor: Colors.red.shade100,
                      onSelected: (_) => setState(() => _qcDecision = AppConstants.qcStatusFailed),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _submitQc,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _qcDecision == AppConstants.qcStatusPassed
                      ? AppColors.primary
                      : (_qcDecision == AppConstants.qcStatusFailed ? AppColors.error : AppColors.secondary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.verified_outlined),
                label: Text(
                  'SUBMIT QUALITY INSPECTION RECORD',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
