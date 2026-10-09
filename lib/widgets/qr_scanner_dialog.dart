import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../providers/factory_data_provider.dart';
import '../screens/tools/qr_scanner_screen.dart';

class QrScannerDialog extends StatefulWidget {
  const QrScannerDialog({super.key});

  @override
  State<QrScannerDialog> createState() => _QrScannerDialogState();
}

class _QrScannerDialogState extends State<QrScannerDialog> {
  final TextEditingController _batchInputController = TextEditingController();
  dynamic _foundBatch;
  bool _hasSearched = false;

  void _searchBatch(String query) {
    if (query.trim().isEmpty) return;
    final provider = Provider.of<FactoryDataProvider>(context, listen: false);
    final matches = provider.batches.where(
      (b) =>
          b.batchNumber.toLowerCase().contains(query.trim().toLowerCase()) ||
          b.id.toLowerCase() == query.trim().toLowerCase(),
    ).toList();

    setState(() {
      _foundBatch = matches.isNotEmpty ? matches.first : null;
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<FactoryDataProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Batch QR Scanner',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Scanner simulation frame
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryLight, width: 2.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const Positioned(
                    bottom: 12,
                    child: Text(
                      'Align QR code inside frame',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _batchInputController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Batch No (e.g. MNG-101)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      isDense: true,
                    ),
                    onSubmitted: _searchBatch,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _searchBatch(_batchInputController.text),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Lookup'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Quick Select Recent Batches:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: provider.batches.take(3).map((b) {
                return ActionChip(
                  label: Text(b.batchNumber, style: const TextStyle(fontSize: 11)),
                  onPressed: () {
                    _batchInputController.text = b.batchNumber;
                    _searchBatch(b.batchNumber);
                  },
                );
              }).toList(),
            ),
            if (_foundBatch != null && _hasSearched) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _foundBatch.batchNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      'Product: ${_foundBatch.productName}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Produced: ${_foundBatch.actualQty} ${_foundBatch.unit} • QC: ${_foundBatch.qcStatus}',
                      style: const TextStyle(fontSize: 11, color: AppColors.primaryDark),
                    ),
                    Text(
                      'Expiry: ${Formatters.date(_foundBatch.expiryDate)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ] else if (_foundBatch == null && _hasSearched) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Batch not found in local active registry. Try scanning via Laser Scanner.',
                        style: TextStyle(color: AppColors.error, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
              label: const Text('Open Fullscreen Laser Scanner', style: TextStyle(fontSize: 12)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
