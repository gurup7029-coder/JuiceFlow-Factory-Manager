import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/report_export_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/factory_data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/section_header.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final appState = Provider.of<AppStateProvider>(context);
    final provider = Provider.of<FactoryDataProvider>(context);

    final totalProduction =
        provider.batches.fold<double>(0, (sum, b) => sum + b.actualQty);
    final totalSales =
        provider.orders.fold<double>(0, (sum, o) => sum + o.grandTotal);
    final totalExpenses =
        provider.expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final netProfit = totalSales - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('reports')),
        actions: [
          IconButton(
            tooltip: 'Export Executive PDF Report',
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
            onPressed: () {
              ReportExportService.exportExecutivePdfReport(
                profile: appState.factoryProfile,
                batches: provider.batches,
                orders: provider.orders,
                expenses: provider.expenses,
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
            // Executive Summary Card
            CustomCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Factory Financial Health',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('THIS MONTH',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onPrimaryContainer)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Revenue', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(Formatters.currency(totalSales),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Expenses', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(Formatters.currency(totalExpenses),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Net Operating Margin',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(
                        Formatters.currency(netProfit),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: netProfit >= 0 ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Production & Operational Performance
            SectionHeader(title: 'Manufacturing Productivity'),
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.speed, color: AppColors.primary),
                        const SizedBox(height: 8),
                        Text(
                          Formatters.percentage(provider.averageProductionEfficiency),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        const Text('Average Efficiency', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.recycling, color: AppColors.secondary),
                        const SizedBox(height: 8),
                        Text(
                          Formatters.percentage(provider.averageWastageRate),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        const Text('Wastage Rate', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.water_drop, color: Colors.blue),
                        const SizedBox(height: 8),
                        Text(
                          '${totalProduction.toInt()} L',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        const Text('Volume Output', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Best Selling Products Card
            SectionHeader(title: 'Top Juice Varieties by Sales Volume'),
            CustomCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: provider.products.take(4).map((p) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                          ],
                        ),
                        Text('MRP ₹${p.sellingPrice.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Data Export Center
            SectionHeader(title: 'Export Data Reports (CSV & PDF)'),
            _exportActionTile(
              title: 'Executive PDF Performance Summary',
              subtitle: 'Formatted PDF with KPIs, production tables and order summaries',
              icon: Icons.picture_as_pdf,
              color: Colors.red.shade700,
              onTap: () {
                ReportExportService.exportExecutivePdfReport(
                  profile: appState.factoryProfile,
                  batches: provider.batches,
                  orders: provider.orders,
                  expenses: provider.expenses,
                );
              },
            ),
            const SizedBox(height: 8),
            _exportActionTile(
              title: 'Production Batches (CSV)',
              subtitle: 'Export complete production, recipe, staff & QC log to CSV',
              icon: Icons.table_chart_outlined,
              color: AppColors.primary,
              onTap: () => ReportExportService.exportBatchesCsv(provider.batches),
            ),
            const SizedBox(height: 8),
            _exportActionTile(
              title: 'Sales Orders & Invoices (CSV)',
              subtitle: 'Export customer orders, taxes, amounts & delivery statuses',
              icon: Icons.table_chart_outlined,
              color: AppColors.secondary,
              onTap: () => ReportExportService.exportOrdersCsv(provider.orders),
            ),
            const SizedBox(height: 8),
            _exportActionTile(
              title: 'Factory Expenses (CSV)',
              subtitle: 'Export category-wise factory operational expenses',
              icon: Icons.table_chart_outlined,
              color: Colors.purple,
              onTap: () => ReportExportService.exportExpensesCsv(provider.expenses),
            ),
            const SizedBox(height: 8),
            _exportActionTile(
              title: 'Raw Material Inventory (CSV)',
              subtitle: 'Export current raw stock, reorder levels and expiry dates',
              icon: Icons.table_chart_outlined,
              color: Colors.amber.shade800,
              onTap: () => ReportExportService.exportInventoryCsv(provider.rawMaterials),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _exportActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.download_rounded, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}
