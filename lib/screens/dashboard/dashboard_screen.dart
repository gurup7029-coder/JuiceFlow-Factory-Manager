import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/factory_data_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_stat_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_badge.dart';
import '../production/new_batch_screen.dart';
import '../production/batch_detail_screen.dart';
import '../orders/create_order_screen.dart';
import '../iot/iot_telemetry_screen.dart';
import '../analytics/ai_forecasting_screen.dart';
import '../tools/brix_calculator_screen.dart';
import '../tools/qr_scanner_screen.dart';
import '../tools/label_designer_screen.dart';
import '../recipes/recipe_formulation_screen.dart';
import '../staff/shift_attendance_screen.dart';
import '../dispatch/fleet_dispatch_screen.dart';
import '../customers/credit_ledger_screen.dart';
import '../../widgets/juice_flowing_3d_tumbler.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final appState = Provider.of<AppStateProvider>(context);
    final provider = Provider.of<FactoryDataProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appState.factoryProfile.factoryName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${loc.translate("role${_getRoleKey(appState.currentRole)}")} • ${appState.currentUserName}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: loc.translate('scanQr'),
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrScannerScreen()),
              );
            },
          ),
          IconButton(
            tooltip: loc.translate('language'),
            icon: const Icon(Icons.language),
            onPressed: () => appState.toggleLanguage(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadAllData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Factory Live Telemetry Glass Banner
              GlassCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.neonLime.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt_rounded, color: AppTheme.neonLime, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'FACTORY STATUS: OPTIMAL',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                  color: AppTheme.neonLime,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('HTST 72°C OK', style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Line A Capping at 120 bpm • Cold Storage: 3.8°C • Zero CIP downtime',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // KPI Row 1: Today's Production & Today's Sales
              Row(
                children: [
                  Expanded(
                    child: GlassStatCard(
                      title: loc.translate('todayProduction'),
                      value: '${provider.todayProductionLiters.toStringAsFixed(0)} L',
                      subtitle: '${provider.activeBatchesCount} batches active',
                      icon: Icons.precision_manufacturing_rounded,
                      accentColor: AppTheme.neonMango,
                      trendBadge: '+12.4%',
                      isPositiveTrend: true,
                      onTap: () => onNavigateTab?.call(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassStatCard(
                      title: loc.translate('todaySales'),
                      value: Formatters.compactCurrency(provider.todaySalesAmount),
                      subtitle: '${provider.pendingOrdersCount} orders pending',
                      icon: Icons.point_of_sale_rounded,
                      accentColor: AppTheme.neonOrange,
                      trendBadge: '+8.6%',
                      isPositiveTrend: true,
                      onTap: () => onNavigateTab?.call(3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // KPI Row 2: Efficiency & Wastage Rate
              Row(
                children: [
                  Expanded(
                    child: GlassStatCard(
                      title: loc.translate('productionEfficiency'),
                      value: Formatters.percentage(provider.averageProductionEfficiency),
                      subtitle: 'Output vs Planned',
                      icon: Icons.speed_rounded,
                      accentColor: AppTheme.neonLime,
                      trendBadge: 'Target 95%',
                      isPositiveTrend: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassStatCard(
                      title: loc.translate('wastageRate'),
                      value: Formatters.percentage(provider.averageWastageRate),
                      subtitle: 'Target: < 3.0%',
                      icon: Icons.recycling_rounded,
                      accentColor: provider.averageWastageRate > 3.0 ? Colors.redAccent : AppTheme.neonCyan,
                      trendBadge: provider.averageWastageRate > 3.0 ? 'High' : 'Optimal',
                      isPositiveTrend: provider.averageWastageRate <= 3.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // KPI Row 3: Pending Balance & Low Stock Alerts
              Row(
                children: [
                  Expanded(
                    child: GlassStatCard(
                      title: loc.translate('pendingPayments'),
                      value: Formatters.compactCurrency(provider.pendingPaymentsTotal),
                      subtitle: 'Receivables Outstanding',
                      icon: Icons.account_balance_wallet_rounded,
                      accentColor: AppTheme.neonPurple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreditLedgerScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassStatCard(
                      title: loc.translate('lowStockItems'),
                      value: '${provider.lowStockCount}',
                      subtitle: 'Stock replenishments',
                      icon: Icons.warning_amber_rounded,
                      accentColor: provider.lowStockCount > 0 ? Colors.redAccent : Colors.tealAccent,
                      onTap: () => onNavigateTab?.call(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Actions Bar with New Modules Included!
              SectionHeader(title: loc.translate('quickActions')),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _glassActionPill(
                      context,
                      label: 'Formulation BOM',
                      icon: Icons.blender_rounded,
                      color: AppTheme.neonMango,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RecipeFormulationScreen()),
                        );
                      },
                    ),
                    _glassActionPill(
                      context,
                      label: 'Label Designer',
                      icon: Icons.label_important_rounded,
                      color: AppTheme.neonOrange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LabelDesignerScreen()),
                        );
                      },
                    ),
                    _glassActionPill(
                      context,
                      label: 'Shift Roster',
                      icon: Icons.badge_rounded,
                      color: AppTheme.neonLime,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ShiftAttendanceScreen()),
                        );
                      },
                    ),
                    _glassActionPill(
                      context,
                      label: 'Fleet Dispatch',
                      icon: Icons.local_shipping_rounded,
                      color: AppTheme.neonCyan,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FleetDispatchScreen()),
                        );
                      },
                    ),
                    _glassActionPill(
                      context,
                      label: 'Credit Ledger',
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppTheme.neonPurple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreditLedgerScreen()),
                        );
                      },
                    ),
                    _glassActionPill(
                      context,
                      label: loc.translate('createBatch'),
                      icon: Icons.add_circle_outline,
                      color: AppTheme.primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NewBatchScreen()),
                        );
                      },
                    ),
                    _glassActionPill(
                      context,
                      label: loc.translate('newOrder'),
                      icon: Icons.shopping_cart_checkout,
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
                        );
                      },
                    ),
                    _glassActionPill(
                      context,
                      label: 'IoT Sensors',
                      icon: Icons.sensors_rounded,
                      color: Colors.cyan.shade700,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const IotTelemetryScreen()),
                        );
                      },
                    ),
                    _glassActionPill(
                      context,
                      label: 'AI Demand',
                      icon: Icons.auto_awesome_rounded,
                      color: Colors.indigo.shade600,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AiForecastingScreen()),
                        );
                      },
                    ),
                    _glassActionPill(
                      context,
                      label: '3D Tumbler',
                      icon: Icons.view_in_ar_rounded,
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Scaffold(
                              appBar: AppBar(title: const Text('3D Juice Flow Tumbler')),
                              body: const JuiceFlowing3dTumbler(autoAdvance: false),
                            ),
                          ),
                        );
                      },
                    ),
                    _glassActionPill(
                      context,
                      label: 'Brix Lab',
                      icon: Icons.science_rounded,
                      color: Colors.amber.shade900,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BrixCalculatorScreen()),
                        );
                      },
                    ),
                    _glassActionPill(
                      context,
                      label: 'Laser Scanner',
                      icon: Icons.qr_code_scanner_rounded,
                      color: const Color(0xFF10B981),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Production Chart with Glass Card
              SectionHeader(
                title: loc.translate('weeklyProductionTrend'),
                subtitle: '7-Day Liters Output',
              ),
              Builder(
                builder: (context) {
                  final todayLiters = provider.todayProductionLiters > 0 ? provider.todayProductionLiters : 620.0;
                  final List<double> weeklyProduction = [480.0, 560.0, 620.0, 390.0, 540.0, 710.0, todayLiters];

                  double maxVal = weeklyProduction.reduce((a, b) => a > b ? a : b);
                  if (maxVal < 600) maxVal = 600;
                  final double chartMaxY = ((maxVal * 1.25) / 100).ceil() * 100.0;
                  final double yInterval = (chartMaxY / 4).clamp(100.0, 1000.0);

                  final now = DateTime.now();
                  const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  final dayNames = List.generate(7, (i) {
                    if (i == 6) return 'Today';
                    final d = now.subtract(Duration(days: 6 - i));
                    return weekDays[d.weekday - 1];
                  });

                  return GlassCard(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 190,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: chartMaxY,
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (_) => isDark ? const Color(0xFF1E293B) : Colors.white,
                                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    final day = (group.x >= 0 && group.x < dayNames.length) ? dayNames[group.x] : '';
                                    return BarTooltipItem(
                                      '$day\n',
                                      TextStyle(
                                        color: isDark ? Colors.white70 : Colors.black87,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '${rod.toY.toInt()} Liters',
                                          style: TextStyle(
                                            color: group.x == 6 ? AppTheme.neonMango : AppColors.primary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (val, meta) {
                                      final idx = val.toInt();
                                      if (idx >= 0 && idx < dayNames.length) {
                                        final isToday = idx == 6;
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            dayNames[idx],
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                              color: isToday
                                                  ? AppTheme.neonMango
                                                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 42,
                                    interval: yInterval,
                                    getTitlesWidget: (val, meta) {
                                      return Text(
                                        '${val.toInt()}L',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: yInterval,
                                getDrawingHorizontalLine: (val) => FlLine(
                                  color: isDark ? Colors.white10 : Colors.black12,
                                  strokeWidth: 0.8,
                                ),
                              ),
                              barGroups: List.generate(7, (i) {
                                return _barGroup(i, weeklyProduction[i], chartMaxY, isDark);
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.neonMango,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tap any bar to inspect daily batch output (Cold Chain Ready)',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Recent Batches Live List
              SectionHeader(
                title: loc.translate('activeBatches'),
                actionTitle: 'View All',
                onActionTap: () => onNavigateTab?.call(1),
              ),
              ...provider.batches.take(3).map((batch) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.all(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BatchDetailScreen(batchId: batch.id),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: batch.statusColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: batch.statusColor.withOpacity(0.4)),
                          ),
                          child: Icon(Icons.bubble_chart_rounded, color: batch.statusColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                batch.batchNumber,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                batch.productName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${batch.actualQty > 0 ? batch.actualQty : batch.plannedQty} ${batch.unit} • Operator: ${batch.assignedStaff}',
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
                            StatBadge(label: batch.status, color: batch.statusColor, fontSize: 10),
                            const SizedBox(height: 6),
                            StatBadge(
                              label: 'QC: ${batch.qcStatus}',
                              color: batch.qcStatus == 'Passed'
                                  ? AppColors.success
                                  : (batch.qcStatus == 'Failed' ? AppColors.error : AppColors.warning),
                              fontSize: 9,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  static String _getRoleKey(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return 'Admin';
      case AppConstants.roleManager:
        return 'Manager';
      case AppConstants.roleProduction:
        return 'Production';
      case AppConstants.roleInventory:
        return 'Inventory';
      case AppConstants.roleSales:
        return 'Sales';
      default:
        return 'Admin';
    }
  }

  Widget _glassActionPill(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131826).withOpacity(0.7) : Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, double maxY, bool isDark) {
    final isToday = x == 6;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            colors: isToday
                ? [AppTheme.neonOrange, AppTheme.neonMango]
                : [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxY,
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
          ),
        ),
      ],
    );
  }
}
