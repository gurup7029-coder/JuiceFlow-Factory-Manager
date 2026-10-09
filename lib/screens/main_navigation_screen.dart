import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state_provider.dart';
import '../providers/factory_data_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'production/production_list_screen.dart';
import 'inventory/inventory_screen.dart';
import 'orders/orders_screen.dart';
import 'products/product_list_screen.dart';
import 'customers/customers_screen.dart';
import 'suppliers/suppliers_screen.dart';
import 'expenses/expenses_screen.dart';
import 'reports/reports_screen.dart';
import 'staff/staff_screen.dart';
import 'notifications/notifications_screen.dart';
import 'audit/audit_log_screen.dart';
import 'settings/settings_screen.dart';
import 'iot/iot_telemetry_screen.dart';
import 'analytics/ai_forecasting_screen.dart';
import 'tools/brix_calculator_screen.dart';
import 'tools/qr_scanner_screen.dart';
import 'tools/label_designer_screen.dart';
import 'recipes/recipe_formulation_screen.dart';
import 'staff/shift_attendance_screen.dart';
import 'dispatch/fleet_dispatch_screen.dart';
import 'customers/credit_ledger_screen.dart';
import 'maintenance/maintenance_screen.dart';
import 'customer/customer_store_screen.dart';
import '../core/services/notification_service.dart';
import '../widgets/juice_flowing_3d_tumbler.dart';
import '../widgets/glass_card.dart';

