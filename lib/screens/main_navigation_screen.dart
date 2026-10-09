import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
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
    final provider = Provider.of<FactoryDataProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unreadNotifs = provider.notifications.where((n) => !n.isRead).length;

    final List<Widget> pages = [
      DashboardScreen(onNavigateTab: _onTabTapped),
      const ProductionListScreen(),
      const InventoryScreen(),
      const OrdersScreen(),
      _buildMoreMenuScreen(context, loc, unreadNotifs, isDark),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildFloatingGlassDock(context, loc, unreadNotifs, isDark),
    );
  }

  Widget _buildFloatingGlassDock(
    BuildContext context,
    AppLocalizations loc,
    int unreadNotifs,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A).withOpacity(0.82) : Colors.white.withOpacity(0.85),
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
              children: [
                _buildDockItem(
                  index: 0,
                  icon: Icons.dashboard_rounded,
                  activeIcon: Icons.dashboard,
                  label: loc.translate('dashboard'),
                ),
                _buildDockItem(
                  index: 1,
                  icon: Icons.precision_manufacturing_outlined,
                  activeIcon: Icons.precision_manufacturing,
                  label: loc.translate('production'),
                ),
                _buildDockItem(
                  index: 2,
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2,
                  label: loc.translate('inventory'),
                ),
                _buildDockItem(
                  index: 3,
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  label: loc.translate('orders'),
                ),
                _buildDockItem(
                  index: 4,
                  icon: Icons.grid_view_rounded,
                  activeIcon: Icons.grid_view_rounded,
                  label: loc.translate('more'),
                  badgeCount: unreadNotifs,
                ),
              ],
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

  Widget _buildMoreMenuScreen(
      BuildContext context, AppLocalizations loc, int unreadNotifs, bool isDark) {
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('more')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Section: Customer Direct Storefront
          _buildSectionHeader('CUSTOMER STORE & ORDERING', const Color(0xFF10B981)),
          _menuTile(
            title: 'Customer Storefront & Juice Ordering',
            subtitle: 'Direct retail ordering, custom bottle quantities, auto-bills & UPI payment',
            icon: Icons.shopping_bag_rounded,
            color: const Color(0xFF10B981),
            badge: 'STORE',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerStoreScreen()),
              );
            },
          ),
          const SizedBox(height: 20),

          // Section: Advanced Factory Modules
          _buildSectionHeader('NEW FACTORY MANAGEMENT MODULES', AppTheme.primaryColor),
          _menuTile(
            title: 'Recipe & Formulation Builder',
            subtitle: 'BOM formulation, pulp dilution, sugar ratio & unit bottle costing',
            icon: Icons.blender_rounded,
            color: AppTheme.neonMango,
            badge: 'NEW',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecipeFormulationScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Smart Label & Barcode Designer',
            subtitle: 'Bottle/carton sticker design, FSSAI, nutrition table & PDF printing',
            icon: Icons.label_important_rounded,
            color: AppTheme.neonOrange,
            badge: 'NEW',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LabelDesignerScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Shift & Worker Attendance',
            subtitle: 'Morning/Evening/Night rosters, station assignments & batch tracking',
            icon: Icons.badge_rounded,
            color: AppTheme.neonLime,
            badge: 'NEW',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShiftAttendanceScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Fleet & Delivery Dispatch',
            subtitle: 'Cold-chain Reefer van tracking, trip routes & digital delivery proof',
            icon: Icons.local_shipping_rounded,
            color: AppTheme.neonCyan,
            badge: 'NEW',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FleetDispatchScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Customer Credit & Aging Ledger',
            subtitle: 'Retailer credit limits, invoice aging, WhatsApp payment reminders',
            icon: Icons.account_balance_wallet_rounded,
            color: AppTheme.neonPurple,
            badge: 'NEW',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreditLedgerScreen()),
              );
            },
          ),
          const SizedBox(height: 20),

          // Section: Advanced Lab & IoT
          _buildSectionHeader('ADVANCED TECHNOLOGIES & LAB', AppColors.secondary),
          _menuTile(
            title: 'IoT Factory Telemetry',
            subtitle: 'Real-time HTST pasteurizer, chiller vat & homogenizer sensors',
            icon: Icons.sensors_rounded,
            color: Colors.cyan.shade700,
            badge: 'LIVE',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const IotTelemetryScreen()),
              );
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiForecastingScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Brix Refractometer & Lab Calculator',
            subtitle: 'ICUMSA temperature correction & batch water dilution formulas',
            icon: Icons.science_rounded,
            color: Colors.amber.shade900,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrixCalculatorScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Batch QR & Barcode Laser Scanner',
            subtitle: 'Viewfinder camera scanner & FSSAI batch certificate verification',
            icon: Icons.qr_code_scanner_rounded,
            color: const Color(0xFF10B981),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrScannerScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: 'Factory CIP & Maintenance Logs',
            subtitle: 'HACCP sanitation compliance, capping torque & equipment service',
            icon: Icons.cleaning_services_rounded,
            color: Colors.green.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MaintenanceScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: '3D Fluid & Tumbler Experience',
            subtitle: 'Interactive 3D juice flowing from fruits into tumbler simulation',
            icon: Icons.view_in_ar_rounded,
            color: AppColors.secondary,
            badge: '3D',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('3D JuiceFlow Fluid Tumbler')),
                    body: const JuiceFlowing3dTumbler(autoAdvance: false),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Section: Core Factory Operations
          _buildSectionHeader('CORE FACTORY MANAGEMENT', Colors.grey),
          _menuTile(
            title: loc.translate('products'),
            subtitle: 'Juice recipes, SKU codes, bottle sizes & MRP',
            icon: Icons.local_drink_rounded,
            color: AppColors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductListScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: loc.translate('customers'),
            subtitle: 'Supermarkets, retailers, hotels & credit balances',
            icon: Icons.storefront_rounded,
            color: AppColors.secondary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomersScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: loc.translate('suppliers'),
            subtitle: 'Fruit orchards, packaging & ingredients vendors',
            icon: Icons.local_shipping_rounded,
            color: Colors.amber.shade800,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SuppliersScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: loc.translate('expenses'),
            subtitle: 'Electricity, machinery service, transport, wages',
            icon: Icons.receipt_long_rounded,
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExpensesScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: loc.translate('reports'),
            subtitle: 'Executive summaries, CSV and PDF reports',
            icon: Icons.analytics_rounded,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: loc.translate('staff'),
            subtitle: 'Workers, supervisors, roles & activity counts',
            icon: Icons.people_alt_rounded,
            color: Colors.indigo,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StaffScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: loc.translate('notifications'),
            subtitle: 'Low stock alerts, quality checks & pending orders',
            icon: Icons.notifications_active_rounded,
            color: AppColors.error,
            badge: unreadNotifs > 0 ? '$unreadNotifs' : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuTile(
            title: loc.translate('auditLog'),
            subtitle: 'Traceable operations log for factory compliance',
            icon: Icons.history_rounded,
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuditLogScreen()),
              );
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
            subtitle: 'Factory profile, English/Tamil language & theme',
            icon: Icons.settings_rounded,
            color: Colors.blueGrey,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(height: 32),
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badge == 'NEW' ? AppTheme.primaryColor : AppColors.error,
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
