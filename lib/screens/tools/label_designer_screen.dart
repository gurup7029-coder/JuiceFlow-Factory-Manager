import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class LabelDesignerScreen extends StatefulWidget {
  const LabelDesignerScreen({super.key});

  @override
  State<LabelDesignerScreen> createState() => _LabelDesignerScreenState();
}

class _LabelDesignerScreenState extends State<LabelDesignerScreen> {
  String _selectedBeverage = 'Alphonso Mango Nectar';
  String _selectedVolume = '500 ml';
  String _labelType = 'front'; // front, back, carton
  String _batchNumber = 'JF-2026-M402';
  double _mrp = 75.0;
  String _fssaiLicense = '10022042000189';
  DateTime _mfgDate = DateTime.now();
  int _shelfLifeDays = 45;

  final List<Map<String, dynamic>> _beverages = [
    {
      'name': 'Alphonso Mango Nectar',
      'color': AppTheme.neonMango,
      'ingredients': 'Mango Pulp (45%), RO Water, Cane Sugar (8%), Citric Acid, Vitamin C',
      'energy': '64 kcal',
      'carbs': '15.8 g',
      'vitC': '32 mg',
      'brix': '14.5° Bx',
    },
    {
      'name': 'Valencia Sweet Orange',
      'color': AppTheme.neonOrange,
      'ingredients': 'Cold-Pressed Orange Juice (85%), Fruit Cells (10%), RO Water, Vit C',
      'energy': '48 kcal',
      'carbs': '11.2 g',
      'vitC': '48 mg',
      'brix': '11.8° Bx',
    },
    {
      'name': 'Royal Pomegranate Punch',
      'color': const Color(0xFFE91E63),
      'ingredients': 'Fresh Pomegranate Aril Extract (70%), RO Water, Beetroot Juice, Citric Acid',
      'energy': '54 kcal',
      'carbs': '13.1 g',
      'vitC': '22 mg',
      'brix': '13.2° Bx',
    },
    {
      'name': 'Cold-Pressed Lime Mint',
      'color': AppTheme.neonLime,
      'ingredients': 'Lime Juice (20%), Fresh Mint Extract, RO Water, Organic Sugar (7%), Rock Salt',
      'energy': '36 kcal',
      'carbs': '8.5 g',
      'vitC': '38 mg',
      'brix': '8.2° Bx',
    },
  ];

  Map<String, dynamic> get _currentBeverage => _beverages.firstWhere(
        (b) => b['name'] == _selectedBeverage,
        orElse: () => _beverages[0],
      );

  DateTime get _expiryDate => _mfgDate.add(Duration(days: _shelfLifeDays));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bev = _currentBeverage;
    final bevColor = bev['color'] as Color;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Label & Barcode Designer'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Print Thermal / PDF Label',
            icon: const Icon(Icons.print_rounded),
            onPressed: _exportAndPrintLabel,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segmented Label Mode
            Row(
              children: [
                _buildTypeTab('front', 'Bottle Front', Icons.aspect_ratio_rounded),
                const SizedBox(width: 8),
                _buildTypeTab('back', 'Nutrition Facts', Icons.fact_check_rounded),
                const SizedBox(width: 8),
                _buildTypeTab('carton', 'Master Carton', Icons.inventory_2_rounded),
              ],
            ),
            const SizedBox(height: 16),

