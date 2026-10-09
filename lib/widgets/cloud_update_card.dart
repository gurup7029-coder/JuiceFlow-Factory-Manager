import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/services/cloud_update_service.dart';
import '../core/theme/app_theme.dart';
import 'custom_card.dart';

class CloudUpdateCard extends StatefulWidget {
  const CloudUpdateCard({super.key});

  @override
  State<CloudUpdateCard> createState() => _CloudUpdateCardState();
}

class _CloudUpdateCardState extends State<CloudUpdateCard> {
  final _updateService = CloudUpdateService.instance;
  bool _isChecking = false;
  bool _isSyncing = false;
  String _syncMessage = '';

  Future<void> _checkUpdate() async {
    setState(() => _isChecking = true);
    final release = await _updateService.checkForUpdates();
    if (!mounted) return;
    setState(() => _isChecking = false);

    if (release != null) {
      _showUpdateDialog(release);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('App is up to date! Current build: v${AppConstants.appVersion}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
      _syncMessage = 'Syncing cloud data...';
    });
    final result = await _updateService.syncDynamicCloudData();
    if (!mounted) return;
    setState(() {
      _isSyncing = false;
      _syncMessage = result['message'] as String? ?? 'Cloud data synced!';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_syncMessage),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showUpdateDialog(CloudReleaseInfo release) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.cloud_download, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Update Available: v${release.version}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              release.releaseName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'What\'s New in this Over-The-Air release:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              release.releaseNotes,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withAlpha(80)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'No PC or USB cable needed! Updates download directly to your device.',
                      style: TextStyle(fontSize: 11, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _startDownload(release);
            },
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  void _startDownload(CloudReleaseInfo release) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading cloud update package in background...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    final filePath = await _updateService.downloadUpdate(release);
    if (!mounted) return;

    if (filePath != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success),
              SizedBox(width: 8),
              Text('Update Downloaded'),
            ],
          ),
          content: Text(
            'JuiceFlow v${release.version} is ready to install! Tap below to update in-place without PC connection.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Dismiss'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _updateService.installDownloadedApk(path: filePath);
              },
              icon: const Icon(Icons.install_mobile, size: 16),
              label: const Text('Install Now'),
            ),
          ],
        ),
      );
    }
  }

  void _showOtaArchitectureSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Row(
              children: [
                Icon(Icons.cloud_sync, color: AppColors.primary, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Cloud Live Updates & OTA Architecture',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildArchitectureTile(
              step: '1',
              title: 'Dynamic Data Sync (Active)',
              description:
                  'Changes to product prices, recipes, batch orders, inventory items, and factory alert thresholds sync immediately over Supabase without any app rebuild.',
              icon: Icons.sync,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildArchitectureTile(
              step: '2',
              title: 'GitHub Releases / Cloud In-App Updater (Active)',
              description:
                  'When code is pushed to your Git repository, our GitHub Actions / Release workflow builds the update. The app detects it and updates with 1 tap right on your device.',
              icon: Icons.system_update_alt,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildArchitectureTile(
              step: '3',
              title: 'Shorebird Code Push (Live Hot-Patching)',
              description:
                  'For instantaneous Dart code changes without reinstalling, Shorebird code push patches the app over-the-air in 30 seconds using command: shorebird patch android.',
              icon: Icons.bolt,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Understood'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchitectureTile({
    required String step,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color,
            foregroundColor: Colors.white,
            child: Icon(icon, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.cloud_sync, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Cloud Updates & Live Sync',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.help_outline, size: 18, color: Colors.grey),
                onPressed: _showOtaArchitectureSheet,
                tooltip: 'How Cloud Updating Works',
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Keep your installed app updated dynamically over-the-air without manual reinstallation.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withAlpha(60)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Installed Version: v${AppConstants.appVersion} • OTA Cloud Channel Active',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: _isChecking ? null : _checkUpdate,
                  icon: _isChecking
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.system_update_alt, size: 16),
                  label: Text(
                    _isChecking ? 'Checking...' : 'Check Cloud Updates',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: _isSyncing ? null : _syncData,
                  icon: _isSyncing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync, size: 16),
                  label: Text(
                    _isSyncing ? 'Syncing...' : 'Live Data Sync',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
