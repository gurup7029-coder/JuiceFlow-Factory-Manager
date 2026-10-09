import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/raw_material.dart';
import '../../providers/factory_data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/stat_badge.dart';
import 'stock_adjustment_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = Provider.of<FactoryDataProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final rawFruitsAndIngredients = provider.rawMaterials
        .where((m) =>
            m.category == 'Fruits' ||
            m.category == 'Sweeteners & Sugar' ||
            m.category == 'Preservatives & Citric' ||
            m.category == 'Water & Minerals')
        .toList();

    final packagingMaterials = provider.rawMaterials
        .where((m) =>
            m.category == 'Bottles (PET / Glass)' ||
            m.category == 'Caps & Seals' ||
            m.category == 'Labels & Stickers' ||
            m.category == 'Carton Boxes')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('inventory')),
        actions: [
          IconButton(
            tooltip: loc.translate('addStock'),
            icon: const Icon(Icons.add_box_outlined, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StockAdjustmentScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(text: loc.translate('rawMaterials')),
            Tab(text: loc.translate('packagingMaterials')),
            Tab(text: loc.translate('finishedGoods')),
            Tab(text: 'Movement Log'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Raw Materials (Fruits & Ingredients)
          _buildMaterialsList(rawFruitsAndIngredients, isDark),

          // 2. Packaging Materials
          _buildMaterialsList(packagingMaterials, isDark),

          // 3. Finished Goods
          _buildFinishedGoodsList(provider, isDark),

          // 4. Stock Movement Log
          _buildMovementLog(provider, isDark),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_inventory',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StockAdjustmentScreen()),
          );
        },
        icon: const Icon(Icons.sync_alt),
        label: Text(loc.translate('addStock')),
      ),
    );
  }

  Widget _buildMaterialsList(List<RawMaterial> list, bool isDark) {
    if (list.isEmpty) {
      return const Center(child: Text('No materials in this category.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final isLow = item.isLowStock;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CustomCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (isLow ? AppColors.error : AppColors.primary).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.category == 'Fruits'
                        ? Icons.eco
                        : (item.category.contains('Bottle') ? Icons.local_drink : Icons.inventory_2),
                    color: isLow ? AppColors.error : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.supplierName} • ${item.storageLocation}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Batch: ${item.batchNumber} • Exp: ${Formatters.date(item.expiryDate)}',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.quantity.toInt()} ${item.unit}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isLow ? AppColors.error : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      ),
                    ),
                    const SizedBox(height: 4),
                    StatBadge(
                      label: isLow ? 'Low Stock' : 'Healthy',
                      color: isLow ? AppColors.error : AppColors.success,
                      fontSize: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinishedGoodsList(FactoryDataProvider provider, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        final p = provider.products[index];
        final isLow = p.currentStock <= p.minStockLevel;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CustomCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.takeout_dining, color: AppColors.secondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p.code} • Rate: ₹${p.sellingPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Min Buffer: ${p.minStockLevel} units',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${p.currentStock} units',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isLow ? AppColors.error : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StatBadge(
                      label: isLow ? 'Reorder Alert' : 'Available',
                      color: isLow ? AppColors.error : AppColors.success,
                      fontSize: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMovementLog(FactoryDataProvider provider, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: provider.movements.isNotEmpty ? provider.movements.length : 1,
      itemBuilder: (context, index) {
        if (provider.movements.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('No stock adjustments recorded yet.'),
            ),
          );
        }
        final m = provider.movements[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CustomCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  m.isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                  color: m.isPositive ? AppColors.success : AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.itemName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${m.movementType} • ${m.performedBy}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      if (m.notes.isNotEmpty)
                        Text(m.notes, style: const TextStyle(fontSize: 10.5)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${m.isPositive ? '+' : '-'}${m.quantity} ${m.unit}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: m.isPositive ? AppColors.success : AppColors.error,
                      ),
                    ),
                    Text(Formatters.date(m.date), style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
