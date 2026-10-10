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
import '../tools/label_designer_screen.dart';
import '../recipes/recipe_formulation_screen.dart';
import '../staff/shift_attendance_screen.dart';
import '../dispatch/fleet_dispatch_screen.dart';
import '../customers/credit_ledger_screen.dart';
import '../customer/customer_store_screen.dart';
import '../inventory/stock_adjustment_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

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

  void _showRoleSwitchSheet(BuildContext context, AppStateProvider appState, bool isTa) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.swap_horiz_rounded, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    isTa ? 'பயனர் பொறுப்பை மாற்றுக' : 'Switch Active User Role',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                isTa
                    ? 'ஒவ்வொருவருக்கும் பொருத்தமான திரை வடிவமைப்பை உடனடியாக பார்க்கலாம்'
                    : 'Each role accesses their dedicated factory tools & navigation tabs',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              _buildRoleOption(
                ctx,
                appState: appState,
                role: AppConstants.roleSales,
                name: 'Vignesh (Sales Executive)',
                badge: isTa ? '💼 விற்பனை பிரதிநிதி' : '💼 Sales Executive',
                desc: 'Orders, retail customers, pricing catalog & credit collections',
                color: AppTheme.neonOrange,
              ),
              _buildRoleOption(
                ctx,
                appState: appState,
                role: AppConstants.roleProduction,
                name: 'Murugan (Production Head)',
                badge: isTa ? '🏭 உற்பத்தி தலைவர்' : '🏭 Production Head',
                desc: 'Plant floor, batch runs, recipe BOM formulation & Brix lab',
                color: AppTheme.neonLime,
              ),
              _buildRoleOption(
                ctx,
                appState: appState,
                role: AppConstants.roleInventory,
                name: 'Muthu Vel (Storekeeper)',
                badge: isTa ? '📦 சரக்கு இருப்பு' : '📦 Inventory In-Charge',
                desc: 'Raw materials, fruit pulp lots, cold store & suppliers',
                color: AppTheme.neonCyan,
              ),
              _buildRoleOption(
                ctx,
                appState: appState,
                role: AppConstants.roleManager,
                name: 'Suresh Pandian (Factory Manager)',
                badge: isTa ? '👔 ஆலை மேலாளர்' : '👔 Factory Manager',
                desc: 'Plant operations, rosters, fleet dispatch & overall oversight',
                color: AppTheme.neonMango,
              ),
              _buildRoleOption(
                ctx,
                appState: appState,
                role: AppConstants.roleAdmin,
                name: 'Ramasamy Kumar (Factory Owner)',
                badge: isTa ? '👑 நிர்வாகி / உரிமையாளர்' : '👑 Factory Owner (Admin)',
                desc: 'Complete ERP controls, financial expenses & business analytics',
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleOption(
    BuildContext context, {
    required AppStateProvider appState,
    required String role,
    required String name,
    required String badge,
    required String desc,
    required Color color,
  }) {
    final isSelected = appState.currentRole == role;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        appState.login(name, role);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.18),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        badge,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isSelected ? color : null,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('ACTIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 20)
            else
              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final appState = Provider.of<AppStateProvider>(context);
    final provider = Provider.of<FactoryDataProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTa = appState.locale.languageCode == 'ta';

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
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
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
          // One-tap Role Switch Chip
          ActionChip(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            avatar: const Icon(Icons.switch_account_rounded, size: 14, color: AppTheme.primaryColor),
            label: Text(
              _getRoleShortLabel(appState.currentRole),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
            onPressed: () => _showRoleSwitchSheet(context, appState, isTa),
          ),
          IconButton(
            tooltip: loc.translate('language'),
            icon: const Icon(Icons.language, size: 20),
            onPressed: () => appState.toggleLanguage(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadAllData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          child: _buildRoleSpecificContent(context, loc, appState, provider, isDark, isTa),
        ),
      ),
    );
  }

  static String _getRoleShortLabel(String role) {
    switch (role) {
      case AppConstants.roleSales:
        return 'Sales';
      case AppConstants.roleProduction:
        return 'Production';
      case AppConstants.roleInventory:
        return 'Inventory';
      case AppConstants.roleManager:
        return 'Manager';
      case AppConstants.roleAdmin:
      default:
        return 'Admin';
    }
  }

  Widget _buildRoleSpecificContent(
    BuildContext context,
    AppLocalizations loc,
    AppStateProvider appState,
    FactoryDataProvider provider,
    bool isDark,
    bool isTa,
  ) {
    switch (appState.currentRole) {
      case AppConstants.roleSales:
        return _buildSalesDashboard(context, loc, appState, provider, isDark, isTa);
      case AppConstants.roleProduction:
        return _buildProductionDashboard(context, loc, appState, provider, isDark, isTa);
      case AppConstants.roleInventory:
        return _buildInventoryDashboard(context, loc, appState, provider, isDark, isTa);
      case AppConstants.roleManager:
        return _buildManagerDashboard(context, loc, appState, provider, isDark, isTa);
      case AppConstants.roleAdmin:
      default:
        return _buildAdminDashboard(context, loc, appState, provider, isDark, isTa);
    }
  }

  // =========================================================================
  // 1. SALES EXECUTIVE DASHBOARD (Only Sales Relevant Metrics)
  // =========================================================================
  Widget _buildSalesDashboard(
    BuildContext context,
    AppLocalizations loc,
    AppStateProvider appState,
    FactoryDataProvider provider,
    bool isDark,
    bool isTa,
  ) {
    final deliveredOrders = provider.orders.where((o) => o.deliveryStatus == AppConstants.orderStatusDelivered).length;
    final pendingOrders = provider.orders.where((o) => o.deliveryStatus != AppConstants.orderStatusDelivered).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Sales Banner
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.neonOrange.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.point_of_sale_rounded, color: AppTheme.neonOrange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isTa ? 'விற்பனை & விநியோகம்: செயல்பாட்டில்' : 'SALES & DISTRIBUTION: ACTIVE',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.5,
                            color: AppTheme.neonOrange,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('$deliveredOrders DELIVERED', style: const TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isTa
                          ? 'இன்றைய ஆர்டர்கள் மற்றும் சூப்பர்மார்க்கெட் வாடிக்கையாளர் பாக்கிகள்'
                          : 'Today orders, fleet dispatch van status & customer credit balances',
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

        // Sales KPI Row 1
        Row(
          children: [
            Expanded(
              child: GlassStatCard(
                title: isTa ? 'இன்றைய விற்பனை' : "Today's Sales",
                value: Formatters.compactCurrency(provider.todaySalesAmount),
                subtitle: '${provider.orders.length} total orders',
                icon: Icons.currency_rupee_rounded,
                accentColor: AppTheme.neonOrange,
                trendBadge: '+14.2%',
                isPositiveTrend: true,
                onTap: () => onNavigateTab?.call(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassStatCard(
                title: isTa ? 'விநியோக பாக்கி' : 'Pending Deliveries',
                value: '$pendingOrders Orders',
                subtitle: '$deliveredOrders delivered today',
                icon: Icons.local_shipping_rounded,
                accentColor: AppTheme.neonCyan,
                trendBadge: pendingOrders == 0 ? 'Clear' : 'In Route',
                isPositiveTrend: pendingOrders == 0,
                onTap: () => onNavigateTab?.call(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Sales KPI Row 2
        Row(
          children: [
            Expanded(
              child: GlassStatCard(
                title: isTa ? 'வசூலிக்க வேண்டிய தொகை' : 'Receivables Balance',
                value: Formatters.compactCurrency(provider.pendingPaymentsTotal),
                subtitle: 'Supermarket credit limits',
                icon: Icons.account_balance_wallet_rounded,
                accentColor: AppTheme.neonPurple,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditLedgerScreen()));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassStatCard(
                title: isTa ? 'தயாரிப்புகள் இருப்பு' : 'Juice SKUs in Stock',
                value: '${provider.products.length} Items',
                subtitle: 'Ready for dispatch',
                icon: Icons.local_drink_rounded,
                accentColor: AppTheme.neonMango,
                onTap: () => onNavigateTab?.call(3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Sales Quick Actions
        SectionHeader(title: isTa ? 'விற்பனை உடனடி செயல்பாடுகள்' : 'Sales Actions'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _glassActionPill(
                context,
                label: isTa ? 'புதிய ஆர்டர்' : 'New Order',
                icon: Icons.add_shopping_cart_rounded,
                color: AppTheme.neonOrange,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateOrderScreen()));
                },
              ),
              _glassActionPill(
                context,
                label: isTa ? 'நேரடி ஸ்டோர்' : 'Retail Store',
                icon: Icons.shopping_bag_rounded,
                color: const Color(0xFF10B981),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerStoreScreen()));
                },
              ),
              _glassActionPill(
                context,
                label: isTa ? 'கிரெடிட் லெட்ஜர்' : 'Credit Ledger',
                icon: Icons.account_balance_wallet_rounded,
                color: AppTheme.neonPurple,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditLedgerScreen()));
                },
              ),
              _glassActionPill(
                context,
                label: isTa ? 'வேன்கள் விநியோகம்' : 'Fleet Dispatch',
                icon: Icons.local_shipping_rounded,
                color: AppTheme.neonCyan,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FleetDispatchScreen()));
                },
              ),
              _glassActionPill(
                context,
                label: isTa ? 'AI தேவை கணிப்பு' : 'AI Demand',
                icon: Icons.auto_awesome_rounded,
                color: Colors.indigo.shade600,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AiForecastingScreen()));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Recent Orders List
        SectionHeader(
          title: isTa ? 'சமீபத்திய ஆர்டர்கள்' : 'Customer Orders & Dispatches',
          subtitle: '${provider.orders.length} orders recorded',
        ),
        if (provider.orders.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No orders yet. Tap + New Order above!')),
          )
        else
          ...provider.orders.map((order) => _buildSalesOrderCard(context, order, isDark, isTa)),

        const SizedBox(height: 16),

        // Key Retail Customers
        SectionHeader(
          title: isTa ? 'முக்கிய சில்லறை வாடிக்கையாளர்கள்' : 'Retail Customers & Credit',
          subtitle: '${provider.customers.length} registered accounts',
        ),
        ...provider.customers.map((c) => _buildCustomerCard(context, c, isDark, isTa)),
      ],
    );
  }

  // =========================================================================
  // 2. PRODUCTION STAFF DASHBOARD (Plant Floor & Batch Quality)
  // =========================================================================
  Widget _buildProductionDashboard(
    BuildContext context,
    AppLocalizations loc,
    AppStateProvider appState,
    FactoryDataProvider provider,
    bool isDark,
    bool isTa,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Factory Telemetry Banner
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
                        Text(
                          isTa ? 'உற்பத்தி தளம்: முழு இயக்கத்தில்' : 'PLANT FLOOR: RUNNING OPTIMAL',
                          style: const TextStyle(
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
                      isTa
                          ? 'பாஸ்டுரைசர் 72°C • சில்லிங் 4.0°C • காப்பிங் வேகம் 120 bpm'
                          : 'Pasteurizer 72°C • Chilling 4.0°C • Capping line 120 bpm • Zero CIP downtime',
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

        // Production KPI Row 1
        Row(
          children: [
            Expanded(
              child: GlassStatCard(
                title: isTa ? 'இன்றைய உற்பத்தி' : "Today's Output",
                value: '${provider.todayProductionLiters.toStringAsFixed(0)} L',
                subtitle: '${provider.batches.length} batches on floor',
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
                title: isTa ? 'உற்பத்தி திறன்' : 'Plant Efficiency',
                value: Formatters.percentage(provider.averageProductionEfficiency),
                subtitle: 'Target 95%',
                icon: Icons.speed_rounded,
                accentColor: AppTheme.neonLime,
                trendBadge: 'Optimal',
                isPositiveTrend: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Production KPI Row 2
        Row(
          children: [
            Expanded(
              child: GlassStatCard(
                title: isTa ? 'சேத வீதம்' : 'Wastage Rate',
                value: Formatters.percentage(provider.averageWastageRate),
                subtitle: 'Target: < 3.0%',
                icon: Icons.recycling_rounded,
                accentColor: provider.averageWastageRate > 3.0 ? Colors.redAccent : AppTheme.neonCyan,
                trendBadge: provider.averageWastageRate <= 3.0 ? 'Nominal' : 'Review',
                isPositiveTrend: provider.averageWastageRate <= 3.0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassStatCard(
                title: isTa ? 'சராசரி பிரிக்ஸ் தரம்' : 'Average Brix °Bx',
                value: '14.2°Bx',
                subtitle: 'Refractometer nominal',
                icon: Icons.science_rounded,
                accentColor: Colors.amber.shade800,
                trendBadge: 'Passed',
                isPositiveTrend: true,
                onTap: () => onNavigateTab?.call(3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Production Quick Actions
        SectionHeader(title: isTa ? 'உற்பத்தி உடனடி கருவிகள்' : 'Plant Floor Actions'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _glassActionPill(
                context,
                label: isTa ? 'புதிய பேட்ச்' : 'New Batch',
                icon: Icons.add_circle_outline,
                color: AppTheme.primaryColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NewBatchScreen()));
                },
              ),
              _glassActionPill(
                context,
                label: isTa ? 'ஃபார்முலேஷன் BOM' : 'Formulation BOM',
                icon: Icons.blender_rounded,
                color: AppTheme.neonMango,
                onTap: () => onNavigateTab?.call(2),
              ),
              _glassActionPill(
                context,
                label: isTa ? 'பிரிக்ஸ் கால்குலேட்டர்' : 'Brix Refractometer',
                icon: Icons.science_rounded,
                color: Colors.amber.shade900,
                onTap: () => onNavigateTab?.call(3),
              ),
              _glassActionPill(
                context,
                label: isTa ? 'லேபிள் டிசைனர்' : 'Label Designer',
                icon: Icons.label_important_rounded,
                color: AppTheme.neonOrange,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LabelDesignerScreen()));
                },
              ),
              _glassActionPill(
                context,
                label: isTa ? 'ஷிப்ட் வருகை' : 'Shift Roster',
                icon: Icons.badge_rounded,
                color: AppTheme.neonLime,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ShiftAttendanceScreen()));
                },
              ),
              _glassActionPill(
                context,
                label: isTa ? 'IoT சென்சார்கள்' : 'IoT Sensors',
                icon: Icons.sensors_rounded,
                color: Colors.cyan.shade700,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const IotTelemetryScreen()));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Batches List
        SectionHeader(
          title: isTa ? 'இயங்கும் மற்றும் சமீபத்திய பேட்ச்கள்' : 'Production Batches on Floor',
          subtitle: '${provider.batches.length} batch runs',
        ),
        ...provider.batches.map((b) => _buildBatchCard(context, b, isDark, isTa)),
      ],
    );
  }

  // =========================================================================
  // 3. INVENTORY & WAREHOUSE DASHBOARD (Raw Materials, Cold Store, Stocks)
  // =========================================================================
  Widget _buildInventoryDashboard(
    BuildContext context,
    AppLocalizations loc,
    AppStateProvider appState,
    FactoryDataProvider provider,
    bool isDark,
    bool isTa,
  ) {
    final rawPulpKg = provider.rawMaterials
        .where((rm) => rm.category == 'Fruits')
        .fold(0.0, (acc, item) => acc + item.quantity);
    final packagingCount = provider.rawMaterials
        .where((rm) => rm.category.contains('Bottles') || rm.category.contains('Caps') || rm.category.contains('Labels'))
        .fold(0.0, (acc, item) => acc + item.quantity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Warehouse Banner
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.neonCyan.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.ac_unit_rounded, color: AppTheme.neonCyan, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isTa ? 'குளிர்சாதன கிடங்கு: சீரானது' : 'COLD WAREHOUSE: 3.8°C OPTIMAL',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.5,
                            color: AppTheme.neonCyan,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('ZERO SPOILAGE', style: TextStyle(color: Colors.tealAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isTa
                          ? 'பழக்கூழ் மற்றும் பேக்கேஜிங் பாட்டில்கள் இருப்பு கண்காணிப்பு'
                          : 'Fruit pulp cold bay, sugar stores, bottle caps & supplier stock',
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

        // Inventory KPI Row 1
        Row(
          children: [
            Expanded(
              child: GlassStatCard(
                title: isTa ? 'பழக்கூழ் இருப்பு' : 'Fruit Pulp Stock',
                value: '${rawPulpKg.toStringAsFixed(0)} Kg',
                subtitle: 'Cold Room A storage',
                icon: Icons.kitchen_rounded,
                accentColor: AppTheme.neonMango,
                trendBadge: 'Fresh',
                isPositiveTrend: true,
                onTap: () => onNavigateTab?.call(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassStatCard(
                title: isTa ? 'பேக்கேஜிங் இருப்பு' : 'Packaging Stock',
                value: '${packagingCount.toInt()} Units',
                subtitle: 'PET bottles, caps, rolls',
                icon: Icons.inventory_2_rounded,
                accentColor: AppTheme.neonCyan,
                onTap: () => onNavigateTab?.call(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Inventory KPI Row 2
        Row(
          children: [
            Expanded(
              child: GlassStatCard(
                title: isTa ? 'குறைந்த இருப்பு எச்சரிக்கை' : 'Low Stock Reorders',
                value: '${provider.lowStockCount}',
                subtitle: provider.lowStockCount > 0 ? 'Requires vendor PO' : 'All stocks adequate',
                icon: Icons.warning_amber_rounded,
                accentColor: provider.lowStockCount > 0 ? Colors.redAccent : Colors.tealAccent,
                trendBadge: provider.lowStockCount > 0 ? 'Order Now' : 'Safe',
                isPositiveTrend: provider.lowStockCount == 0,
                onTap: () => onNavigateTab?.call(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassStatCard(
                title: isTa ? 'சப்ளையர் நெட்வொர்க்' : 'Verified Suppliers',
                value: '${provider.suppliers.length} Vendors',
                subtitle: 'Orchards & packaging',
                icon: Icons.local_shipping_rounded,
                accentColor: AppTheme.neonLime,
                onTap: () => onNavigateTab?.call(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Inventory Quick Actions
        SectionHeader(title: isTa ? 'கிடங்கு உடனடி செயல்பாடுகள்' : 'Warehouse Actions'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _glassActionPill(
                context,
                label: isTa ? 'சரக்கு சேர்' : 'Add Material',
                icon: Icons.add_box_rounded,
                color: AppTheme.neonCyan,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StockAdjustmentScreen()));
                },
              ),
              _glassActionPill(
                context,
                label: isTa ? 'QR ஸ்கேனர்' : 'Scan Lot QR',
                icon: Icons.qr_code_scanner_rounded,
                color: const Color(0xFF10B981),
                onTap: () => onNavigateTab?.call(3),
              ),
              _glassActionPill(
                context,
                label: isTa ? 'சப்ளையர்கள்' : 'Suppliers PO',
                icon: Icons.local_shipping_rounded,
                color: Colors.amber.shade800,
                onTap: () => onNavigateTab?.call(2),
              ),
              _glassActionPill(
                context,
                label: isTa ? 'பார்-கோடு லேபிள்' : 'Barcode Labels',
                icon: Icons.label_important_rounded,
                color: AppTheme.neonOrange,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LabelDesignerScreen()));
                },
              ),
              _glassActionPill(
                context,
                label: isTa ? 'AI கொள்முதல் கணிப்பு' : 'AI Procurement',
                icon: Icons.auto_awesome_rounded,
                color: Colors.indigo.shade600,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AiForecastingScreen()));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Raw Materials Table/Cards
        SectionHeader(
          title: isTa ? 'முக்கிய மூலப்பொருட்கள் இருப்பு' : 'Essential Raw Materials Stock',
          subtitle: '${provider.rawMaterials.length} lot items',
        ),
        ...provider.rawMaterials.map((rm) => _buildRawMaterialCard(context, rm, isDark, isTa)),
      ],
    );
  }

  // =========================================================================
  // 4. MANAGER & ADMIN DASHBOARD (Comprehensive Factory Operations & ERP)
  // =========================================================================
  Widget _buildManagerDashboard(
    BuildContext context,
    AppLocalizations loc,
    AppStateProvider appState,
    FactoryDataProvider provider,
    bool isDark,
    bool isTa,
  ) {
    return _buildAdminDashboard(context, loc, appState, provider, isDark, isTa);
  }

  Widget _buildAdminDashboard(
    BuildContext context,
    AppLocalizations loc,
    AppStateProvider appState,
    FactoryDataProvider provider,
    bool isDark,
    bool isTa,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Factory Telemetry Banner
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
                        Text(
                          isTa ? 'தொழிற்சாலை நிலை: மிக நன்று' : 'FACTORY STATUS: OPTIMAL',
                          style: const TextStyle(
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
                      isTa
                          ? 'லைன் A காப்பிங்: 120 bpm • குளிர்சாதன கிடங்கு: 3.8°C'
                          : 'Line A Capping at 120 bpm • Cold Storage: 3.8°C • Zero CIP downtime',
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

        // KPI Row 3: Pending Payments & Low Stock
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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditLedgerScreen()));
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

        // Quick Actions
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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeFormulationScreen()));
                },
              ),
              _glassActionPill(
                context,
                label: loc.translate('createBatch'),
                icon: Icons.add_circle_outline,
                color: AppTheme.primaryColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NewBatchScreen()));
                },
              ),
              _glassActionPill(
                context,
                label: loc.translate('newOrder'),
                icon: Icons.shopping_cart_checkout,
                color: AppColors.secondary,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateOrderScreen()));
                },
              ),
              _glassActionPill(
                context,
                label: 'Fleet Dispatch',
                icon: Icons.local_shipping_rounded,
                color: AppTheme.neonCyan,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FleetDispatchScreen()));
                },
              ),
              _glassActionPill(
                context,
                label: 'Credit Ledger',
                icon: Icons.account_balance_wallet_rounded,
                color: AppTheme.neonPurple,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditLedgerScreen()));
                },
              ),
              _glassActionPill(
                context,
                label: 'IoT Sensors',
                icon: Icons.sensors_rounded,
                color: Colors.cyan.shade700,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const IotTelemetryScreen()));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Weekly Production Trend Chart
        SectionHeader(
          title: loc.translate('weeklyProductionTrend'),
          subtitle: '7-Day Liters Output',
        ),
        _buildProductionChart(context, provider, isDark),
        const SizedBox(height: 20),

        // Recent Batches
        SectionHeader(
          title: loc.translate('recentBatches'),
        ),
        ...provider.batches.take(2).map((b) => _buildBatchCard(context, b, isDark, isTa)),
      ],
    );
  }

  // Helper Card Builders
  Widget _buildSalesOrderCard(BuildContext context, dynamic order, bool isDark, bool isTa) {
    final isDelivered = order.deliveryStatus == AppConstants.orderStatusDelivered;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDelivered ? Colors.green.withOpacity(0.14) : Colors.orange.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDelivered ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                color: isDelivered ? Colors.greenAccent : Colors.orangeAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.customerName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.orderNumber} • ${Formatters.date(order.orderDate)}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.currency(order.grandTotal),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppTheme.neonOrange),
                ),
                const SizedBox(height: 2),
                StatBadge(
                  label: order.deliveryStatus.toUpperCase(),
                  color: isDelivered ? AppColors.success : AppColors.warning,
                  fontSize: 9.5,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, dynamic customer, bool isDark, bool isTa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.neonPurple.withOpacity(0.18),
              child: const Icon(Icons.storefront_rounded, color: AppTheme.neonPurple, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(customer.address, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  customer.outstandingBalance > 0 ? Formatters.currency(customer.outstandingBalance) : '₹0 Due',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: customer.outstandingBalance > 0 ? Colors.redAccent : Colors.greenAccent,
                  ),
                ),
                Text(customer.customerType, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchCard(BuildContext context, dynamic batch, bool isDark, bool isTa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BatchDetailScreen(batchId: batch.id)),
          );
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.neonMango.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.precision_manufacturing_rounded, color: AppTheme.neonMango, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(batch.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  const SizedBox(height: 2),
                  Text('${batch.batchNumber} • ${batch.assignedStaff}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${batch.actualQty > 0 ? batch.actualQty.toInt() : batch.plannedQty.toInt()} L',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppTheme.neonLime)),
                const SizedBox(height: 2),
                StatBadge(
                  label: batch.status.toUpperCase(),
                  color: batch.status == AppConstants.batchStatusCompleted ? AppColors.success : AppColors.info,
                  fontSize: 9.5,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRawMaterialCard(BuildContext context, dynamic rm, bool isDark, bool isTa) {
    final isLow = rm.quantity <= rm.minStockLevel;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLow ? Colors.red.withOpacity(0.14) : AppTheme.neonCyan.withOpacity(0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isLow ? Icons.warning_amber_rounded : Icons.inventory_2_rounded,
                color: isLow ? Colors.redAccent : AppTheme.neonCyan,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rm.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('${rm.batchNumber} • ${rm.storageLocation}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${rm.quantity.toInt()} ${rm.unit}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isLow ? Colors.redAccent : AppTheme.neonLime,
                  ),
                ),
                Text('Min: ${rm.minStockLevel.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductionChart(BuildContext context, FactoryDataProvider provider, bool isDark) {
    final todayLiters = provider.todayProductionLiters > 0 ? provider.todayProductionLiters : 300.0;
    final List<double> weeklyProduction = [260.0, 310.0, 280.0, 340.0, 290.0, 320.0, todayLiters];

    double maxVal = weeklyProduction.reduce((a, b) => a > b ? a : b);
    if (maxVal < 400) maxVal = 400;
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
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: chartMaxY,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => isDark ? const Color(0xFF1E293B) : Colors.white,
                tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toInt()} L\n${dayNames[group.x.toInt()]}',
                    TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 38,
                  interval: yInterval,
                  getTitlesWidget: (val, meta) => Text(
                    '${val.toInt()}L',
                    style: TextStyle(
                      fontSize: 9.5,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, meta) {
                    final idx = val.toInt();
                    if (idx < 0 || idx >= dayNames.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        dayNames[idx],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: idx == 6 ? FontWeight.bold : FontWeight.normal,
                          color: idx == 6 ? AppTheme.neonMango : (isDark ? Colors.white54 : Colors.black54),
                        ),
                      ),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: yInterval,
              getDrawingHorizontalLine: (val) => FlLine(
                color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(7, (i) {
              final isToday = i == 6;
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: weeklyProduction[i],
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: isToday
                          ? [AppTheme.neonOrange, AppTheme.neonMango]
                          : [AppTheme.primaryColor.withOpacity(0.5), AppTheme.neonLime.withOpacity(0.8)],
                    ),
                    width: 14,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _glassActionPill(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
