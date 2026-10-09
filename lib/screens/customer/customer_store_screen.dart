import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/factory_data_provider.dart';
import '../main_navigation_screen.dart';
import 'customer_checkout_screen.dart';
import 'customer_orders_screen.dart';

class CustomerStoreScreen extends StatefulWidget {
  final String customerName;
  final String customerPhone;
  final String customerAddress;

  const CustomerStoreScreen({
    super.key,
    this.customerName = 'Valued Customer',
    this.customerPhone = '9876543210',
    this.customerAddress = 'Shop #12, Market Road, Chennai',
  });

  @override
  State<CustomerStoreScreen> createState() => _CustomerStoreScreenState();
}

class _CustomerStoreScreenState extends State<CustomerStoreScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final Map<String, int> _cartQuantities = {}; // productId -> quantity

  final List<String> _categories = [
    'All',
    'Pure Juice',
    'Nectar',
    'Cold Pressed',
    'Seasonal Special',
  ];

  int get _totalCartItems =>
      _cartQuantities.values.fold(0, (sum, qty) => sum + qty);

  double _calculateSubtotal(List<Product> products) {
    double total = 0.0;
    for (var entry in _cartQuantities.entries) {
      if (entry.value > 0) {
        final p = products.firstWhere(
          (item) => item.id == entry.key,
          orElse: () => products.first,
        );
        total += p.sellingPrice * entry.value;
      }
    }
    return total;
  }

  void _updateQuantity(String productId, int delta) {
    setState(() {
      final current = _cartQuantities[productId] ?? 0;
      final updated = (current + delta).clamp(0, 999);
      if (updated <= 0) {
        _cartQuantities.remove(productId);
      } else {
        _cartQuantities[productId] = updated;
      }
    });
  }

  void _setBulkQuantity(String productId, int qty) {
    setState(() {
      if (qty <= 0) {
        _cartQuantities.remove(productId);
      } else {
        _cartQuantities[productId] = qty;
      }
    });
  }

  Color _getFruitColor(String fruit) {
    switch (fruit.toLowerCase()) {
      case 'mango':
        return const Color(0xFFF59E0B);
      case 'apple':
        return const Color(0xFFEF4444);
      case 'orange':
        return const Color(0xFFF97316);
      case 'pomegranate':
        return const Color(0xFFBE123C);
      case 'guava':
        return const Color(0xFF10B981);
      case 'pineapple':
        return const Color(0xFFEAB308);
      case 'lemon':
        return const Color(0xFF84CC16);
      default:
        return AppColors.primary;
    }
  }

  String _getFruitEmoji(String fruit) {
    switch (fruit.toLowerCase()) {
      case 'mango':
        return '🥭';
      case 'apple':
        return '🍎';
      case 'orange':
        return '🍊';
      case 'pomegranate':
        return '🫐';
      case 'guava':
        return '🍈';
      case 'pineapple':
        return '🍍';
      case 'lemon':
        return '🍋';
      default:
        return '🥤';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FactoryDataProvider>(context);
    final appState = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTa = appState.locale.languageCode == 'ta';

    // Filter products
    final filteredProducts = provider.products.where((p) {
      final matchesCat = _selectedCategory == 'All' ||
          p.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.tamilName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.fruit.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    final subtotal = _calculateSubtotal(provider.products);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_drink_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTa ? 'ஜூஸ்ப்ளோ ஃப்ரெஷ் ஷாப்' : 'JuiceFlow Fresh Store',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  isTa ? 'தொழிற்சாலை நேரடி விற்பனை' : 'Factory-Direct Pure Juices',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Language Switcher
          IconButton(
            tooltip: isTa ? 'Switch to English' : 'தமிழுக்கு மாறுக',
            icon: const Icon(Icons.language_rounded, size: 20),
            onPressed: () => appState.toggleLanguage(),
          ),
          // My Orders Button
          IconButton(
            tooltip: isTa ? 'என் ஆர்டர்கள்' : 'My Orders',
            icon: const Icon(Icons.receipt_long_rounded, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerOrdersScreen()),
              );
            },
          ),
          // Switch to Factory Manager
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) {
              if (val == 'factory') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                );
              } else if (val == 'orders') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerOrdersScreen()),
                );
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'factory',
                child: Row(
                  children: [
                    const Icon(Icons.factory_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Text(isTa ? 'தொழிற்சாலை மேலாண்மைக்கு மாறு' : 'Switch to Factory Portal'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'orders',
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded, color: Colors.blue, size: 20),
                    const SizedBox(width: 10),
                    Text(isTa ? 'கடந்த பில்கள் & ஆர்டர்கள்' : 'Past Bills & Invoices'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Customer Welcome & Factory Direct Freshness Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🌿', style: TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTa
                            ? 'வணக்கம், ${widget.customerName}!'
                            : 'Welcome, ${widget.customerName}!',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isTa
                            ? '100% தூய பழச்சாறு • வேதியியல் சேர்க்கை இல்லை • தானியங்கி பில்'
                            : '100% Cold-Pressed • Instant Auto-Billing • Live Tracking',
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

          // 2. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: isTa ? 'சாறு வகை / பழத்தை தேடுக...' : 'Search fresh juices, fruits...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),

          // 3. Category Horizontal Pills
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          // 4. Products List
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          isTa ? 'பழச்சாறுகள் எதுவும் கிடைக்கவில்லை' : 'No juices found',
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, idx) {
                      final product = filteredProducts[idx];
                      final qty = _cartQuantities[product.id] ?? 0;
                      final fruitColor = _getFruitColor(product.fruit);
                      final fruitEmoji = _getFruitEmoji(product.fruit);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: qty > 0
                                ? AppColors.primary
                                : (isDark ? Colors.white12 : Colors.black12),
                            width: qty > 0 ? 1.5 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: qty > 0
                                  ? AppColors.primary.withOpacity(0.12)
                                  : Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Avatar / Fruit Emblem
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      color: fruitColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: fruitColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        fruitEmoji,
                                        style: const TextStyle(fontSize: 30),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Product Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                isTa ? product.tamilName : product.name,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: fruitColor.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                product.bottleSize,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: fruitColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (isTa)
                                          Text(
                                            product.name,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? Colors.white60 : Colors.black54,
                                            ),
                                          ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.verified_rounded,
                                                size: 14, color: Color(0xFF10B981)),
                                            const SizedBox(width: 4),
                                            Text(
                                              isTa ? 'இன்று தயாரிக்கப்பட்டது' : 'Fresh Batch • Cold Pressed',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF10B981),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 10),

                              // Bottom Row: Price & Quantity Controls
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Price
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '₹${product.sellingPrice.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900,
                                          color: isDark ? Colors.white : AppColors.primary,
                                        ),
                                      ),
                                      Text(
                                        isTa ? 'பாட்டில் ஒன்றுக்கு' : 'per bottle (incl. GST)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? Colors.white54 : Colors.black45,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Stepper / Add Button
                                  qty == 0
                                      ? ElevatedButton.icon(
                                          onPressed: () => _updateQuantity(product.id, 1),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                          ),
                                          icon: const Icon(Icons.add_shopping_cart, size: 16),
                                          label: Text(
                                            isTa ? 'சேர் (+)' : 'ADD TO BILL',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        )
                                      : Row(
                                          children: [
                                            // Bulk crate quick popup
                                            PopupMenuButton<int>(
                                              icon: const Icon(Icons.view_module_rounded, size: 20),
                                              tooltip: isTa ? 'மொத்த ஆர்டர் (பெட்டி)' : 'Bulk Carton/Crate',
                                              onSelected: (val) => _setBulkQuantity(product.id, val),
                                              itemBuilder: (_) => [
                                                const PopupMenuItem(value: 6, child: Text('📦 6-Bottle Pack')),
                                                const PopupMenuItem(value: 12, child: Text('📦 12-Bottle Crate')),
                                                const PopupMenuItem(value: 24, child: Text('🏭 24-Bottle Carton')),
                                              ],
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? AppColors.surfaceVariantDark
                                                    : const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                                              ),
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    visualDensity: VisualDensity.compact,
                                                    icon: const Icon(Icons.remove, size: 18),
                                                    onPressed: () => _updateQuantity(product.id, -1),
                                                  ),
                                                  Container(
                                                    constraints: const BoxConstraints(minWidth: 28),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      '$qty',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    visualDensity: VisualDensity.compact,
                                                    icon: const Icon(Icons.add, size: 18),
                                                    onPressed: () => _updateQuantity(product.id, 1),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // 5. Persistent Floating Bottom Cart & Bill Bar
      bottomSheet: _totalCartItems > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Total info
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_totalCartItems ${isTa ? 'பாட்டில்கள்' : 'Bottle(s)'}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        Text(
                          '₹${subtotal.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Checkout & Generate Bill Button
                    ElevatedButton.icon(
                      onPressed: () {
                        // Gather cart items
                        final selectedItems = <Product, int>{};
                        for (var entry in _cartQuantities.entries) {
                          if (entry.value > 0) {
                            final prod = provider.products.firstWhere(
                              (p) => p.id == entry.key,
                            );
                            selectedItems[prod] = entry.value;
                          }
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomerCheckoutScreen(
                              selectedItems: selectedItems,
                              customerName: widget.customerName,
                              customerPhone: widget.customerPhone,
                              customerAddress: widget.customerAddress,
                              onOrderPlaced: () {
                                setState(() {
                                  _cartQuantities.clear();
                                });
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.receipt_rounded, size: 20),
                      label: Text(
                        isTa ? 'பில் & ஆர்டர் செய்க' : 'GENERATE BILL & PAY',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
