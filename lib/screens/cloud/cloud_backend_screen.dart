import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/factory_data_provider.dart';

class CloudBackendScreen extends StatefulWidget {
  const CloudBackendScreen({super.key});

  @override
  State<CloudBackendScreen> createState() => _CloudBackendScreenState();
}

class _CloudBackendScreenState extends State<CloudBackendScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();

  bool _isTesting = false;
  bool _isSaving = false;
  bool _isSyncing = false;
  String? _statusFeedback;
  bool _feedbackIsError = false;

  @override
  void initState() {
    super.initState();
    final supabase = SupabaseService.instance;
    _urlController.text = supabase.savedUrl ?? '';
    _keyController.text = supabase.savedAnonKey ?? '';
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _statusFeedback = null;
    });

    final result = await SupabaseService.instance.testConnection(
      _urlController.text.trim(),
      _keyController.text.trim(),
    );

    setState(() {
      _isTesting = false;
      _feedbackIsError = result['success'] != true;
      _statusFeedback = result['message'] as String?;
    });
  }

  Future<void> _saveAndConnect() async {
    setState(() {
      _isSaving = true;
      _statusFeedback = null;
    });

    final success = await SupabaseService.instance.saveAndConnect(
      _urlController.text.trim(),
      _keyController.text.trim(),
    );

    setState(() {
      _isSaving = false;
      _feedbackIsError = !success;
      if (success) {
        _statusFeedback = '🎉 Connected to Cloud Backend! All changes will now synchronize.';
      } else {
        _statusFeedback = SupabaseService.instance.lastError ?? 'Failed to connect. Check URL and Key.';
      }
    });
  }

  Future<void> _disconnect() async {
    await SupabaseService.instance.disconnect();
    setState(() {
      _urlController.clear();
      _keyController.clear();
      _statusFeedback = 'Switched to Offline-First Local Mode (SQLite).';
      _feedbackIsError = false;
    });
  }

  Future<void> _pushLocalData() async {
    final provider = Provider.of<FactoryDataProvider>(context, listen: false);
    setState(() {
      _isSyncing = true;
      _statusFeedback = null;
    });

    final result = await SupabaseService.instance.pushAllLocalDataToCloud(provider);

    setState(() {
      _isSyncing = false;
      _feedbackIsError = result['success'] != true;
      if (result['success'] == true) {
        final counts = result['counts'] as Map<String, int>? ?? {};
        final itemsDesc = counts.entries.map((e) => '${e.value} ${e.key}').join(', ');
        _statusFeedback = '✅ Cloud Push Complete!\nUploaded: $itemsDesc';
      } else {
        _statusFeedback = result['message'] as String?;
      }
    });
  }

  Future<void> _pullCloudData() async {
    final provider = Provider.of<FactoryDataProvider>(context, listen: false);
    setState(() {
      _isSyncing = true;
      _statusFeedback = null;
    });

    final result = await SupabaseService.instance.pullAllCloudDataToLocal(provider);

    setState(() {
      _isSyncing = false;
      _feedbackIsError = result['success'] != true;
      if (result['success'] == true) {
        final counts = result['counts'] as Map<String, int>? ?? {};
        final itemsDesc = counts.entries.map((e) => '${e.value} ${e.key}').join(', ');
        _statusFeedback = '✅ Cloud Download Complete!\nSynchronized: $itemsDesc';
      } else {
        _statusFeedback = result['message'] as String?;
      }
    });
  }

  Future<void> _copySqlSchema() async {
    try {
      final schemaString = await rootBundle.loadString('database/schema.sql');
      await Clipboard.setData(ClipboardData(text: schemaString));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📋 Full PostgreSQL database schema copied to clipboard!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load schema: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final supabase = SupabaseService.instance;
    final isConnected = supabase.isConnected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Backend & Multi-Device Sync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Status',
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status Banner
            _buildStatusBanner(isConnected, isDark),
            const SizedBox(height: 16),

            // Feedback Message
            if (_statusFeedback != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _feedbackIsError
                      ? Colors.red.withOpacity(0.12)
                      : const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _feedbackIsError
                        ? Colors.redAccent.withOpacity(0.4)
                        : const Color(0xFF10B981).withOpacity(0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _feedbackIsError ? Icons.error_outline : Icons.check_circle_outline,
                      color: _feedbackIsError ? Colors.redAccent : const Color(0xFF10B981),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _statusFeedback!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _feedbackIsError
                              ? (isDark ? Colors.red[200] : Colors.red[800])
                              : (isDark ? Colors.teal[200] : Colors.teal[800]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Credentials Card
            _buildCredentialsCard(isDark, isConnected),
            const SizedBox(height: 16),

            // Live Sync Actions Card
            if (isConnected) ...[
              _buildSyncCard(isDark),
              const SizedBox(height: 16),
            ],

            // Staff Login Cheat-sheet
            _buildStaffCredentialsCard(isDark),
            const SizedBox(height: 16),

            // 3-Step Supabase Cloud Setup Guide
            _buildSetupGuideCard(isDark),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(bool isConnected, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConnected
            ? const Color(0xFF10B981).withOpacity(0.12)
            : const Color(0xFFF59E0B).withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected
              ? const Color(0xFF10B981).withOpacity(0.5)
              : const Color(0xFFF59E0B).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isConnected
                  ? const Color(0xFF10B981).withOpacity(0.2)
                  : const Color(0xFFF59E0B).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: isConnected ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected
                      ? '🟢 Live Cloud Backend Connected'
                      : '🟡 Offline-First Mode (Local SQLite)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isConnected
                        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF065F46))
                        : (isDark ? const Color(0xFFFBBF24) : const Color(0xFF92400E)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isConnected
                      ? 'Server: ${SupabaseService.instance.savedUrl ?? "Active"}\nAll phones & devices sync to PostgreSQL in real time.'
                      : 'The factory app operates fully offline on this device. Enter your Supabase credentials below to connect to the cloud.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsCard(bool isDark, bool isConnected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.settings_input_composite, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Supabase Server Configuration',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Supabase Project URL',
              hintText: 'https://xyzcompany.supabase.co',
              prefixIcon: Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _keyController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Supabase Anon Public API Key',
              hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
              prefixIcon: Icon(Icons.key),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isTesting ? null : _testConnection,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.network_ping, size: 18),
                  label: const Text('Test Ping'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isSaving ? null : _saveAndConnect,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.cloud_upload, size: 18),
                  label: const Text('Save & Connect'),
                ),
              ),
            ],
          ),
          if (isConnected) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _disconnect,
                icon: const Icon(Icons.power_settings_new, size: 16, color: Colors.redAccent),
                label: const Text(
                  'Disconnect & Revert to Offline Mode',
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncCard(bool isDark) {
    final lastSync = SupabaseService.instance.lastSyncTime;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.sync, color: Color(0xFF10B981), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Bi-Directional Cloud Synchronization',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (_isSyncing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            lastSync != null
                ? 'Last synchronized: ${lastSync.hour.toString().padLeft(2, '0')}:${lastSync.minute.toString().padLeft(2, '0')} on ${lastSync.day}/${lastSync.month}/${lastSync.year}'
                : 'No sync performed yet on this session.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _isSyncing ? null : _pushLocalData,
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: const Text('Push to Cloud ⬆️', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _isSyncing ? null : _pullCloudData,
                  icon: const Icon(Icons.cloud_download_outlined, size: 18),
                  label: const Text('Pull to Phone ⬇️', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCredentialsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.badge_outlined, color: Colors.blueAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Factory Staff Login Directory',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Password: factory@2026',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStaffRow('👑 Admin / Owner', 'Ramasamy Kumar', 'admin@juiceflow.com', isDark),
          const Divider(height: 12),
          _buildStaffRow('👔 Plant Manager', 'Suresh Pandian', 'manager@juiceflow.com', isDark),
          const Divider(height: 12),
          _buildStaffRow('💼 Sales Head', 'Vignesh', 'sales@juiceflow.com', isDark),
          const Divider(height: 12),
          _buildStaffRow('🏭 Production Head', 'Murugan', 'production@juiceflow.com', isDark),
          const Divider(height: 12),
          _buildStaffRow('📦 Inventory Staff', 'Muthu Vel', 'inventory@juiceflow.com', isDark),
        ],
      ),
    );
  }

  Widget _buildStaffRow(String role, String name, String email, bool isDark) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: email));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied $email to clipboard!'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  email,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.primary),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.copy, size: 14, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupGuideCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.terminal, color: Colors.purpleAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Instant Cloud Setup Guide',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: _copySqlSchema,
                icon: const Icon(Icons.copy, size: 14),
                label: const Text('Copy SQL Schema', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStepRow(
            '1',
            'Create Free Project on Supabase',
            'Go to supabase.com -> Sign in -> New Project (Name: JuiceFlow Factory).',
            isDark,
          ),
          const SizedBox(height: 8),
          _buildStepRow(
            '2',
            'Paste & Run SQL Migration',
            'Click "SQL Editor" -> Click "New query" -> Paste copied schema -> Click "Run". This creates all 16 tables, staff accounts, and RLS security policies.',
            isDark,
          ),
          const SizedBox(height: 8),
          _buildStepRow(
            '3',
            'Copy API Credentials to this Screen',
            'Go to Project Settings -> API. Copy "Project URL" and "anon public" API key into the fields above and tap "Save & Connect".',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(String number, String title, String description, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: Colors.purpleAccent.withOpacity(0.2),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.purpleAccent,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
