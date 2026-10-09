import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/factory_data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/stat_badge.dart';
import 'new_batch_screen.dart';
import 'batch_detail_screen.dart';

class ProductionListScreen extends StatefulWidget {
  const ProductionListScreen({super.key});

  @override
  State<ProductionListScreen> createState() => _ProductionListScreenState();
}

class _ProductionListScreenState extends State<ProductionListScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = Provider.of<FactoryDataProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredBatches = provider.batches.where((batch) {
      if (_selectedFilter != 'All' && batch.status != _selectedFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return batch.batchNumber.toLowerCase().contains(q) ||
            batch.productName.toLowerCase().contains(q) ||
            batch.assignedStaff.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('production')),
        actions: [
          IconButton(
            tooltip: loc.translate('createBatch'),
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewBatchScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search batch #, juice flavor, staff...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                isDense: true,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                'All',
                AppConstants.batchStatusInProgress,
                AppConstants.batchStatusQualityCheck,
                AppConstants.batchStatusPlanned,
                AppConstants.batchStatusCompleted,
                AppConstants.batchStatusRejected,
              ].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(filter, style: const TextStyle(fontSize: 12)),
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                    selectedColor: AppColors.primaryContainer,
                    checkmarkColor: AppColors.primary,
                  ),
                );
              }).toList(),
            ),
          ),
          // List
          Expanded(
            child: filteredBatches.isEmpty
                ? EmptyStateView(
                    icon: Icons.precision_manufacturing_outlined,
                    title: 'No Production Batches',
                    description: 'Start a new juice manufacturing batch to begin production tracking.',
                    buttonText: loc.translate('createBatch'),
                    onButtonPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NewBatchScreen()),
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: filteredBatches.length,
                    itemBuilder: (context, index) {
                      final batch = filteredBatches[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CustomCard(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BatchDetailScreen(batchId: batch.id),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: batch.statusColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.water_drop, color: batch.statusColor, size: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        batch.batchNumber,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  StatBadge(
                                    label: batch.status,
                                    color: batch.statusColor,
                                    fontSize: 11,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                batch.productName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Operator: ${batch.assignedStaff} • Date: ${Formatters.date(batch.productionDate)}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _statColumn('Planned', '${batch.plannedQty.toInt()} ${batch.unit}'),
                                    _statColumn(
                                        'Actual Output',
                                        batch.actualQty > 0
                                            ? '${batch.actualQty.toInt()} ${batch.unit}'
                                            : 'Running...'),
                                    _statColumn(
                                      'Wastage',
                                      batch.wastageQty > 0
                                          ? '${batch.wastageQty} L (${batch.wastagePercent.toStringAsFixed(1)}%)'
                                          : '0%',
                                    ),
                                    _statColumn(
                                      'QC Status',
                                      batch.qcStatus,
                                      color: batch.qcStatus == 'Passed'
                                          ? AppColors.success
                                          : (batch.qcStatus == 'Failed' ? AppColors.error : AppColors.warning),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_production',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewBatchScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(loc.translate('createBatch')),
      ),
    );
  }

  Widget _statColumn(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
