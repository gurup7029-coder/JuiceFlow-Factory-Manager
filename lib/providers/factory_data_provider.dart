import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../core/services/database_helper.dart';
import '../models/product.dart';
import '../models/raw_material.dart';
import '../models/production_batch.dart';
import '../models/quality_check.dart';
import '../models/stock_movement.dart';
import '../models/order.dart';
import '../models/customer.dart';
import '../models/supplier.dart';
import '../models/expense.dart';
import '../models/staff.dart';
import '../models/notification_item.dart';
import '../models/audit_log.dart';
import '../core/services/notification_service.dart';

class FactoryDataProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  bool _isLoading = true;
  List<Product> _products = [];
  List<RawMaterial> _rawMaterials = [];
  List<ProductionBatch> _batches = [];
  List<QualityCheck> _qualityChecks = [];
  List<StockMovement> _movements = [];
  List<SalesOrder> _orders = [];
  List<Customer> _customers = [];
  List<Supplier> _suppliers = [];
  List<Expense> _expenses = [];
  List<Staff> _staffList = [];
  List<NotificationItem> _notifications = [];
  List<AuditLog> _auditLogs = [];

  bool get isLoading => _isLoading;
  List<Product> get products => _products;
  List<RawMaterial> get rawMaterials => _rawMaterials;
  List<ProductionBatch> get batches => _batches;
  List<QualityCheck> get qualityChecks => _qualityChecks;
  List<StockMovement> get movements => _movements;
  List<SalesOrder> get orders => _orders;
  List<Customer> get customers => _customers;
  List<Supplier> get suppliers => _suppliers;
  List<Expense> get expenses => _expenses;
  List<Staff> get staffList => _staffList;
  List<NotificationItem> get notifications => _notifications;
  List<AuditLog> get auditLogs => _auditLogs;

  FactoryDataProvider() {
    loadAllData();
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await _dbHelper.database;

      final pMaps = await db.query('products');
      if (pMaps.isEmpty) {
        await seedRealisticFactoryData();
        return;
      }

      _products = pMaps.map((e) => Product.fromMap(e)).toList();

      final rmMaps = await db.query('raw_materials');
      _rawMaterials = rmMaps.map((e) => RawMaterial.fromMap(e)).toList();

      final bMaps = await db.query('production_batches', orderBy: 'production_date DESC');
      _batches = bMaps.map((e) => ProductionBatch.fromMap(e)).toList();

      final qMaps = await db.query('quality_checks', orderBy: 'check_date DESC');
      _qualityChecks = qMaps.map((e) => QualityCheck.fromMap(e)).toList();

      final smMaps = await db.query('stock_movements', orderBy: 'date DESC');
      _movements = smMaps.map((e) => StockMovement.fromMap(e)).toList();

      final oMaps = await db.query('sales_orders', orderBy: 'order_date DESC');
      _orders = oMaps.map((e) => SalesOrder.fromMap(e)).toList();

      final cMaps = await db.query('customers', orderBy: 'name ASC');
      _customers = cMaps.map((e) => Customer.fromMap(e)).toList();

      final sMaps = await db.query('suppliers', orderBy: 'name ASC');
      _suppliers = sMaps.map((e) => Supplier.fromMap(e)).toList();

      final eMaps = await db.query('expenses', orderBy: 'date DESC');
      _expenses = eMaps.map((e) => Expense.fromMap(e)).toList();

      final stMaps = await db.query('staff', orderBy: 'name ASC');
      _staffList = stMaps.map((e) => Staff.fromMap(e)).toList();

      final nMaps = await db.query('notifications', orderBy: 'created_at DESC');
      _notifications = nMaps.map((e) => NotificationItem.fromMap(e)).toList();

      final aMaps = await db.query('audit_logs', orderBy: 'timestamp DESC');
      _auditLogs = aMaps.map((e) => AuditLog.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error loading data from local SQLite: $e');
      // If error or empty, seed demo data
      await seedRealisticFactoryData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- SEED SAMPLE REALISTIC DATA ---
  Future<void> seedRealisticFactoryData() async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();

    // 1. Products (4 Flagship Flavors)
    _products = [
      Product(
        id: 'PRD-001',
        name: 'Alphonso Mango Juice (500ml)',
        tamilName: 'அல்போன்சா மாம்பழ சாறு (500மி.லி)',
        code: 'JF-MNG-500',
        category: 'Pure Juice',
        fruit: 'Mango',
        bottleSize: '500 ml',
        packagingType: 'PET Bottle',
        sellingPrice: 45.0,
        costPrice: 24.0,
        gstRate: 12.0,
        minStockLevel: 50,
        currentStock: 120,
      ),
      Product(
        id: 'PRD-002',
        name: 'Nagpur Orange Delight (500ml)',
        tamilName: 'நாக்பூர் ஆரஞ்சு பழச்சாறு (500மி.லி)',
        code: 'JF-ORG-500',
        category: 'Pure Juice',
        fruit: 'Orange',
        bottleSize: '500 ml',
        packagingType: 'PET Bottle',
        sellingPrice: 40.0,
        costPrice: 21.0,
        gstRate: 12.0,
        minStockLevel: 50,
        currentStock: 80,
      ),
      Product(
        id: 'PRD-003',
        name: 'Kinnaur Apple Nectar (1 Liter)',
        tamilName: 'ஆப்பிள் நெக்டார் (1 லிட்டர்)',
        code: 'JF-APL-1000',
        category: 'Nectar Blend',
        fruit: 'Apple',
        bottleSize: '1000 ml (1 Liter)',
        packagingType: 'PET Bottle',
        sellingPrice: 85.0,
        costPrice: 46.0,
        gstRate: 12.0,
        minStockLevel: 30,
        currentStock: 40,
      ),
      Product(
        id: 'PRD-004',
        name: 'Kerala Queen Pineapple Juice (500ml)',
        tamilName: 'அன்னாசி பழச்சாறு (500மி.லி)',
        code: 'JF-PNP-500',
        category: 'Pure Juice',
        fruit: 'Pineapple',
        bottleSize: '500 ml',
        packagingType: 'PET Bottle',
        sellingPrice: 42.0,
        costPrice: 22.0,
        gstRate: 12.0,
        minStockLevel: 40,
        currentStock: 25, // Low stock prompt
      ),
    ];

    // 2. Raw Materials (5 Essential Items)
    _rawMaterials = [
      RawMaterial(
        id: 'RM-001',
        name: 'Grade A Alphonso Mango Pulp',
        tamilName: 'மாம்பழ கூழ் (கிரேடு A)',
        category: 'Fruits',
        supplierId: 'SUP-001',
        supplierName: 'Dharmapuri Fruit Orchards',
        quantity: 500.0,
        unit: 'Kg',
        purchasePrice: 65.0,
        batchNumber: 'LOT-MNG-401',
        purchaseDate: now.subtract(const Duration(days: 2)),
        expiryDate: now.add(const Duration(days: 60)),
        minStockLevel: 150.0,
        storageLocation: 'Cold Storage Room A',
      ),
      RawMaterial(
        id: 'RM-002',
        name: 'Refined Pure Sugar (Food Grade)',
        tamilName: 'சுத்திகரிக்கப்பட்ட சர்க்கரை',
        category: 'Sweeteners & Sugar',
        supplierId: 'SUP-002',
        supplierName: 'Erode Agro Commodities',
        quantity: 400.0,
        unit: 'Kg',
        purchasePrice: 38.0,
        batchNumber: 'SGR-2026-01',
        purchaseDate: now.subtract(const Duration(days: 5)),
        expiryDate: now.add(const Duration(days: 365)),
        minStockLevel: 100.0,
        storageLocation: 'Dry Warehouse Bay 1',
      ),
      RawMaterial(
        id: 'RM-003',
        name: '500ml PET Juice Bottles',
        tamilName: '500மி.லி PET பாட்டில்கள்',
        category: 'Bottles (PET / Glass)',
        supplierId: 'SUP-002',
        supplierName: 'PolyPlast Packaging Industries',
        quantity: 1500.0,
        unit: 'Units / Pcs',
        purchasePrice: 3.20,
        batchNumber: 'PET-500-01',
        purchaseDate: now.subtract(const Duration(days: 3)),
        expiryDate: now.add(const Duration(days: 700)),
        minStockLevel: 500.0,
        storageLocation: 'Packaging Bay A',
      ),
      RawMaterial(
        id: 'RM-004',
        name: 'Tamper-Evident Green Screw Caps (28mm)',
        tamilName: 'பச்சை நிற பாட்டில் மூடிகள் (28mm)',
        category: 'Caps & Seals',
        supplierId: 'SUP-002',
        supplierName: 'PolyPlast Packaging Industries',
        quantity: 2000.0,
        unit: 'Units / Pcs',
        purchasePrice: 0.85,
        batchNumber: 'CAP-28-01',
        purchaseDate: now.subtract(const Duration(days: 3)),
        expiryDate: now.add(const Duration(days: 700)),
        minStockLevel: 600.0,
        storageLocation: 'Packaging Bay A',
      ),
      RawMaterial(
        id: 'RM-005',
        name: 'Self-Adhesive Alphonso Labels (Roll)',
        tamilName: 'மாம்பழ லேபிள் சுருள்கள்',
        category: 'Labels & Stickers',
        supplierId: 'SUP-002',
        supplierName: 'PolyPlast Packaging Industries',
        quantity: 1200.0,
        unit: 'Units / Pcs',
        purchasePrice: 1.10,
        batchNumber: 'LBL-MNG-01',
        purchaseDate: now.subtract(const Duration(days: 4)),
        expiryDate: now.add(const Duration(days: 365)),
        minStockLevel: 400.0,
        storageLocation: 'Label Room',
      ),
    ];

    // 3. Initial Active Batch (1 Starting Batch)
    _batches = [
      ProductionBatch(
        id: 'BAT-2026-001',
        batchNumber: 'BATCH-2026-MNG-101',
        productId: 'PRD-001',
        productName: 'Alphonso Mango Juice (500ml)',
        productionDate: now.subtract(const Duration(hours: 3)),
        plannedQty: 300.0,
        actualQty: 295.0,
        wastageQty: 5.0,
        unit: 'Liters',
        ingredientsSummary: 'Mango Pulp: 90kg, Sugar: 28kg, Treated Water: 180L, Citric: 0.8kg',
        assignedStaff: 'Murugan (Production)',
        startTime: now.subtract(const Duration(hours: 3)),
        endTime: now.subtract(const Duration(hours: 1)),
        status: AppConstants.batchStatusCompleted,
        qcStatus: AppConstants.qcStatusPassed,
        expiryDate: now.add(const Duration(days: 90)),
        notes: 'Initial plant calibration batch. Viscosity, Brix & pasteurization nominal.',
      ),
    ];

    // 4. Quality Checks
    _qualityChecks = [
      QualityCheck(
        id: 'QC-001',
        batchId: 'BAT-2026-001',
        batchNumber: 'BATCH-2026-MNG-101',
        appearance: 'Golden thick pulpy liquid, uniform suspension',
        colour: 'Rich deep mango golden yellow',
        taste: 'Sweet with authentic Alphonso fresh fruit flavor',
        smell: 'Intense ripe fruit aroma',
        phValue: 3.82,
        temperature: 4.2,
        brixSugar: 14.2,
        packagingCondition: 'Good seal, clean PET wall',
        sealCondition: 'Hermetic induction seal passed',
        remarks: 'Sample passed all lab quality standards.',
        inspectorName: 'Murugan (QC Officer)',
        checkDate: now.subtract(const Duration(hours: 1)),
        status: AppConstants.qcStatusPassed,
      ),
    ];

    // 5. Verified B2B Retail Customers (2 Accounts)
    _customers = [
      Customer(
        id: 'CUST-001',
        name: 'Sundar Supermarket',
        businessName: 'Sundar Retail Mart Pvt Ltd',
        phone: '+91 94432 11098',
        email: 'purchase@sundarmart.in',
        address: '14 Cross Road, Madurai - 625001',
        customerType: 'Supermarket',
        outstandingBalance: 4500.0,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Customer(
        id: 'CUST-002',
        name: 'Hotel Grand Residency',
        businessName: 'Grand Residency Hospitality',
        phone: '+91 98840 22334',
        email: 'fnb@grandresidency.com',
        address: 'Bypass Road, Dindigul - 624004',
        customerType: 'Hotel & Resort',
        outstandingBalance: 0.0,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];

    // 6. Registered Suppliers (2 Vendors)
    _suppliers = [
      Supplier(
        id: 'SUP-001',
        name: 'Dharmapuri Fruit Orchards',
        contactPerson: 'Venkatesh Farmer Producer Org',
        phone: '+91 94421 77654',
        email: 'dharmapuri.fruits@gmail.com',
        address: 'Orchard Valley, Dharmapuri - 636701',
        materialsSupplied: 'Alphonso Mango Pulp',
        outstandingAmount: 0.0,
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      Supplier(
        id: 'SUP-002',
        name: 'PolyPlast Packaging Industries',
        contactPerson: 'Mahesh Kumar',
        phone: '+91 97910 88992',
        email: 'sales@polyplastpack.com',
        address: 'SIDCO Estate, Coimbatore - 641021',
        materialsSupplied: 'PET Bottles, Caps, Labels',
        outstandingAmount: 0.0,
        createdAt: now.subtract(const Duration(days: 14)),
      ),
    ];

    // 7. Initial Customer Order (1 Sample Order)
    _orders = [
      SalesOrder(
        id: 'ORD-001',
        orderNumber: 'JF-ORD-2026-01',
        customerId: 'CUST-001',
        customerName: 'Sundar Supermarket',
        customerPhone: '+91 94432 11098',
        customerAddress: '14 Cross Road, Madurai',
        items: [
          OrderItem(
            productId: 'PRD-001',
            productName: 'Alphonso Mango Juice (500ml)',
            bottleSize: '500 ml',
            quantity: 60,
            unitPrice: 45.0,
          ),
        ],
        subtotal: 2700.0,
        discount: 0.0,
        taxAmount: 324.0,
        grandTotal: 3024.0,
        paidAmount: 3024.0,
        paymentStatus: AppConstants.paymentStatusPaid,
        deliveryStatus: AppConstants.orderStatusDelivered,
        orderDate: now.subtract(const Duration(hours: 4)),
        deliveryDate: now.subtract(const Duration(hours: 1)),
        notes: 'Delivered via plant dispatch.',
      ),
    ];

    // 8. Basic Operational Expenses
    _expenses = [
      Expense(
        id: 'EXP-001',
        title: 'Factory Electricity (TANGEDCO)',
        category: 'Electricity & Power',
        amount: 6500.0,
        date: now.subtract(const Duration(days: 1)),
        paymentMethod: 'UPI / Net Banking',
        description: 'Plant startup power connection and chiller testing.',
      ),
      Expense(
        id: 'EXP-002',
        title: 'RO Water Filtration & Lab Microbiological Test',
        category: 'Water Supply',
        amount: 1800.0,
        date: now.subtract(const Duration(days: 2)),
        paymentMethod: 'UPI',
        description: 'FSSAI certified water potability lab test certificate.',
      ),
    ];

    // 9. Clean Built-in Staff Accounts (5 Roles)
    _staffList = [
      Staff(
        id: 'STF-001',
        name: 'Ramasamy Kumar',
        employeeCode: 'EMP-ADM-01',
        role: AppConstants.roleAdmin,
        phone: '+91 98421 55678',
        email: 'admin@juiceflow.com',
        joiningDate: now.subtract(const Duration(days: 60)),
        department: 'Executive Management',
        batchesHandled: 1,
        ordersHandled: 1,
      ),
      Staff(
        id: 'STF-002',
        name: 'Suresh Pandian',
        employeeCode: 'EMP-MGR-02',
        role: AppConstants.roleManager,
        phone: '+91 97890 33441',
        email: 'manager@juiceflow.com',
        joiningDate: now.subtract(const Duration(days: 45)),
        department: 'Plant Operations',
        batchesHandled: 1,
        ordersHandled: 1,
      ),
      Staff(
        id: 'STF-003',
        name: 'Vignesh',
        employeeCode: 'EMP-SLS-03',
        role: AppConstants.roleSales,
        phone: '+91 98400 44556',
        email: 'sales@juiceflow.com',
        joiningDate: now.subtract(const Duration(days: 30)),
        department: 'Sales & Distribution',
        batchesHandled: 0,
        ordersHandled: 1,
      ),
      Staff(
        id: 'STF-004',
        name: 'Murugan',
        employeeCode: 'EMP-PRD-04',
        role: AppConstants.roleProduction,
        phone: '+91 96290 11223',
        email: 'production@juiceflow.com',
        joiningDate: now.subtract(const Duration(days: 30)),
        department: 'Juice Processing & Filling',
        batchesHandled: 1,
        ordersHandled: 0,
      ),
      Staff(
        id: 'STF-005',
        name: 'Muthu Vel',
        employeeCode: 'EMP-INV-05',
        role: AppConstants.roleInventory,
        phone: '+91 94860 99887',
        email: 'inventory@juiceflow.com',
        joiningDate: now.subtract(const Duration(days: 30)),
        department: 'Cold Stores & Raw Materials',
        batchesHandled: 0,
        ordersHandled: 1,
      ),
    ];

    // 10. Notifications
    _notifications = [
      NotificationItem(
        id: 'NOTIF-001',
        title: 'Factory Operations Ready',
        message: 'JuiceFlow plant ready: 4 juices, 5 raw materials, 1 active line.',
        type: 'system',
        priority: 'MEDIUM',
        createdAt: now.subtract(const Duration(minutes: 15)),
      ),
    ];

    // 11. Audit Logs
    _auditLogs = [
      AuditLog(
        id: 'AUD-001',
        userName: 'Ramasamy Kumar',
        userRole: 'admin',
        action: 'FACTORY_INIT',
        module: 'System',
        recordAffected: 'JuiceFlow Plant OS',
        details: 'Initialized fresh juice factory startup workspace.',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
    ];

    // Save all to SQLite
    await _persistAllSeedData();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persistAllSeedData() async {
    try {
      final db = await _dbHelper.database;
      await _dbHelper.clearAllData(); // Clear old data to prevent duplicate clutter!
      final batch = db.batch();

      for (var p in _products) {
        batch.insert('products', p.toMap());
      }
      for (var rm in _rawMaterials) {
        batch.insert('raw_materials', rm.toMap());
      }
      for (var b in _batches) {
        batch.insert('production_batches', b.toMap());
      }
      for (var q in _qualityChecks) {
        batch.insert('quality_checks', q.toMap());
      }
      for (var o in _orders) {
        batch.insert('sales_orders', o.toMap());
      }
      for (var c in _customers) {
        batch.insert('customers', c.toMap());
      }
      for (var s in _suppliers) {
        batch.insert('suppliers', s.toMap());
      }
      for (var e in _expenses) {
        batch.insert('expenses', e.toMap());
      }
      for (var st in _staffList) {
        batch.insert('staff', st.toMap());
      }
      for (var n in _notifications) {
        batch.insert('notifications', n.toMap());
      }
      for (var a in _auditLogs) {
        batch.insert('audit_logs', a.toMap());
      }

      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('Error persisting seed data: $e');
    }
  }

  // --- KPI CALCULATIONS FOR DASHBOARD ---
  double get todayProductionLiters {
    final today = DateTime.now();
    return _batches
        .where((b) =>
            b.productionDate.year == today.year &&
            b.productionDate.month == today.month &&
            b.productionDate.day == today.day)
        .fold(0.0, (sum, b) => sum + b.actualQty);
  }

  double get todaySalesAmount {
    final today = DateTime.now();
    return _orders
        .where((o) =>
            o.orderDate.year == today.year &&
            o.orderDate.month == today.month &&
            o.orderDate.day == today.day)
        .fold(0.0, (sum, o) => sum + o.grandTotal);
  }

  int get pendingOrdersCount => _orders
      .where((o) =>
          o.deliveryStatus != AppConstants.orderStatusDelivered &&
          o.deliveryStatus != AppConstants.orderStatusCancelled)
      .length;

  double get pendingPaymentsTotal =>
      _orders.fold(0.0, (sum, o) => sum + o.balanceAmount);

  int get activeBatchesCount => _batches
      .where((b) =>
          b.status == AppConstants.batchStatusInProgress ||
          b.status == AppConstants.batchStatusQualityCheck)
      .length;

  int get lowStockCount {
    int pLow = _products.where((p) => p.currentStock <= p.minStockLevel).length;
    int rmLow = _rawMaterials.where((m) => m.isLowStock).length;
    return pLow + rmLow;
  }

  double get averageProductionEfficiency {
    final completed =
        _batches.where((b) => b.status == AppConstants.batchStatusCompleted).toList();
    if (completed.isEmpty) return 96.5;
    final total = completed.fold(0.0, (sum, b) => sum + b.efficiency);
    return total / completed.length;
  }

  double get averageWastageRate {
    final completed =
        _batches.where((b) => b.status == AppConstants.batchStatusCompleted).toList();
    if (completed.isEmpty) return 2.8;
    final total = completed.fold(0.0, (sum, b) => sum + b.wastagePercent);
    return total / completed.length;
  }

  double get monthlyRevenueTotal {
    final now = DateTime.now();
    return _orders
        .where((o) => o.orderDate.month == now.month && o.orderDate.year == now.year)
        .fold(0.0, (sum, o) => sum + o.grandTotal);
  }

  double get todayExpensesTotal {
    final today = DateTime.now();
    return _expenses
        .where((e) =>
            e.date.year == today.year &&
            e.date.month == today.month &&
            e.date.day == today.day)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // --- ACTIONS & AUDITING ---

  Future<void> addAuditLog({
    required String userName,
    required String userRole,
    required String action,
    required String module,
    required String recordAffected,
    required String details,
  }) async {
    final log = AuditLog(
      id: _uuid.v4(),
      userName: userName,
      userRole: userRole,
      action: action,
      module: module,
      recordAffected: recordAffected,
      details: details,
      timestamp: DateTime.now(),
    );
    _auditLogs.insert(0, log);
    notifyListeners();
    try {
      final db = await _dbHelper.database;
      await db.insert('audit_logs', log.toMap());
    } catch (_) {}
  }

  // Product Actions
  Future<void> addProduct(Product product, String userName, String role) async {
    _products.add(product);
    notifyListeners();
    final db = await _dbHelper.database;
    await db.insert('products', product.toMap());
    await addAuditLog(
      userName: userName,
      userRole: role,
      action: 'CREATE',
      module: 'Products',
      recordAffected: product.name,
      details: 'Added product ${product.code} at selling price ₹${product.sellingPrice}',
    );
  }

  Future<void> updateProduct(Product product, String userName, String role) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
      final db = await _dbHelper.database;
      await db.update('products', product.toMap(), where: 'id = ?', whereArgs: [product.id]);
      await addAuditLog(
        userName: userName,
        userRole: role,
        action: 'UPDATE',
        module: 'Products',
        recordAffected: product.name,
        details: 'Updated details/stock for ${product.name}',
      );
    }
  }

  Future<void> deleteProduct(String id, String userName, String role) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final p = _products[index];
      _products.removeAt(index);
      notifyListeners();
      final db = await _dbHelper.database;
      await db.delete('products', where: 'id = ?', whereArgs: [id]);
      await addAuditLog(
        userName: userName,
        userRole: role,
        action: 'DELETE',
        module: 'Products',
        recordAffected: p.name,
        details: 'Deleted product ${p.code}',
      );
    }
  }

  // Raw Material Actions
  Future<void> addRawMaterial(RawMaterial material, String userName, String role) async {
    _rawMaterials.add(material);
    notifyListeners();
    final db = await _dbHelper.database;
    await db.insert('raw_materials', material.toMap());
    await addAuditLog(
      userName: userName,
      userRole: role,
      action: 'CREATE',
      module: 'Inventory',
      recordAffected: material.name,
      details: 'Added raw material: ${material.quantity} ${material.unit}',
    );
  }

  Future<void> updateRawMaterialStock(
      String materialId, double newQty, String userName, String role, String reason) async {
    final index = _rawMaterials.indexWhere((m) => m.id == materialId);
    if (index != -1) {
      final old = _rawMaterials[index];
      final updated = old.copyWith(quantity: newQty);
      _rawMaterials[index] = updated;
      notifyListeners();
      final db = await _dbHelper.database;
      await db.update('raw_materials', updated.toMap(), where: 'id = ?', whereArgs: [materialId]);
      await addAuditLog(
        userName: userName,
        userRole: role,
        action: 'STOCK_ADJUST',
        module: 'Inventory',
        recordAffected: old.name,
        details: 'Stock adjusted from ${old.quantity} to $newQty ${old.unit}. Reason: $reason',
      );
    }
  }

  // Production Batch Actions
  Future<void> createBatch(ProductionBatch batch, String userName, String role) async {
    _batches.insert(0, batch);
    notifyListeners();
    final db = await _dbHelper.database;
    await db.insert('production_batches', batch.toMap());
    await addAuditLog(
      userName: userName,
      userRole: role,
      action: 'BATCH_CREATE',
      module: 'Production',
      recordAffected: batch.batchNumber,
      details: 'Created batch for ${batch.productName} (Planned: ${batch.plannedQty} ${batch.unit})',
    );
  }

  Future<void> updateBatchStatus(
    String batchId,
    String status, {
    double? actualQty,
    double? wastageQty,
    String? qcStatus,
    required String userName,
    required String role,
  }) async {
    final index = _batches.indexWhere((b) => b.id == batchId);
    if (index != -1) {
      final old = _batches[index];
      final updated = old.copyWith(
        status: status,
        actualQty: actualQty ?? old.actualQty,
        wastageQty: wastageQty ?? old.wastageQty,
        qcStatus: qcStatus ?? old.qcStatus,
        endTime: status == AppConstants.batchStatusCompleted ? DateTime.now() : old.endTime,
      );
      _batches[index] = updated;

      // When batch is marked completed, automatically increment finished product stock!
      if (status == AppConstants.batchStatusCompleted && old.status != AppConstants.batchStatusCompleted) {
        final pIndex = _products.indexWhere((p) => p.id == updated.productId);
        if (pIndex != -1) {
          // If 500ml bottles, 1 Liter = 2 bottles approx
          final bottleCount = (updated.actualQty * (updated.productName.contains('500ml') ? 2 : 1)).toInt();
          final updatedProduct = _products[pIndex].copyWith(
            currentStock: _products[pIndex].currentStock + bottleCount,
          );
          _products[pIndex] = updatedProduct;
          final db = await _dbHelper.database;
          await db.update('products', updatedProduct.toMap(), where: 'id = ?', whereArgs: [updatedProduct.id]);
        }
      }

      notifyListeners();
      final db = await _dbHelper.database;
      await db.update('production_batches', updated.toMap(), where: 'id = ?', whereArgs: [batchId]);
      await addAuditLog(
        userName: userName,
        userRole: role,
        action: 'BATCH_UPDATE',
        module: 'Production',
        recordAffected: updated.batchNumber,
        details: 'Batch status moved to $status. Actual output: ${updated.actualQty} ${updated.unit}',
      );
    }
  }

  // Quality Control Action
  Future<void> submitQualityCheck(QualityCheck qc, String userName, String role) async {
    _qualityChecks.insert(0, qc);
    // Update batch QC status
    final bIndex = _batches.indexWhere((b) => b.id == qc.batchId);
    if (bIndex != -1) {
      final b = _batches[bIndex];
      final updatedBatch = b.copyWith(
        qcStatus: qc.status,
        status: qc.status == AppConstants.qcStatusPassed
            ? AppConstants.batchStatusCompleted
            : (qc.status == AppConstants.qcStatusFailed
                ? AppConstants.batchStatusRejected
                : AppConstants.batchStatusQualityCheck),
      );
      _batches[bIndex] = updatedBatch;
      final db = await _dbHelper.database;
      await db.update('production_batches', updatedBatch.toMap(), where: 'id = ?', whereArgs: [b.id]);
    }

    notifyListeners();
    final db = await _dbHelper.database;
    await db.insert('quality_checks', qc.toMap());
    await addAuditLog(
      userName: userName,
      userRole: role,
      action: 'QC_${qc.status.toUpperCase()}',
      module: 'Quality Control',
      recordAffected: qc.batchNumber,
      details: 'QC Result: ${qc.status} by ${qc.inspectorName}. Brix: ${qc.brixSugar}°Bx, pH: ${qc.phValue}',
    );
  }

  // Orders Actions
  Future<void> createOrder(SalesOrder order, String userName, String role) async {
    _orders.insert(0, order);
    // Auto deduct finished goods stock
    for (var item in order.items) {
      final pIndex = _products.indexWhere((p) => p.id == item.productId);
      if (pIndex != -1) {
        final current = _products[pIndex].currentStock;
        final newStock = (current - item.quantity).clamp(0, 999999);
        final updatedP = _products[pIndex].copyWith(currentStock: newStock);
        _products[pIndex] = updatedP;
        final db = await _dbHelper.database;
        await db.update('products', updatedP.toMap(), where: 'id = ?', whereArgs: [updatedP.id]);
      }
    }

    // Add In-App notification
    final notif = NotificationItem(
      id: _uuid.v4(),
      title: '🎉 New Order #${order.orderNumber}',
      message: '${order.customerName} ordered ${order.items.length} items totaling ₹${order.grandTotal.toStringAsFixed(0)}',
      type: 'pending_order',
      priority: 'HIGH',
      createdAt: DateTime.now(),
    );
    _notifications.insert(0, notif);

    notifyListeners();
    final db = await _dbHelper.database;
    await db.insert('sales_orders', order.toMap());
    await db.insert('notifications', notif.toMap());

    // Trigger Real Native Android Notifications
    await NotificationService.instance.showOrderConfirmedNotification(
      orderNumber: order.orderNumber,
      grandTotal: order.grandTotal,
      itemCount: order.items.fold<int>(0, (sum, i) => sum + i.quantity),
      paymentMode: order.paymentStatus == 'Paid' ? 'Online / UPI' : 'COD',
    );

    final summary = order.items.map((i) => '${i.quantity}x ${i.productName}').join(', ');
    await NotificationService.instance.showNewOrderForFactoryNotification(
      orderNumber: order.orderNumber,
      customerName: order.customerName,
      grandTotal: order.grandTotal,
      itemsSummary: summary,
    );

    await addAuditLog(
      userName: userName,
      userRole: role,
      action: 'CREATE_ORDER',
      module: 'Orders',
      recordAffected: order.orderNumber,
      details: 'Order created for ${order.customerName} for total ₹${order.grandTotal}',
    );
  }

  Future<void> addNotification(NotificationItem item) async {
    _notifications.insert(0, item);
    notifyListeners();
    final db = await _dbHelper.database;
    await db.insert('notifications', item.toMap());
    await NotificationService.instance.showFactoryAlert(
      title: item.title,
      message: item.message,
    );
  }

  Future<void> updateOrderStatus(
    String orderId,
    String deliveryStatus,
    String paymentStatus,
    double paidAmount,
    String userName,
    String role,
  ) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final old = _orders[index];
      final updated = old.copyWith(
        deliveryStatus: deliveryStatus,
        paymentStatus: paymentStatus,
        paidAmount: paidAmount,
      );
      _orders[index] = updated;
      notifyListeners();
      final db = await _dbHelper.database;
      await db.update('sales_orders', updated.toMap(), where: 'id = ?', whereArgs: [orderId]);
      await addAuditLog(
        userName: userName,
        userRole: role,
        action: 'ORDER_UPDATE',
        module: 'Orders',
        recordAffected: updated.orderNumber,
        details: 'Status changed to $deliveryStatus, Payment: $paymentStatus (Paid: ₹$paidAmount)',
      );
    }
  }

  // Customers & Suppliers Actions
  Future<void> addCustomer(Customer customer, String userName, String role) async {
    _customers.add(customer);
    notifyListeners();
    final db = await _dbHelper.database;
    await db.insert('customers', customer.toMap());
    await addAuditLog(
      userName: userName,
      userRole: role,
      action: 'CREATE',
      module: 'Customers',
      recordAffected: customer.name,
      details: 'Registered customer: ${customer.businessName}',
    );
  }

  Future<void> addSupplier(Supplier supplier, String userName, String role) async {
    _suppliers.add(supplier);
    notifyListeners();
    final db = await _dbHelper.database;
    await db.insert('suppliers', supplier.toMap());
    await addAuditLog(
      userName: userName,
      userRole: role,
      action: 'CREATE',
      module: 'Suppliers',
      recordAffected: supplier.name,
      details: 'Registered supplier for ${supplier.materialsSupplied}',
    );
  }

  // Expenses Actions
  Future<void> addExpense(Expense expense, String userName, String role) async {
    _expenses.insert(0, expense);
    notifyListeners();
    final db = await _dbHelper.database;
    await db.insert('expenses', expense.toMap());
    await addAuditLog(
      userName: userName,
      userRole: role,
      action: 'CREATE',
      module: 'Expenses',
      recordAffected: expense.title,
      details: 'Recorded expense: ₹${expense.amount} under ${expense.category}',
    );
  }

  // Staff Actions
  Future<void> addStaff(Staff staff, String userName, String role) async {
    _staffList.add(staff);
    notifyListeners();
    final db = await _dbHelper.database;
    await db.insert('staff', staff.toMap());
    await addAuditLog(
      userName: userName,
      userRole: role,
      action: 'CREATE',
      module: 'Staff',
      recordAffected: staff.name,
      details: 'Enrolled staff ${staff.employeeCode} (${staff.role})',
    );
  }

  // Reset Data
  Future<void> resetAllData() async {
    await _dbHelper.clearAllData();
    _products = [];
    _rawMaterials = [];
    _batches = [];
    _qualityChecks = [];
    _movements = [];
    _orders = [];
    _customers = [];
    _suppliers = [];
    _expenses = [];
    _staffList = [];
    _notifications = [];
    _auditLogs = [];
    notifyListeners();
    await seedRealisticFactoryData();
  }
}
