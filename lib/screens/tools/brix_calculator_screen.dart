import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_card.dart';

class BrixCalculatorScreen extends StatefulWidget {
  const BrixCalculatorScreen({super.key});

  @override
  State<BrixCalculatorScreen> createState() => _BrixCalculatorScreenState();
}

class _BrixCalculatorScreenState extends State<BrixCalculatorScreen> {
  final TextEditingController _rawBrixController = TextEditingController(text: '15.2');
  final TextEditingController _tempController = TextEditingController(text: '28.5');
  final TextEditingController _batchVolumeController = TextEditingController(text: '1000');
  final TextEditingController _targetBrixController = TextEditingController(text: '14.0');

  double _correctedBrix = 15.75;
  double _specificGravity = 1.064;
  double _sugarGramsPerLiter = 167.5;
  double _waterNeededLiters = 125.0;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    final rawBrix = double.tryParse(_rawBrixController.text) ?? 15.0;
    final temp = double.tryParse(_tempController.text) ?? 20.0;
    final batchVolume = double.tryParse(_batchVolumeController.text) ?? 1000.0;
    final targetBrix = double.tryParse(_targetBrixController.text) ?? 14.0;

    // ICUMSA temperature correction formula (standard reference 20°C):
    // delta = 0.0006 * brix * (T - 20) + 0.055 * (T - 20)
    final delta = (0.0006 * rawBrix * (temp - 20.0)) + (0.055 * (temp - 20.0));
    final corrected = (rawBrix + delta).clamp(0.0, 75.0);

    // Specific gravity approx from Brix: SG = 1 + (Brix / (258.6 - (Brix / 258.2) * 227.1))
    final sg = 1.0 + (corrected / (258.6 - (corrected / 258.2) * 227.1));
    final sugarGpl = corrected * sg * 10;

    // Pearson Square / Dilution: V_water = V_batch * ((Brix_current - Brix_target) / Brix_target)
    double waterNeeded = 0.0;
    if (corrected > targetBrix && targetBrix > 0) {
      waterNeeded = batchVolume * ((corrected - targetBrix) / targetBrix);
    }

    setState(() {
      _correctedBrix = corrected;
      _specificGravity = sg;
      _sugarGramsPerLiter = sugarGpl;
      _waterNeededLiters = waterNeeded;
    });
  }

  void _applyPreset(String name, double brix, double target) {
    _rawBrixController.text = brix.toString();
    _targetBrixController.text = target.toString();
    _recalculate();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brix Refractometer & Lab Calculator'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD97706), Color(0xFFB45309)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.science_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ICUMSA °Bx Calibration Engine',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Corrects optical readings to 20°C reference standard & calculates batch water dilution.',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Fruit Presets
          const Text('Standard Fruit Presets',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _presetChip('Mango Nectar', 16.0, 14.5),
                _presetChip('Fresh Orange', 12.0, 11.2),
                _presetChip('Apple Crisp', 12.5, 11.5),
                _presetChip('Pineapple Zing', 13.5, 12.0),
                _presetChip('Lemon Ade', 8.5, 7.5),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Input Form Card
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Refractometer Measurements',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _rawBrixController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Raw Reading (°Bx)',
                          suffixText: '°Bx',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _recalculate(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _tempController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Juice Temp (°C)',
                          suffixText: '°C',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _recalculate(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _batchVolumeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Batch Volume (L)',
                          suffixText: 'L',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _recalculate(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _targetBrixController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Target Recipe (°Bx)',
                          suffixText: '°Bx',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _recalculate(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Results Output Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Temperature-Corrected Brix (20°C):',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_correctedBrix.toStringAsFixed(2)} °Bx',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _specOutput(
                        label: 'Specific Gravity',
                        value: _specificGravity.toStringAsFixed(4),
                        icon: Icons.compress_rounded,
                      ),
                    ),
                    Expanded(
                      child: _specOutput(
                        label: 'Sugar Concentration',
                        value: '${_sugarGramsPerLiter.toStringAsFixed(1)} g/L',
                        icon: Icons.grain_rounded,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF0284C7).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.water_drop_rounded, color: Color(0xFF0284C7), size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'RO Water Dilution Required:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _waterNeededLiters > 0
                                  ? 'Add ${_waterNeededLiters.toStringAsFixed(1)} Liters to reach ${_targetBrixController.text}°Bx'
                                  : 'Optimal Brix level reached (No dilution needed)',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetChip(String label, double raw, double target) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.secondary.withOpacity(0.1),
        side: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
        onPressed: () => _applyPreset(label, raw, target),
      ),
    );
  }

  Widget _specOutput({required String label, required String value, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
