import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/factory_data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/qr_code_dialog.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_badge.dart';
import 'quality_check_screen.dart';

class BatchDetailScreen extends StatelessWidget {
  final String batchId;

  const BatchDetailScreen({super.key, required this.batchId});

  void _showUpdateActualDialog(BuildContext context, dynamic batch) {
    final actualCtrl = TextEditingController(
        text: batch.actualQty > 0 ? '${batch.actualQty}' : '${batch.plannedQty}');
    final wastageCtrl =
        TextEditingController(text: batch.wastageQty > 0 ? '${batch.wastageQty}' : '12');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Record Production Output'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: actualCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Actual Produced (Liters)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: wastageCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Wastage / Loss (Liters)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final actual = double.tryParse(actualCtrl.text) ?? batch.plannedQty;
              final waste = double.tryParse(wastageCtrl.text) ?? 0.0;
              final provider = Provider.of<FactoryDataProvider>(context, listen: false);
              final appState = Provider.of<AppStateProvider>(context, listen: false);

              provider.updateBatchStatus(
                batch.id,
                AppConstants.batchStatusQualityCheck,
                actualQty: actual,
                wastageQty: waste,
                userName: appState.currentUserName,
                role: appState.currentRole,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Production output recorded! Ready for Quality Check.')),
              );
            },
            child: const Text('Save & Send to QC'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final provider = Provider.of<FactoryDataProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final batch = provider.batches.firstWhere(
      (b) => b.id == batchId,
      orElse: () => provider.batches.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(batch.batchNumber),
        actions: [
          IconButton(
            tooltip: 'Batch QR Code',
            icon: const Icon(Icons.qr_code, color: AppColors.primary),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => QrCodeDialog(
                  batch: batch,
                  factoryName: appState.factoryProfile.factoryName,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header Card
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          batch.productName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      StatBadge(label: batch.status, color: batch.statusColor),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Batch Code: ${batch.batchNumber}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _getProgressValue(batch.status),
                    backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                    color: batch.statusColor,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: ${Formatters.date(batch.productionDate)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text(
                        'Expiry: ${Formatters.date(batch.expiryDate)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Key Metrics Grid
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Planned Vol', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('${batch.plannedQty.toInt()} ${batch.unit}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Actual Output', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          batch.actualQty > 0 ? '${batch.actualQty.toInt()} ${batch.unit}' : '--',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Wastage Rate', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          '${batch.wastagePercent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: batch.wastagePercent > 3.0 ? AppColors.warning : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Production Traceability Card
            SectionHeader(title: 'Ingredients & Traceability'),
            CustomCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Recipe Ingredients Used',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    batch.ingredientsSummary.isNotEmpty
                        ? batch.ingredientsSummary
                        : 'No detailed ingredients logged.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Assigned Operator:', style: const TextStyle(fontSize: 12)),
                      Text(batch.assignedStaff,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (batch.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Notes: ', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Text(batch.notes,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quality Control Status Section
            SectionHeader(title: 'Quality Assurance (QA / QC)'),
            CustomCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (batch.qcStatus == 'Passed'
                              ? AppColors.success
                              : (batch.qcStatus == 'Failed' ? AppColors.error : AppColors.warning))
                          .withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.biotech,
                      color: batch.qcStatus == 'Passed'
                          ? AppColors.success
                          : (batch.qcStatus == 'Failed' ? AppColors.error : AppColors.warning),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QC Status: ${batch.qcStatus}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          batch.qcStatus == 'Passed'
                              ? 'Meets food safety standards (Brix & pH approved)'
                              : 'Pending lab testing and seal verification',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QualityCheckScreen(batch: batch),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('QC Test'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Workflow Step Triggers
            SectionHeader(title: 'Update Production Stage'),
            if (batch.status == AppConstants.batchStatusPlanned)
              ElevatedButton.icon(
                onPressed: () {
                  provider.updateBatchStatus(
                    batch.id,
                    AppConstants.batchStatusInProgress,
                    userName: appState.currentUserName,
                    role: appState.currentRole,
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('START PRODUCTION (BLENDING & HEATING)'),
              ),
            if (batch.status == AppConstants.batchStatusInProgress)
              ElevatedButton.icon(
                onPressed: () => _showUpdateActualDialog(context, batch),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                icon: const Icon(Icons.biotech_outlined),
                label: const Text('SEND BATCH TO QUALITY CONTROL'),
              ),
            if (batch.status == AppConstants.batchStatusQualityCheck)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        provider.updateBatchStatus(
                          batch.id,
                          AppConstants.batchStatusCompleted,
                          qcStatus: AppConstants.qcStatusPassed,
                          userName: appState.currentUserName,
                          role: appState.currentRole,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Batch completed and added to Finished Stock!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('APPROVE & COMPLETE'),
                    ),
                  ),
                ],
              ),
            if (batch.status == AppConstants.batchStatusCompleted)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Batch Completed • Added to Inventory Finished Goods',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _getProgressValue(String status) {
    switch (status) {
      case 'Planned':
        return 0.25;
      case 'In Progress':
        return 0.50;
      case 'Quality Check':
        return 0.75;
      case 'Completed':
        return 1.0;
      case 'Rejected':
      case 'Cancelled':
      default:
        return 0.0;
    }
  }
}
