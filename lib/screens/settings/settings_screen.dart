import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/factory_data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/stat_badge.dart';
import '../audit/audit_log_screen.dart';
import '../auth/login_screen.dart';
import '../setup/setup_wizard_screen.dart';
import 'factory_profile_screen.dart';
import '../../widgets/cloud_update_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showRoleSwitchDialog(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.translate('switchRole')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.allRoles.map((role) {
            final isSelected = appState.currentRole == role;
            return ListTile(
              title: Text(
                _getRoleDisplayName(role),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : null,
                ),
              ),
              trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                appState.setCurrentRole(role);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Switched view to ${_getRoleDisplayName(role)}')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  static String _getRoleDisplayName(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return 'Factory Owner (Admin)';
      case AppConstants.roleManager:
        return 'Factory Manager';
      case AppConstants.roleProduction:
        return 'Production Staff';
      case AppConstants.roleInventory:
        return 'Inventory Staff';
      case AppConstants.roleSales:
        return 'Sales Staff';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final appState = Provider.of<AppStateProvider>(context);
    final dataProvider = Provider.of<FactoryDataProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User & Role Card
          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.currentUserName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getRoleDisplayName(appState.currentRole),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _showRoleSwitchDialog(context),
                  child: const Text('Switch Role', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Factory Profile Section
          _settingsTile(
            title: loc.translate('factoryProfile'),
            subtitle: appState.factoryProfile.factoryName,
            icon: Icons.factory_outlined,
            color: AppColors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FactoryProfileScreen()),
              );
            },
          ),
          const SizedBox(height: 8),

          // Language Switcher Tile
          _settingsTile(
            title: loc.translate('language'),
            subtitle: appState.locale.languageCode == 'ta' ? 'தமிழ் (Tamil)' : 'English',
            icon: Icons.language,
            color: Colors.blue,
            trailing: Switch(
              value: appState.locale.languageCode == 'ta',
              onChanged: (_) => appState.toggleLanguage(),
            ),
            onTap: () => appState.toggleLanguage(),
          ),
          const SizedBox(height: 8),

          // Theme Mode Tile
          _settingsTile(
            title: loc.translate('theme'),
            subtitle: isDark ? loc.translate('themeDark') : loc.translate('themeLight'),
            icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            color: Colors.amber.shade800,
            trailing: Switch(
              value: isDark,
              onChanged: (val) {
                appState.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
              },
            ),
            onTap: () {
              appState.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
          const SizedBox(height: 8),

          // Audit Log Trail
          _settingsTile(
            title: loc.translate('auditLog'),
            subtitle: '${dataProvider.auditLogs.length} traceable factory operations',
            icon: Icons.history,
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuditLogScreen()),
              );
            },
          ),
          const SizedBox(height: 8),

          // Setup Wizard Re-run
          _settingsTile(
            title: 'Setup Wizard',
            subtitle: 'Re-run initial factory configuration steps',
            icon: Icons.auto_fix_high,
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SetupWizardScreen()),
              );
            },
          ),
          const SizedBox(height: 16),

          // Data Management Section
          const Text('Data & Offline Caching',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),

          CustomCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Cloud Sync Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    StatBadge(
                      label: 'Offline-First (Active)',
                      color: AppColors.success,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Local SQLite engine active. Data persists safely without internet connectivity.',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await dataProvider.seedRealisticFactoryData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🌿 Factory initialized: 4 juices, 5 raw materials, 1 active line!'),
                                backgroundColor: Color(0xFF10B981),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.dataset_outlined, size: 16),
                        label: const Text('Fresh Startup State', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                        onPressed: () async {
                          await dataProvider.resetAllData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Factory data reset to Day-1 baseline!'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.restore, size: 16),
                        label: const Text('Reset All Data', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const CloudUpdateCard(),
          const SizedBox(height: 20),

          // About App
          CustomCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JuiceFlow Factory Manager v${AppConstants.appVersion}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enterprise Food & Beverage Production Management System for Juice Manufacturing Plants.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sign Out Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.surfaceVariantDark : Colors.grey.shade200,
              foregroundColor: AppColors.error,
              elevation: 0,
            ),
            onPressed: () {
              appState.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, size: 18),
            label: Text(loc.translate('logout')),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}