            // Live Visual Label Canvas Preview
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _buildInteractivePreviewCard(isDark, bev, bevColor),
              ),
            ),
            const SizedBox(height: 20),

            // Customization Controls
            Text(
              'Label Parameters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Product dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedBeverage,
                    decoration: const InputDecoration(
                      labelText: 'Select Beverage Formulation',
                      prefixIcon: Icon(Icons.local_drink_rounded),
                    ),
                    items: _beverages.map((b) {
                      return DropdownMenuItem<String>(
                        value: b['name'] as String,
                        child: Text(b['name'] as String),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedBeverage = val);
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // Volume & Price Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedVolume,
                          decoration: const InputDecoration(
                            labelText: 'Pack Volume',
                            prefixIcon: Icon(Icons.straighten_rounded),
                          ),
                          items: const [
                            DropdownMenuItem(value: '250 ml', child: Text('250 ml')),
                            DropdownMenuItem(value: '500 ml', child: Text('500 ml')),
                            DropdownMenuItem(value: '1000 ml', child: Text('1000 ml (1L)')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedVolume = val;
                                if (val == '250 ml') _mrp = 45.0;
                                if (val == '500 ml') _mrp = 75.0;
                                if (val == '1000 ml') _mrp = 140.0;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: _mrp.toStringAsFixed(0),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'MRP (₹)',
                            prefixIcon: Icon(Icons.currency_rupee_rounded),
                          ),
                          onChanged: (val) {
                            final parsed = double.tryParse(val);
                            if (parsed != null) setState(() => _mrp = parsed);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Batch & FSSAI
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _batchNumber,
                          decoration: const InputDecoration(
                            labelText: 'Batch Number',
                            prefixIcon: Icon(Icons.qr_code_2_rounded),
                          ),
                          onChanged: (val) => setState(() => _batchNumber = val),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: _shelfLifeDays.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Shelf Life (Days)',
                            prefixIcon: Icon(Icons.timelapse_rounded),
                          ),
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed != null) setState(() => _shelfLifeDays = parsed);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Date picker & FSSAI
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today_rounded, size: 16),
                          label: Text('Mfg: ${DateFormat('dd MMM yyyy').format(_mfgDate)}'),
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: _mfgDate,
                              firstDate: DateTime(2025),
                              lastDate: DateTime(2030),
                            );
                            if (d != null) setState(() => _mfgDate = d);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: _fssaiLicense,
                          decoration: const InputDecoration(
                            labelText: 'FSSAI Lic. No.',
                            prefixIcon: Icon(Icons.verified_user_rounded),
                          ),
                          onChanged: (val) => setState(() => _fssaiLicense = val),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Print / Export Actions
            ElevatedButton.icon(
              onPressed: _exportAndPrintLabel,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: bevColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.print_rounded, size: 22),
              label: const Text(
                'Generate & Print Label (Thermal / PDF)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTab(String type, String title, IconData icon) {
    final isSelected = _labelType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _labelType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.18)
                : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.12),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractivePreviewCard(bool isDark, Map<String, dynamic> bev, Color bevColor) {
    if (_labelType == 'back') {
      return _buildNutritionBackPreview(isDark, bev, bevColor);
    } else if (_labelType == 'carton') {
      return _buildCartonPreview(isDark, bev, bevColor);
    }
    return _buildFrontLabelPreview(isDark, bev, bevColor);
  }

  Widget _buildFrontLabelPreview(bool isDark, Map<String, dynamic> bev, Color bevColor) {
    return Container(
      key: const ValueKey('front_label'),
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131826),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: bevColor.withOpacity(0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: bevColor.withOpacity(0.25),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Brand Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.greenAccent),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.eco_rounded, color: Colors.greenAccent, size: 12),
                    SizedBox(width: 4),
                    Text(
                      '100% PURE',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'FSSAI Lic. $_fssaiLicense',
                style: const TextStyle(color: Colors.white70, fontSize: 8),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // JuiceFlow Logo Emblem
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [bevColor.withOpacity(0.4), Colors.transparent],
              ),
            ),
            child: Icon(Icons.local_drink_rounded, size: 42, color: bevColor),
          ),
          const SizedBox(height: 8),

          Text(
            'JUICEFLOW',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: bevColor,
            ),
          ),
          Text(
            bev['name'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cold-Pressed • No Added Preservatives • Flash Pasteurized',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 14),

          // Net Volume & MRP Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text('NET VOLUME', style: TextStyle(color: Colors.white54, fontSize: 8)),
                    Text(
                      _selectedVolume,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: bevColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: bevColor.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    const Text('MRP (INCL. TAXES)', style: TextStyle(color: Colors.white54, fontSize: 8)),
                    Text(
                      '₹${_mrp.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: bevColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Barcode & Batch Section
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BATCH: $_batchNumber', style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                    Text('MFG: ${DateFormat('dd/MM/yy').format(_mfgDate)}', style: const TextStyle(color: Colors.black87, fontSize: 8)),
                    Text('EXP: ${DateFormat('dd/MM/yy').format(_expiryDate)}', style: const TextStyle(color: Colors.black87, fontSize: 8)),
                  ],
                ),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: QrImageView(
                    data: 'JUICEFLOW:$_batchNumber:${bev['name']}',
                    size: 44,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionBackPreview(bool isDark, Map<String, dynamic> bev, Color bevColor) {
    return Container(
      key: const ValueKey('back_label'),
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'NUTRITION INFORMATION',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
            ),
          ),
          const Center(
            child: Text(
              'Approximate Values Per 100ml Serving',
              style: TextStyle(color: Colors.white60, fontSize: 9),
            ),
          ),
          const Divider(color: Colors.white24, height: 16),
          _buildNutriRow('Energy', bev['energy'] as String),
          _buildNutriRow('Carbohydrates', bev['carbs'] as String),
          _buildNutriRow('Added Sugar', '0.0 g (No added refined syrup)'),
          _buildNutriRow('Vitamin C', bev['vitC'] as String),
          _buildNutriRow('Refractometer Brix', bev['brix'] as String),
          const Divider(color: Colors.white24, height: 16),
          const Text(
            'INGREDIENTS:',
            style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            bev['ingredients'] as String,
            style: const TextStyle(color: Colors.white54, fontSize: 9),
          ),
          const SizedBox(height: 10),
          const Text(
            'STORAGE INSTRUCTIONS:',
            style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Keep refrigerated below 4°C. Consume within 48 hours once opened.',
            style: TextStyle(color: Colors.white54, fontSize: 8),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Manufactured by JuiceFlow Factory Ltd • Coimbatore, TN\nCustomer Care: support@juiceflow.com',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartonPreview(bool isDark, Map<String, dynamic> bev, Color bevColor) {
    return Container(
      key: const ValueKey('carton_label'),
      width: 320,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFD4A373).withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4A373), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.inventory_2_rounded, color: Color(0xFFD4A373), size: 20),
                  SizedBox(width: 6),
                  Text(
                    'SHIPPING CARTON',
                    style: TextStyle(color: Color(0xFFD4A373), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('BOX OF 24', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 16),
          Text(
            bev['name'] as String,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text('Quantity: 24 Bottles × $_selectedVolume', style: const TextStyle(color: Colors.white70, fontSize: 11)),
          Text('Batch: $_batchNumber', style: const TextStyle(color: Colors.white70, fontSize: 11)),
          Text('Mfg: ${DateFormat('dd MMM yyyy').format(_mfgDate)} | Exp: ${DateFormat('dd MMM yyyy').format(_expiryDate)}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('MASTER BARCODE:', style: TextStyle(color: Colors.black54, fontSize: 8)),
                      const Text('||||| | |||| ||| ||||||| |||', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
                      Text('8901234${_batchNumber.replaceAll(RegExp(r'[^0-9]'), '')}', style: const TextStyle(fontSize: 8, color: Colors.black)),
                    ],
                  ),
                ),
                QrImageView(
                  data: 'CARTON:24X$_selectedVolume:$_batchNumber',
                  size: 40,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutriRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
        ],
      ),
    );
  }

  Future<void> _exportAndPrintLabel() async {
    final pdf = pw.Document();
    final bev = _currentBeverage;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('JUICEFLOW FACTORY', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text(bev['name'] as String, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Net Vol: $_selectedVolume', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('MRP: INR ${_mrp.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Batch: $_batchNumber', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('FSSAI: $_fssaiLicense', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Mfg: ${DateFormat('dd/MM/yyyy').format(_mfgDate)}', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('Exp: ${DateFormat('dd/MM/yyyy').format(_expiryDate)}', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text('Ingredients: ${bev['ingredients']}', style: const pw.TextStyle(fontSize: 8)),
                pw.Spacer(),
                pw.BarcodeWidget(
                  data: 'JF-$_batchNumber-$_selectedVolume',
                  barcode: pw.Barcode.code128(),
                  height: 36,
                  width: 160,
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Label_$_batchNumber.pdf',
    );
  }
}
