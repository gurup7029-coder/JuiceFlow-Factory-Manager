import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/glass_card.dart';
import '../production/new_batch_screen.dart';

class RecipeFormulationScreen extends StatefulWidget {
  const RecipeFormulationScreen({super.key});

  @override
  State<RecipeFormulationScreen> createState() => _RecipeFormulationScreenState();
}

class _RecipeFormulationScreenState extends State<RecipeFormulationScreen> {
  String _selectedRecipe = 'Alphonso Mango Nectar 14°Bx';

  double _pulpPercentage = 42.0;
  double _waterPercentage = 46.5;
  double _sugarPercentage = 11.0;
  double _acidPercentage = 0.5;

  double _batchSizeLiters = 2500.0;
  final double _pulpCostPerKg = 48.0;
  final double _sugarCostPerKg = 42.0;

  final List<Map<String, dynamic>> _presets = [
    {
      'name': 'Alphonso Mango Nectar 14°Bx',
      'pulp': 42.0,
      'water': 46.5,
      'sugar': 11.0,
      'acid': 0.5,
      'targetBrix': 14.2,
      'color': Color(0xFFD97706),
    },
    {
      'name': 'Nagpur Orange Fresh 11.5°Bx',
      'pulp': 60.0,
      'water': 32.5,
      'sugar': 7.0,
      'acid': 0.5,
      'targetBrix': 11.6,
      'color': Color(0xFFEA580C),
    },
    {
      'name': 'Shimla Apple Clear 12°Bx',
      'pulp': 50.0,
      'water': 41.5,
      'sugar': 8.0,
      'acid': 0.5,
      'targetBrix': 12.0,
      'color': Color(0xFFDC2626),
    },
    {
      'name': 'Tropical Mixed Fruit 13.5°Bx',
      'pulp': 45.0,
      'water': 44.5,
      'sugar': 10.0,
      'acid': 0.5,
      'targetBrix': 13.5,
      'color': Color(0xFF8B5CF6),
    },
  ];

  void _applyPreset(Map<String, dynamic> p) {
    setState(() {
      _selectedRecipe = p['name'] as String;
      _pulpPercentage = p['pulp'] as double;
      _waterPercentage = p['water'] as double;
      _sugarPercentage = p['sugar'] as double;
      _acidPercentage = p['acid'] as double;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mass calculations (density ~ 1.05 kg/L for fruit nectar)
    final totalMassKg = _batchSizeLiters * 1.05;
    final pulpRequiredKg = (totalMassKg * (_pulpPercentage / 100));
    final sugarRequiredKg = (totalMassKg * (_sugarPercentage / 100));
    final waterRequiredLiters = (_batchSizeLiters * (_waterPercentage / 100));
    final acidRequiredKg = (totalMassKg * (_acidPercentage / 100));

    // Batch costing
    final pulpTotalCost = pulpRequiredKg * _pulpCostPerKg;
    final sugarTotalCost = sugarRequiredKg * _sugarCostPerKg;
    final otherCost = acidRequiredKg * 120.0 + (_batchSizeLiters * 1.8); // Water/electricity
    final totalIngredientCost = pulpTotalCost + sugarTotalCost + otherCost;

    final bottles500ml = (_batchSizeLiters / 0.5).round();
    final costPerBottle = bottles500ml > 0 ? (totalIngredientCost / bottles500ml) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe & Formulation Builder'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD97706), Color(0xFFB45309)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD97706).withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.blender_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Standard Juice Formulations',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Batch volume scaling & real-time BOM (Bill of Materials) ingredient cost calculator.',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Recipe Presets Horizontal List
          const Text(
            'Master Product Recipes',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _presets.map((preset) {
                final isSelected = preset['name'] == _selectedRecipe;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(preset['name'] as String),
                    selected: isSelected,
                    selectedColor: AppColors.secondary.withOpacity(0.2),
                    side: BorderSide(
                      color: isSelected ? AppColors.secondary : Colors.grey.withOpacity(0.3),
                    ),
                    onSelected: (_) => _applyPreset(preset),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // Formulation Sliders in GlassCard
          GlassCard(
            neonGlowColor: AppColors.secondary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Target Batch Volume',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_batchSizeLiters.toInt()} Liters ($bottles500ml Bottles)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _batchSizeLiters,
                  min: 500,
                  max: 10000,
                  divisions: 19,
                  activeColor: AppColors.secondary,
                  onChanged: (v) => setState(() => _batchSizeLiters = v),
                ),
                const Divider(height: 20),

                // Component Percentages
                _percentageSlider(
                  title: 'Fruit Puree / Pulp',
                  percent: _pulpPercentage,
                  color: const Color(0xFFD97706),
                  onChanged: (v) => setState(() => _pulpPercentage = v),
                ),
                _percentageSlider(
                  title: 'RO Treated Water',
                  percent: _waterPercentage,
                  color: const Color(0xFF0284C7),
                  onChanged: (v) => setState(() => _waterPercentage = v),
                ),
                _percentageSlider(
                  title: 'Sugar Syrup Solids',
                  percent: _sugarPercentage,
                  color: const Color(0xFFEA580C),
                  onChanged: (v) => setState(() => _sugarPercentage = v),
                ),
                _percentageSlider(
                  title: 'Citric Acid & Pectin',
                  percent: _acidPercentage,
                  color: const Color(0xFF16A34A),
                  onChanged: (v) => setState(() => _acidPercentage = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Bill of Materials (BOM) Requirements Output
          const Text(
            'Batch Requirements & Bill of Materials (BOM)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _bomPill(
                  label: 'Fruit Pulp Required',
                  value: '${pulpRequiredKg.toStringAsFixed(0)} kg',
                  sub: 'Cost: ${Formatters.currency(pulpTotalCost)}',
                  icon: Icons.eco_rounded,
                  color: const Color(0xFFD97706),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _bomPill(
                  label: 'Sugar Solids',
                  value: '${sugarRequiredKg.toStringAsFixed(0)} kg',
                  sub: 'Cost: ${Formatters.currency(sugarTotalCost)}',
                  icon: Icons.grain_rounded,
                  color: const Color(0xFFEA580C),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _bomPill(
                  label: 'RO Pure Water',
                  value: '${waterRequiredLiters.toStringAsFixed(0)} L',
                  sub: 'UV Filtered',
                  icon: Icons.water_drop_rounded,
                  color: const Color(0xFF0284C7),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _bomPill(
                  label: 'Unit Cost / 500ml',
                  value: Formatters.currency(costPerBottle),
                  sub: 'Excl. packaging',
                  icon: Icons.monetization_on_rounded,
                  color: const Color(0xFF16A34A),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Direct Batch Launch Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewBatchScreen()),
              );
            },
            icon: const Icon(Icons.rocket_launch_rounded),
            label: Text(
              'Deploy to Batch Production (${_batchSizeLiters.toInt()} L)',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _percentageSlider({
    required String title,
    required double percent,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(
              '${percent.toStringAsFixed(1)} %',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        Slider(
          value: percent.clamp(0.0, 100.0),
          min: 0.0,
          max: 100.0,
          activeColor: color,
          inactiveColor: color.withOpacity(0.15),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _bomPill({
    required String label,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