class _DockTabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badge;

  const _DockTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final appState = Provider.of<AppStateProvider>(context);
    final provider = Provider.of<FactoryDataProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTa = appState.locale.languageCode == 'ta';

    final unreadNotifs = provider.notifications.where((n) => !n.isRead).length;

    // DYNAMIC ROLE-BASED NAVIGATION ARCHITECTURE
    List<Widget> pages;
    List<_DockTabItem> tabs;

    switch (appState.currentRole) {
      case AppConstants.roleSales:
        pages = [
          DashboardScreen(onNavigateTab: _onTabTapped),
          const OrdersScreen(),
          const CustomersScreen(),
          const ProductListScreen(),
          _buildSalesHubScreen(context, loc, unreadNotifs, isDark, isTa),
        ];
        tabs = [
          _DockTabItem(
            icon: Icons.point_of_sale_outlined,
            activeIcon: Icons.point_of_sale_rounded,
            label: isTa ? 'விற்பனை' : 'Sales',
          ),
          _DockTabItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: loc.translate('orders'),
          ),
          _DockTabItem(
            icon: Icons.storefront_outlined,
            activeIcon: Icons.storefront_rounded,
            label: loc.translate('customers'),
          ),
          _DockTabItem(
            icon: Icons.local_drink_outlined,
            activeIcon: Icons.local_drink_rounded,
            label: isTa ? 'பழச்சாறுகள்' : 'Catalog',
          ),
          _DockTabItem(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: isTa ? 'விற்பனை மையம்' : 'Sales Hub',
            badge: unreadNotifs,
          ),
        ];
        break;

      case AppConstants.roleProduction:
        pages = [
          DashboardScreen(onNavigateTab: _onTabTapped),
          const ProductionListScreen(),
          const RecipeFormulationScreen(),
          const BrixCalculatorScreen(),
          _buildProductionHubScreen(context, loc, unreadNotifs, isDark, isTa),
        ];
        tabs = [
          _DockTabItem(
            icon: Icons.precision_manufacturing_outlined,
            activeIcon: Icons.precision_manufacturing_rounded,
            label: isTa ? 'இயக்கம்' : 'Plant Floor',
          ),
          _DockTabItem(
            icon: Icons.batch_prediction_outlined,
            activeIcon: Icons.batch_prediction_rounded,
            label: loc.translate('production'),
          ),
          _DockTabItem(
            icon: Icons.blender_outlined,
            activeIcon: Icons.blender_rounded,
            label: isTa ? 'ஃபார்முலா' : 'Recipes',
          ),
          _DockTabItem(
            icon: Icons.science_outlined,
            activeIcon: Icons.science_rounded,
            label: isTa ? 'தர ஆய்வகம்' : 'Brix Lab',
          ),
          _DockTabItem(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: isTa ? 'தொழிற்சாலை மையம்' : 'Plant Hub',
            badge: unreadNotifs,
          ),
        ];
        break;

      case AppConstants.roleInventory:
        pages = [
          DashboardScreen(onNavigateTab: _onTabTapped),
          const InventoryScreen(),
          const SuppliersScreen(),
          const QrScannerScreen(),
          _buildInventoryHubScreen(context, loc, unreadNotifs, isDark, isTa),
        ];
        tabs = [
          _DockTabItem(
            icon: Icons.warehouse_outlined,
            activeIcon: Icons.warehouse_rounded,
            label: isTa ? 'கிடங்கு' : 'Warehouse',
          ),
          _DockTabItem(
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2_rounded,
            label: isTa ? 'மூலப்பொருள்' : 'Raw Stock',
          ),
          _DockTabItem(
            icon: Icons.local_shipping_outlined,
            activeIcon: Icons.local_shipping_rounded,
            label: loc.translate('suppliers'),
          ),
          _DockTabItem(
            icon: Icons.qr_code_scanner_outlined,
            activeIcon: Icons.qr_code_scanner_rounded,
            label: isTa ? 'ஸ்கேனர்' : 'Scan Lots',
          ),
          _DockTabItem(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: isTa ? 'கிடங்கு மையம்' : 'Store Hub',
            badge: unreadNotifs,
          ),
        ];
        break;

      case AppConstants.roleManager:
        pages = [
          DashboardScreen(onNavigateTab: _onTabTapped),
          const ProductionListScreen(),
          const InventoryScreen(),
          const OrdersScreen(),
          _buildManagerHubScreen(context, loc, unreadNotifs, isDark, isTa),
        ];
        tabs = [
          _DockTabItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: isTa ? 'செயல்பாடுகள்' : 'Operations',
          ),
          _DockTabItem(
            icon: Icons.precision_manufacturing_outlined,
            activeIcon: Icons.precision_manufacturing_rounded,
            label: loc.translate('production'),
          ),
          _DockTabItem(
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2_rounded,
            label: loc.translate('inventory'),
          ),
          _DockTabItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: loc.translate('orders'),
          ),
          _DockTabItem(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: isTa ? 'மேலாளர் மையம்' : 'Manager Hub',
            badge: unreadNotifs,
          ),
        ];
        break;

      case AppConstants.roleAdmin:
      default:
        pages = [
          DashboardScreen(onNavigateTab: _onTabTapped),
          const ProductionListScreen(),
          const InventoryScreen(),
          const OrdersScreen(),
          _buildAdminHubScreen(context, loc, unreadNotifs, isDark, isTa),
        ];
        tabs = [
          _DockTabItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: isTa ? 'நிர்வாகம்' : 'Executive',
          ),
          _DockTabItem(
            icon: Icons.precision_manufacturing_outlined,
            activeIcon: Icons.precision_manufacturing_rounded,
            label: loc.translate('production'),
          ),
          _DockTabItem(
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2_rounded,
            label: loc.translate('inventory'),
          ),
          _DockTabItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: loc.translate('orders'),
          ),
          _DockTabItem(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: isTa ? 'முழு மையம்' : 'ERP Hub',
            badge: unreadNotifs,
          ),
        ];
        break;
    }

    final safeIndex = _currentIndex.clamp(0, pages.length - 1);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: safeIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildFloatingGlassDock(context, tabs, isDark),
    );
  }

  Widget _buildFloatingGlassDock(
    BuildContext context,
    List<_DockTabItem> tabs,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white.withOpacity(0.90),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.12),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (i) {
                final item = tabs[i];
                return _buildDockItem(
                  index: i,
                  icon: item.icon,
                  activeIcon: item.activeIcon,
                  label: item.label,
                  badgeCount: item.badge,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int? badgeCount,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppTheme.primaryColor.withOpacity(0.5), width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade400,
                  size: 22,
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. SALES HUB SCREEN (Tailored for Sales Staff) ---
  Widget _buildSalesHubScreen(
      BuildContext context, AppLocalizations loc, int unreadNotifs, bool isDark, bool isTa) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isTa ? '💼 விற்பனை மேலாண்மை மையம்' : '💼 Sales & Distribution Hub'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          _buildRoleBanner(
            title: isTa ? 'விற்பனை பிரதிநிதி தளம்' : 'SALES EXECUTIVE PORTAL',
            subtitle: isTa
                ? 'வாடிக்கையாளர் ஆர்டர்கள், பாக்கி கணக்கு மற்றும் டெலிவரி மேலாண்மை'
                : 'Customer orders, invoices, credit ledger & fleet delivery dispatches',
            icon: Icons.point_of_sale_rounded,
            color: AppTheme.neonOrange,
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('DIRECT SALES & ORDERS', AppTheme.neonOrange),
          _menuTile(
            title: 'Customer Storefront & Retail Ordering',
            subtitle: 'Direct customer ordering, quantity pricing, auto-bills & UPI QR',
            icon: Icons.shopping_bag_rounded,
            color: const Color(0xFF10B981),
            badge: 'STORE',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerStoreScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Customer Credit & Aging Ledger',
            subtitle: 'Retailer credit limits, invoice aging & WhatsApp payment reminders',
            icon: Icons.account_balance_wallet_rounded,
            color: AppTheme.neonPurple,
            badge: 'RECEIVABLES',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditLedgerScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Fleet & Delivery Dispatch',
            subtitle: 'Cold-chain delivery van tracking, trip routes & digital delivery proof',
            icon: Icons.local_shipping_rounded,
            color: AppTheme.neonCyan,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FleetDispatchScreen()));
            },
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('SALES INTELLIGENCE & ALERTS', AppColors.secondary),
          _menuTile(
            title: 'AI Demand & Seasonality Engine',
            subtitle: 'Weather telemetry correlation & customer purchase forecast',
            icon: Icons.auto_awesome_rounded,
            color: Colors.indigo.shade600,
            badge: 'AI',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AiForecastingScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Test Instant Phone Notification',
            subtitle: 'Verify real-time mobile order alerts (works even when app is closed)',
            icon: Icons.notification_important_rounded,
            color: Colors.deepOrange,
            onTap: () async {
              await NotificationService.instance.sendTestNotification();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔔 Notification sent! Check phone notification bar.'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: loc.translate('settings'),
            subtitle: 'Language (தமிழ்/English) & App Theme',
            icon: Icons.settings_rounded,
            color: Colors.blueGrey,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }

  // --- 2. PRODUCTION HUB SCREEN (Tailored for Production Staff) ---
  Widget _buildProductionHubScreen(
      BuildContext context, AppLocalizations loc, int unreadNotifs, bool isDark, bool isTa) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isTa ? '🏭 உற்பத்தி பிரிவு மையம்' : '🏭 Plant Floor Operations Hub'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          _buildRoleBanner(
            title: isTa ? 'தயாரிப்பு & தரக்கட்டுப்பாடு' : 'PRODUCTION & QUALITY FLOOR',
            subtitle: isTa
                ? 'சாறு உற்பத்தி ஃபார்முலா, தொழிலாளர் சுழற்சி & சுத்திகரிப்பு பதிவுகள்'
                : 'Batch formulations, shift rosters, CIP sanitation & machine telemetry',
            icon: Icons.precision_manufacturing_rounded,
            color: AppTheme.neonLime,
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('PLANT FLOOR MODULES', AppTheme.neonLime),
          _menuTile(
            title: 'Shift & Worker Attendance Rosters',
            subtitle: 'Morning/Evening rosters, station assignments & batch tracking',
            icon: Icons.badge_rounded,
            color: AppTheme.neonLime,
            badge: 'ROSTER',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ShiftAttendanceScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Factory CIP & Sanitation Logs',
            subtitle: 'HACCP sanitation compliance, pasteurizer CIP & machine service',
            icon: Icons.cleaning_services_rounded,
            color: Colors.green.shade700,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Smart Label & Barcode Designer',
            subtitle: 'FSSAI compliance, nutrition facts table, batch code & PDF print',
            icon: Icons.label_important_rounded,
            color: AppTheme.neonOrange,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LabelDesignerScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'IoT Factory Telemetry',
            subtitle: 'Live HTST pasteurizer (72°C), chiller vat & homogenizer pressure',
            icon: Icons.sensors_rounded,
            color: Colors.cyan.shade700,
            badge: 'LIVE',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const IotTelemetryScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: '3D Fluid & Tumbler Experience',
            subtitle: 'Interactive 3D juice flowing from fresh fruits into tumbler',
            icon: Icons.view_in_ar_rounded,
            color: AppColors.secondary,
            badge: '3D',
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
          const SizedBox(height: 16),

          _buildSectionHeader('SYSTEM & SETTINGS', Colors.grey),
          _menuTile(
            title: 'Test Native Phone Notification',
            subtitle: 'Trigger instant phone notification for temperature/batch alerts',
            icon: Icons.notification_important_rounded,
            color: Colors.deepOrange,
            onTap: () async {
              await NotificationService.instance.sendTestNotification();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔔 Notification sent! Check phone notification bar.'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: loc.translate('settings'),
            subtitle: 'Language & Theme Settings',
            icon: Icons.settings_rounded,
            color: Colors.blueGrey,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }

  // --- 3. INVENTORY HUB SCREEN (Tailored for Inventory Staff) ---
  Widget _buildInventoryHubScreen(
      BuildContext context, AppLocalizations loc, int unreadNotifs, bool isDark, bool isTa) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isTa ? '📦 கிடங்கு & இருப்பு மையம்' : '📦 Warehouse & Inventory Hub'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          _buildRoleBanner(
            title: isTa ? 'மூலப்பொருள் & கிடங்கு தளம்' : 'RAW MATERIALS & COLD STORAGE',
            subtitle: isTa
                ? 'பழக்கூழ், பாட்டில்கள், மூடிகள் & சப்ளையர் கொள்முதல் மேலாண்மை'
                : 'Pulp lots, packaging supplies, supplier POs & reorder alerts',
            icon: Icons.inventory_2_rounded,
            color: AppTheme.neonCyan,
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('INVENTORY TOOLS', AppTheme.neonCyan),
          _menuTile(
            title: 'Smart Label & Barcode Designer',
            subtitle: 'Pallet lot barcode stickers, raw material tags & carton labels',
            icon: Icons.label_important_rounded,
            color: AppTheme.neonOrange,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LabelDesignerScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'AI Raw Fruit Procurement Forecast',
            subtitle: 'Predict fruit requirements based on weather & historical juice run',
            icon: Icons.auto_awesome_rounded,
            color: Colors.indigo.shade600,
            badge: 'AI',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AiForecastingScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Cold Storage Room & Equipment Logs',
            subtitle: 'Cold Room A & B temperature checks and maintenance history',
            icon: Icons.ac_unit_rounded,
            color: Colors.blue.shade700,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceScreen()));
            },
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('ALERTS & SETTINGS', Colors.grey),
          _menuTile(
            title: 'Test Native Phone Notification',
            subtitle: 'Trigger instant phone notification for low stock reorders',
            icon: Icons.notification_important_rounded,
            color: Colors.deepOrange,
            onTap: () async {
              await NotificationService.instance.sendTestNotification();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔔 Notification sent! Check phone notification bar.'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: loc.translate('settings'),
            subtitle: 'Language & Theme Settings',
            icon: Icons.settings_rounded,
            color: Colors.blueGrey,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }

  // --- 4. MANAGER HUB SCREEN (Tailored for Factory Manager) ---
  Widget _buildManagerHubScreen(
      BuildContext context, AppLocalizations loc, int unreadNotifs, bool isDark, bool isTa) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isTa ? '👔 ஆலை மேலாளர் கட்டுப்பாட்டு மையம்' : '👔 Plant Manager Operations Hub'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          _buildRoleBanner(
            title: isTa ? 'தொழிற்சாலை முழு மேலாண்மை' : 'PLANT OPERATIONS MANAGEMENT',
            subtitle: isTa
                ? 'உற்பத்தி, சரக்கு, விநியோகம் மற்றும் தொழிலாளர் ஒருங்கிணைப்பு'
                : 'Production runs, warehouse stock, fleet distribution & worker shifts',
            icon: Icons.engineering_rounded,
            color: AppTheme.neonMango,
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('OPERATIONAL MODULES', AppTheme.neonMango),
          _menuTile(
            title: 'Recipe & Formulation Builder',
            subtitle: 'BOM formulation, pulp dilution, sugar ratio & unit bottle costing',
            icon: Icons.blender_rounded,
            color: AppTheme.neonMango,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeFormulationScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Shift & Worker Attendance',
            subtitle: 'Shift rosters, station assignments & plant staff management',
            icon: Icons.badge_rounded,
            color: AppTheme.neonLime,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ShiftAttendanceScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Fleet & Delivery Dispatch',
            subtitle: 'Reefer van delivery trips & dispatch tracking',
            icon: Icons.local_shipping_rounded,
            color: AppTheme.neonCyan,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FleetDispatchScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'IoT Factory Telemetry',
            subtitle: 'Real-time HTST pasteurizer & chiller vat sensors',
            icon: Icons.sensors_rounded,
            color: Colors.cyan.shade700,
            badge: 'LIVE',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const IotTelemetryScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'AI Demand & Seasonality Engine',
            subtitle: 'Weather telemetry correlation & raw fruit forecast',
            icon: Icons.auto_awesome_rounded,
            color: Colors.indigo.shade600,
            badge: 'AI',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AiForecastingScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Factory CIP & Maintenance Logs',
            subtitle: 'HACCP sanitation compliance & equipment service',
            icon: Icons.cleaning_services_rounded,
            color: Colors.green.shade700,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceScreen()));
            },
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('INTELLIGENCE & REPORTS', Colors.grey),
          _menuTile(
            title: loc.translate('reports'),
            subtitle: 'Factory production & dispatch reports (PDF/CSV)',
            icon: Icons.analytics_rounded,
            color: Colors.blue,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: loc.translate('staff'),
            subtitle: 'Factory technicians, shift supervisors & workers',
            icon: Icons.people_alt_rounded,
            color: Colors.indigo,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: loc.translate('settings'),
            subtitle: 'Factory profile, English/Tamil language & theme',
            icon: Icons.settings_rounded,
            color: Colors.blueGrey,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }

  // --- 5. ADMIN / OWNER HUB SCREEN (Full Executive Access) ---
  Widget _buildAdminHubScreen(
      BuildContext context, AppLocalizations loc, int unreadNotifs, bool isDark, bool isTa) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isTa ? '👑 தொழிற்சாலை உரிமையாளர் ERP' : '👑 Executive Plant ERP Hub'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          _buildRoleBanner(
            title: isTa ? 'முழு தொழிற்சாலை கட்டுப்பாட்டு மையம்' : 'EXECUTIVE FACTORY OS',
            subtitle: isTa
                ? 'நிதி, தயாரிப்பு, ஆலை செட்டிங்ஸ் மற்றும் முழு அமைப்பின் நிர்வாகம்'
                : 'Complete business analytics, plant profile, finances & system configuration',
            icon: Icons.admin_panel_settings_rounded,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('CUSTOMER & RETAIL STORE', const Color(0xFF10B981)),
          _menuTile(
            title: 'Customer Storefront & Retail Ordering',
            subtitle: 'Direct retail ordering, custom bottle quantities, auto-bills & UPI payment',
            icon: Icons.shopping_bag_rounded,
            color: const Color(0xFF10B981),
            badge: 'STORE',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerStoreScreen()));
            },
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('ADVANCED MODULES', AppTheme.primaryColor),
          _menuTile(
            title: 'Recipe & Formulation Builder',
            subtitle: 'BOM formulation, pulp dilution, sugar ratio & unit bottle costing',
            icon: Icons.blender_rounded,
            color: AppTheme.neonMango,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeFormulationScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Customer Credit & Aging Ledger',
            subtitle: 'Retailer credit limits, invoice aging, WhatsApp payment reminders',
            icon: Icons.account_balance_wallet_rounded,
            color: AppTheme.neonPurple,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditLedgerScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Fleet & Delivery Dispatch',
            subtitle: 'Cold-chain Reefer van tracking, trip routes & digital delivery proof',
            icon: Icons.local_shipping_rounded,
            color: AppTheme.neonCyan,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FleetDispatchScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'IoT Factory Telemetry',
            subtitle: 'Real-time HTST pasteurizer, chiller vat & homogenizer sensors',
            icon: Icons.sensors_rounded,
            color: Colors.cyan.shade700,
            badge: 'LIVE',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const IotTelemetryScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'AI Demand & Seasonality Engine',
            subtitle: 'Weather telemetry correlation & raw fruit procurement forecast',
            icon: Icons.auto_awesome_rounded,
            color: Colors.indigo.shade600,
            badge: 'AI',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AiForecastingScreen()));
            },
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('FINANCE & CORE MANAGEMENT', Colors.grey),
          _menuTile(
            title: loc.translate('expenses'),
            subtitle: 'Electricity bills, machinery service, transport, wages',
            icon: Icons.receipt_long_rounded,
            color: Colors.purple,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: loc.translate('reports'),
            subtitle: 'Executive summaries, CSV and PDF reports',
            icon: Icons.analytics_rounded,
            color: Colors.blue,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: loc.translate('staff'),
            subtitle: 'Workers, supervisors, roles & activity counts',
            icon: Icons.people_alt_rounded,
            color: Colors.indigo,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: loc.translate('notifications'),
            subtitle: 'Factory alerts, low stock warnings & batch signoffs',
            icon: Icons.notifications_active_rounded,
            color: AppColors.error,
            badge: unreadNotifs > 0 ? '$unreadNotifs' : null,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: loc.translate('auditLog'),
            subtitle: 'Traceable operations log for factory compliance',
            icon: Icons.history_rounded,
            color: Colors.teal,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AuditLogScreen()));
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Test Native Phone Notification',
            subtitle: 'Trigger instant phone notification (even if app is closed/in background)',
            icon: Icons.notification_important_rounded,
            color: Colors.deepOrange,
            badge: 'TEST',
            onTap: () async {
              await NotificationService.instance.sendTestNotification();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔔 Notification sent! Check your phone notification bar.'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: loc.translate('settings'),
            subtitle: 'Factory profile, reset factory data, language & theme',
            icon: Icons.settings_rounded,
            color: Colors.blueGrey,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildRoleBanner({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.8,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: accentColor,
        ),
      ),
    );
  }

  Widget _menuTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badge == 'NEW' || badge == 'LIVE' || badge == 'AI' || badge == 'STORE'
                      ? AppTheme.primaryColor
                      : AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
