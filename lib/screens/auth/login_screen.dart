import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../customer/customer_store_screen.dart';
import '../main_navigation_screen.dart';
import '../setup/setup_wizard_screen.dart';
import '../cloud/cloud_backend_screen.dart';
import '../../core/services/supabase_service.dart';
import '../../widgets/juiceflow_brand_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Producer state
  final TextEditingController _emailController =
      TextEditingController(text: 'admin@juiceflow.com');
  final TextEditingController _passwordController =
      TextEditingController(text: 'factory@2026');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  String _selectedRole = AppConstants.roleAdmin;

  // Customer state
  final TextEditingController _custNameController =
      TextEditingController(text: 'Karthik Raja');
  final TextEditingController _custPhoneController =
      TextEditingController(text: '9842155678');
  final TextEditingController _custAddressController =
      TextEditingController(text: 'Fresh Fruit Juice Bar, Anna Nagar, Madurai');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _custNameController.dispose();
    _custPhoneController.dispose();
    _custAddressController.dispose();
    super.dispose();
  }

  Future<void> _handleProducerLogin() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Verify staff credentials with Cloud Server / Local SQLite
    final staffAuth = await SupabaseService.instance.loginStaff(
      email: email,
      password: password,
    );

    String userName = 'Factory User';
    String role = _selectedRole;

    if (staffAuth != null) {
      userName = staffAuth['name']?.toString() ?? userName;
      role = staffAuth['role']?.toString() ?? role;
      final isCloud = staffAuth['isCloudAuth'] == true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCloud
                  ? '🟢 Cloud Authenticated: $userName ($role)'
                  : '🟡 Local Factory Sign-in: $userName ($role)',
            ),
            backgroundColor: isCloud ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      if (_selectedRole == AppConstants.roleAdmin) {
        userName = 'Ramasamy Kumar (Owner)';
      } else if (_selectedRole == AppConstants.roleManager) {
        userName = 'Suresh Pandian (Manager)';
      } else if (_selectedRole == AppConstants.roleProduction) {
        userName = 'Murugan (Production Head)';
      } else if (_selectedRole == AppConstants.roleInventory) {
        userName = 'Muthu Vel (Inventory)';
      } else if (_selectedRole == AppConstants.roleSales) {
        userName = 'Vignesh (Sales)';
      }
    }

    appState.login(userName, role);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  void _handleCustomerEnter() {
    final name = _custNameController.text.trim().isNotEmpty
        ? _custNameController.text.trim()
        : 'Fresh Juice Customer';
    final phone = _custPhoneController.text.trim().isNotEmpty
        ? _custPhoneController.text.trim()
        : '9876543210';
    final address = _custAddressController.text.trim().isNotEmpty
        ? _custAddressController.text.trim()
        : 'Local Delivery / Dine-in';

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CustomerStoreScreen(
          customerName: name,
          customerPhone: phone,
          customerAddress: address,
        ),
      ),
    );
  }

  Future<void> _testPhoneNotification() async {
    await NotificationService.instance.sendTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔔 Notification sent! Check your phone notification tray.'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final appState = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTa = appState.locale.languageCode == 'ta';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Language Switcher
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => appState.toggleLanguage(),
                      icon: const Icon(Icons.language, size: 16),
                      label: Text(
                        isTa ? 'English' : 'தமிழ்',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Cloud Backend Status Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(
                          color: SupabaseService.instance.isConnected
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CloudBackendScreen()),
                        );
                        setState(() {});
                      },
                      icon: Icon(
                        SupabaseService.instance.isConnected
                            ? Icons.cloud_done
                            : Icons.cloud_off_outlined,
                        size: 15,
                        color: SupabaseService.instance.isConnected
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                      label: Text(
                        SupabaseService.instance.isConnected ? 'Cloud 🟢' : 'Cloud 🟡',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: SupabaseService.instance.isConnected
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                    ),

                    // Theme Switcher
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      ),
                      onPressed: () {
                        appState.setThemeMode(
                          isDark ? ThemeMode.light : ThemeMode.dark,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                const Center(
                  child: JuiceflowBrandHeader(
                    logoSize: 84,
                    showTagline: false,
                  ),
                ),
                const SizedBox(height: 2),
                Center(
                  child: Text(
                    isTa
                      ? 'தயாரிப்பாளர் & வாடிக்கையாளர் நுழைவு தளம்'
                      : 'Dual Portal: Factory Producer & Retail Customer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Dual Role Tab Bar (Producer vs Customer)
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.factory_rounded, size: 18),
                        text: isTa ? 'தயாரிப்பாளர் (Producer)' : 'Factory (Producer)',
                      ),
                      Tab(
                        icon: const Icon(Icons.shopping_bag_rounded, size: 18),
                        text: isTa ? 'வாடிக்கையாளர் (Customer)' : 'Customer (Store)',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tab Content
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    return _tabController.index == 0
                        ? _buildProducerForm(isDark, loc, isTa)
                        : _buildCustomerForm(isDark, isTa);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 1. PRODUCER / FACTORY MANAGEMENT FORM ---
  Widget _buildProducerForm(bool isDark, AppLocalizations loc, bool isTa) {
    final supabase = SupabaseService.instance;
    final isCloudConnected = supabase.isConnected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cloud Server Status Indicator Card
        InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CloudBackendScreen()),
            );
            setState(() {});
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isCloudConnected
                  ? const Color(0xFF10B981).withOpacity(0.12)
                  : const Color(0xFFF59E0B).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCloudConnected
                    ? const Color(0xFF10B981).withOpacity(0.4)
                    : const Color(0xFFF59E0B).withOpacity(0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isCloudConnected ? Icons.cloud_done : Icons.cloud_queue,
                      size: 18,
                      color: isCloudConnected
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCloudConnected
                          ? 'Cloud Server: Live Connected 🟢'
                          : 'Cloud Server: Offline SQLite 🟡',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCloudConnected
                            ? (isDark ? const Color(0xFF34D399) : const Color(0xFF065F46))
                            : (isDark ? const Color(0xFFFBBF24) : const Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Manage ⚙️',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.amber[200] : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Role Selector Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedRole,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
              items: [
                DropdownMenuItem(
                  value: AppConstants.roleAdmin,
                  child: Text('👑 ${loc.translate('roleAdmin')}'),
                ),
                DropdownMenuItem(
                  value: AppConstants.roleManager,
                  child: Text('👔 ${loc.translate('roleManager')}'),
                ),
                DropdownMenuItem(
                  value: AppConstants.roleProduction,
                  child: Text('🏭 ${loc.translate('roleProduction')}'),
                ),
                DropdownMenuItem(
                  value: AppConstants.roleInventory,
                  child: Text('📦 ${loc.translate('roleInventory')}'),
                ),
                DropdownMenuItem(
                  value: AppConstants.roleSales,
                  child: Text('💼 ${loc.translate('roleSales')}'),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedRole = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Email Input
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Factory Email / Staff ID',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 12),

        // Password Input
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Remember Me & Forgot
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => _rememberMe = val ?? true);
                  },
                ),
                Text(
                  'Remember credentials',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Forgot?', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Sign In Button
        ElevatedButton(
          onPressed: _handleProducerLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            isTa ? 'தொழிற்சாலை மேலாண்மைக்குள் நுழைக' : 'SIGN IN TO FACTORY ERP',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),

        // Quick Demo Role Buttons
        Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            _demoRoleChip('👑 Owner', AppConstants.roleAdmin, 'admin@juiceflow.com'),
            _demoRoleChip('👔 Manager', AppConstants.roleManager, 'manager@juiceflow.com'),
            _demoRoleChip('💼 Sales', AppConstants.roleSales, 'sales@juiceflow.com'),
            _demoRoleChip('🏭 Production', AppConstants.roleProduction, 'production@juiceflow.com'),
            _demoRoleChip('📦 Inventory', AppConstants.roleInventory, 'inventory@juiceflow.com'),
          ],
        ),
        const SizedBox(height: 14),

        // Setup Wizard & Notification Test Row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SetupWizardScreen()),
                  );
                },
                icon: const Icon(Icons.auto_fix_high, size: 14),
                label: Text(
                  isTa ? 'அமைவு விஸார்ட்' : 'Setup Wizard',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _testPhoneNotification,
                icon: const Icon(Icons.notifications_active_outlined, size: 14, color: AppColors.primary),
                label: Text(
                  isTa ? 'அலர்ட் டெஸ்ட்' : 'Test Alert',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _demoRoleChip(String label, String role, String email) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      onPressed: () {
        setState(() {
          _selectedRole = role;
          _emailController.text = email;
          _passwordController.text = 'factory@2026';
        });
        _handleProducerLogin();
      },
    );
  }

  // --- 2. CUSTOMER / JUICE STORE FORM ---
  Widget _buildCustomerForm(bool isDark, bool isTa) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fresh Store Intro Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Text('🥭', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTa ? 'நேரடி தொழிற்சாலை பழச்சாறுகள்' : 'Direct Fresh Juice Store',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    Text(
                      isTa
                          ? 'சாறு வகை மற்றும் அளவை (Quantity) தேர்ந்தெடுத்து உடனடி பில் பெறலாம்'
                          : 'Select juice type & quantity, get auto-calculated bills & live delivery!',
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

        // Customer Name
        TextField(
          controller: _custNameController,
          decoration: InputDecoration(
            labelText: isTa ? 'வாடிக்கையாளர் பெயர்' : 'Your Name / Outlet Name',
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 12),

        // Customer Mobile Number
        TextField(
          controller: _custPhoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: isTa ? 'மொபைல் எண் (WhatsApp பில் பெற)' : 'Mobile Number (for WhatsApp Bill & Notifications)',
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 12),

        // Customer Delivery Address
        TextField(
          controller: _custAddressController,
          decoration: InputDecoration(
            labelText: isTa ? 'டெலிவரி முகவரி / கடை' : 'Delivery Address / Table / Outlet',
            prefixIcon: const Icon(Icons.location_on_outlined),
          ),
        ),
        const SizedBox(height: 20),

        // Enter Store Button
        ElevatedButton.icon(
          onPressed: _handleCustomerEnter,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 3,
          ),
          icon: const Icon(Icons.local_drink_rounded, size: 20),
          label: Text(
            isTa ? 'பழச்சாறுகள் மெனு & ஆர்டர் செய்ய நுழைக' : 'BROWSE MENU & ORDER JUICES',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ),
        const SizedBox(height: 12),

        // Guest 1-Tap Access
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const CustomerStoreScreen(
                  customerName: 'Guest Customer',
                  customerPhone: '9800000000',
                  customerAddress: 'Takeaway / Dine-in',
                ),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
          label: Text(
            isTa ? 'விருந்தினராக நேரடியாக பார்க்க (Guest Mode)' : 'Explore Store as Guest',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
