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

    // 1. Products
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
        minStockLevel: 100,
        currentStock: 480,
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
        minStockLevel: 80,
        currentStock: 320,
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
        minStockLevel: 60,
        currentStock: 140,
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
        minStockLevel: 80,
        currentStock: 45, // Low stock trigger
      ),
      Product(
        id: 'PRD-005',
        name: 'Salem Guava Pulp Drink (300ml)',
        tamilName: 'சேலம் கொய்யா சாறு (300மி.லி)',
        code: 'JF-GVA-300',
        category: 'Pulp Squash',
        fruit: 'Guava',
        bottleSize: '300 ml',
        packagingType: 'Glass Bottle',
        sellingPrice: 35.0,
        costPrice: 17.5,
        gstRate: 12.0,
        minStockLevel: 100,
        currentStock: 260,
      ),
      Product(
        id: 'PRD-006',
        name: 'Royal Tropical Mixed Fruit (1 Liter)',
        tamilName: 'ராயல் மிக்ஸட் ஃப்ரூட் ஜூஸ் (1 லிட்டர்)',
        code: 'JF-MIX-1000',
        category: 'Nectar Blend',
        fruit: 'Mixed Fruit',
        bottleSize: '1000 ml (1 Liter)',
        packagingType: 'PET Bottle',
        sellingPrice: 90.0,
        costPrice: 48.0,
        gstRate: 12.0,
        minStockLevel: 50,
        currentStock: 95,
      ),
    ];

    // 2. Raw Materials
    _rawMaterials = [
      RawMaterial(
        id: 'RM-001',
        name: 'Grade A Alphonso Mango Pulp',
        tamilName: 'மாம்பழ கூழ் (கிரேடு A)',
        category: 'Fruits',
        supplierId: 'SUP-001',
        supplierName: 'Dharmapuri Fruit Orchards',
        quantity: 850.0,
        unit: 'Kg',
        purchasePrice: 65.0,
        batchNumber: 'LOT-MNG-402',
        purchaseDate: now.subtract(const Duration(days: 4)),
        expiryDate: now.add(const Duration(days: 45)),
        minStockLevel: 250.0,
        storageLocation: 'Cold Storage Room A',
      ),
      RawMaterial(
        id: 'RM-002',
        name: 'Fresh Nagpur Orange Extract',
        tamilName: 'ஆரஞ்சு சாறு கூழ்',
        category: 'Fruits',
        supplierId: 'SUP-002',
        supplierName: 'Citrus Valley Suppliers',
        quantity: 120.0, // Low stock
        unit: 'Kg',
        purchasePrice: 58.0,
        batchNumber: 'LOT-ORG-318',
        purchaseDate: now.subtract(const Duration(days: 8)),
        expiryDate: now.add(const Duration(days: 15)),
        minStockLevel: 200.0,
        storageLocation: 'Cold Storage Room B',
      ),
      RawMaterial(
        id: 'RM-003',
        name: 'Refined Pure Sugar (Food Grade)',
        tamilName: 'சுத்திகரிக்கப்பட்ட சர்க்கரை',
        category: 'Sweeteners & Sugar',
        supplierId: 'SUP-003',
        supplierName: 'Erode Agro Commodities',
        quantity: 1200.0,
        unit: 'Kg',
        purchasePrice: 38.0,
        batchNumber: 'SGR-2026-08',
        purchaseDate: now.subtract(const Duration(days: 12)),
        expiryDate: now.add(const Duration(days: 360)),
        minStockLevel: 300.0,
        storageLocation: 'Dry Warehouse Bay 2',
      ),
      RawMaterial(
        id: 'RM-004',
        name: 'Citric Acid & Antioxidant Formulation',
        tamilName: 'சிட்ரிக் அமிலம் (உணவு தரம்)',
        category: 'Preservatives & Citric',
        supplierId: 'SUP-004',
        supplierName: 'ChemFood Ingredients',
        quantity: 45.0,
        unit: 'Kg',
        purchasePrice: 190.0,
        batchNumber: 'CA-902',
        purchaseDate: now.subtract(const Duration(days: 20)),
        expiryDate: now.add(const Duration(days: 180)),
        minStockLevel: 15.0,
        storageLocation: 'Ingredient Store Lab',
      ),
      RawMaterial(
        id: 'RM-005',
        name: '500ml PET Juice Bottles',
        tamilName: '500மி.லி PET பாட்டில்கள்',
        category: 'Bottles (PET / Glass)',
        supplierId: 'SUP-005',
        supplierName: 'PolyPlast Packaging Industries',
        quantity: 4200.0,
        unit: 'Units / Pcs',
        purchasePrice: 3.20,
        batchNumber: 'PET-500-88',
        purchaseDate: now.subtract(const Duration(days: 5)),
        expiryDate: now.add(const Duration(days: 700)),
        minStockLevel: 1500.0,
        storageLocation: 'Packaging Bay A',
      ),
      RawMaterial(
        id: 'RM-006',
        name: 'Tamper-Evident Green Screw Caps (28mm)',
        tamilName: 'பச்சை நிற பாட்டில் மூடிகள் (28mm)',
        category: 'Caps & Seals',
        supplierId: 'SUP-005',
        supplierName: 'PolyPlast Packaging Industries',
        quantity: 5500.0,
        unit: 'Units / Pcs',
        purchasePrice: 0.85,
        batchNumber: 'CAP-28-14',
        purchaseDate: now.subtract(const Duration(days: 5)),
        expiryDate: now.add(const Duration(days: 700)),
        minStockLevel: 2000.0,
        storageLocation: 'Packaging Bay A',
      ),
      RawMaterial(
        id: 'RM-007',
        name: 'Self-Adhesive Alphonso Labels (Roll)',
        tamilName: 'மாம்பழ லேபிள் சுருள்கள்',
        category: 'Labels & Stickers',
        supplierId: 'SUP-006',
        supplierName: 'Sivakasi Print & Pack',
        quantity: 3800.0,
        unit: 'Units / Pcs',
        purchasePrice: 1.10,
        batchNumber: 'LBL-MNG-12',
        purchaseDate: now.subtract(const Duration(days: 7)),
        expiryDate: now.add(const Duration(days: 365)),
        minStockLevel: 1000.0,
        storageLocation: 'Label Room',
      ),
    ];

    // 3. Production Batches
    _batches = [
      ProductionBatch(
        id: 'BAT-2026-001',
        batchNumber: 'BATCH-2026-MNG-101',
        productId: 'PRD-001',
        productName: 'Alphonso Mango Juice (500ml)',
        productionDate: now.subtract(const Duration(hours: 4)),
        plannedQty: 600.0,
        actualQty: 580.0,
        wastageQty: 18.0,
        unit: 'Liters',
        ingredientsSummary: 'Mango Pulp: 180kg, Sugar: 55kg, Treated Water: 360L, Citric: 1.5kg',
        assignedStaff: 'Murugan (Supervisor)',
        startTime: now.subtract(const Duration(hours: 4)),
        endTime: now.subtract(const Duration(minutes: 30)),
        status: AppConstants.batchStatusCompleted,
        qcStatus: AppConstants.qcStatusPassed,
        expiryDate: now.add(const Duration(days: 90)),
        notes: 'Batch blending ran smooth. High natural fruit aroma and ideal viscosity.',
      ),
      ProductionBatch(
        id: 'BAT-2026-002',
        batchNumber: 'BATCH-2026-ORG-102',
        productId: 'PRD-002',
        productName: 'Nagpur Orange Delight (500ml)',
        productionDate: now.subtract(const Duration(hours: 2)),
        plannedQty: 400.0,
        actualQty: 390.0,
        wastageQty: 8.0,
        unit: 'Liters',
        ingredientsSummary: 'Orange Pulp: 130kg, Sugar: 35kg, Water: 240L',
        assignedStaff: 'Karthik Raja',
        startTime: now.subtract(const Duration(hours: 2)),
        status: AppConstants.batchStatusQualityCheck,
        qcStatus: AppConstants.qcStatusNeedsReview,
        expiryDate: now.add(const Duration(days: 90)),
        notes: 'Bottled and awaiting QC sign-off on pH stability.',
      ),
      ProductionBatch(
        id: 'BAT-2026-003',
        batchNumber: 'BATCH-2026-PNP-103',
        productId: 'PRD-004',
        productName: 'Kerala Queen Pineapple Juice (500ml)',
        productionDate: now,
        plannedQty: 500.0,
        actualQty: 0.0,
        wastageQty: 0.0,
        unit: 'Liters',
        ingredientsSummary: 'Pineapple Concentrate: 140kg, Sugar: 40kg, Water: 320L',
        assignedStaff: 'Selvam',
        startTime: now,
        status: AppConstants.batchStatusInProgress,
        qcStatus: AppConstants.qcStatusPending,
        expiryDate: now.add(const Duration(days: 90)),
        notes: 'Pasterization tank heating up to 85°C.',
      ),
      ProductionBatch(
        id: 'BAT-2026-004',
        batchNumber: 'BATCH-2026-APL-099',
        productId: 'PRD-003',
        productName: 'Kinnaur Apple Nectar (1 Liter)',
        productionDate: now.subtract(const Duration(days: 1)),
        plannedQty: 300.0,
        actualQty: 295.0,
        wastageQty: 5.0,
        unit: 'Liters',
        ingredientsSummary: 'Apple Nectar: 110kg, Water: 185L',
        assignedStaff: 'Murugan (Supervisor)',
        startTime: now.subtract(const Duration(days: 1, hours: 5)),
        endTime: now.subtract(const Duration(days: 1, hours: 1)),
        status: AppConstants.batchStatusCompleted,
        qcStatus: AppConstants.qcStatusPassed,
        expiryDate: now.add(const Duration(days: 120)),
        notes: 'Passed laboratory clarity and seal leakage vacuum test.',
      ),
    ];

    // 4. Quality Checks
    _qualityChecks = [
      QualityCheck(
        id: 'QC-001',
        batchId: 'BAT-2026-001',
        batchNumber: 'BATCH-2026-MNG-101',
        appearance: 'Golden thick pulpy liquid, no sedimentation',
        colour: 'Rich deep mango yellow',
        taste: 'Sweet with natural Alphonso tart note',
        smell: 'Intense fresh ripe fruit aroma',
        phValue: 3.85,
        temperature: 4.2,
        brixSugar: 14.5,
        packagingCondition: 'Clean, no dents, perfect label alignment',
        sealCondition: 'Hermetic induction heat seal intact',
        remarks: 'Sample approved for commercial release.',
        inspectorName: 'Dr. Anitha (Food Technologist)',
        checkDate: now.subtract(const Duration(hours: 1)),
        status: AppConstants.qcStatusPassed,
      ),
      QualityCheck(
        id: 'QC-002',
        batchId: 'BAT-2026-002',
        batchNumber: 'BATCH-2026-ORG-102',
        appearance: 'Natural citrus cloudiness',
        colour: 'Bright orange',
        taste: 'Tangy citrus flavor',
        smell: 'Fresh zesty aroma',
        phValue: 3.42,
        temperature: 4.5,
        brixSugar: 11.8,
        packagingCondition: 'Good',
        sealCondition: 'Passed torque resistance test',
        remarks: 'pH borderline at 3.42. Re-test sample in 1 hour.',
        inspectorName: 'Dr. Anitha (Food Technologist)',
        checkDate: now.subtract(const Duration(minutes: 30)),
        status: AppConstants.qcStatusNeedsReview,
      ),
    ];

    // 5. Customers
    _customers = [
      Customer(
        id: 'CUST-001',
        name: 'Sundar Stores (Supermarket)',
        businessName: 'Sundar Retail Mart Pvt Ltd',
        phone: '+91 94432 11098',
        email: 'purchase@sundarmart.in',
        address: '14 Cross Road, Madurai - 625001',
        customerType: 'Supermarket',
        outstandingBalance: 12500.0,
        createdAt: now.subtract(const Duration(days: 60)),
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
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      Customer(
        id: 'CUST-003',
        name: 'Vasantham Department Stores',
        businessName: 'Vasantham Retail Group',
        phone: '+91 97500 88210',
        email: 'vasantham.theni@gmail.com',
        address: 'Main Bazaar, Theni - 625531',
        customerType: 'Retailer',
        outstandingBalance: 6800.0,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Customer(
        id: 'CUST-004',
        name: 'Southern Beverages Wholesale',
        businessName: 'Southern Distributor Network',
        phone: '+91 99420 55112',
        email: 'orders@southernbev.com',
        address: 'Wholesale Market Complex, Trichy - 620008',
        customerType: 'Distributor',
        outstandingBalance: 34000.0,
        createdAt: now.subtract(const Duration(days: 90)),
      ),
    ];

    // 6. Suppliers
    _suppliers = [
      Supplier(
        id: 'SUP-001',
        name: 'Dharmapuri Fruit Orchards',
        contactPerson: 'Venkatesh Farmers Association',
        phone: '+91 94421 77654',
        email: 'dharmapuri.fruits@gmail.com',
        address: 'Orchard Valley, Dharmapuri - 636701',
        materialsSupplied: 'Alphonso Mango Pulp, Totapuri Mangoes',
        outstandingAmount: 22000.0,
        createdAt: now.subtract(const Duration(days: 120)),
      ),
      Supplier(
        id: 'SUP-002',
        name: 'Citrus Valley Suppliers',
        contactPerson: 'Rajesh Sharma',
        phone: '+91 98230 44122',
        email: 'citrusvalley@nagpurcitrus.in',
        address: 'Market Yard, Nagpur - 440008',
        materialsSupplied: 'Nagpur Orange Extract & Concentrate',
        outstandingAmount: 14500.0,
        createdAt: now.subtract(const Duration(days: 80)),
      ),
      Supplier(
        id: 'SUP-003',
        name: 'Erode Agro Commodities',
        contactPerson: 'Shanmugam Traders',
        phone: '+91 98427 33211',
        email: 'erodeagro@sugar.co.in',
        address: 'Industrial Area, Erode - 638001',
        materialsSupplied: 'Refined Sugar, Liquid Invert Sugar',
        outstandingAmount: 0.0,
        createdAt: now.subtract(const Duration(days: 100)),
      ),
      Supplier(
        id: 'SUP-005',
        name: 'PolyPlast Packaging Industries',
        contactPerson: 'Mahesh Kumar',
        phone: '+91 97910 88992',
        email: 'sales@polyplastpack.com',
        address: 'SIDCO Estate, Coimbatore - 641021',
        materialsSupplied: 'PET Bottles, Caps, Shrink Sleeves',
        outstandingAmount: 8400.0,
        createdAt: now.subtract(const Duration(days: 90)),
      ),
    ];

    // 7. Orders
    _orders = [
      SalesOrder(
        id: 'ORD-001',
        orderNumber: 'JF-ORD-2026-101',
        customerId: 'CUST-001',
        customerName: 'Sundar Stores (Supermarket)',
        customerPhone: '+91 94432 11098',
        customerAddress: '14 Cross Road, Madurai',
        items: [
          OrderItem(
            productId: 'PRD-001',
            productName: 'Alphonso Mango Juice (500ml)',
            bottleSize: '500 ml',
            quantity: 120,
            unitPrice: 45.0,
          ),
          OrderItem(
            productId: 'PRD-002',
            productName: 'Nagpur Orange Delight (500ml)',
            bottleSize: '500 ml',
            quantity: 60,
            unitPrice: 40.0,
          ),
        ],
        subtotal: 7800.0,
        discount: 300.0,
        taxAmount: 900.0,
        grandTotal: 8400.0,
        paidAmount: 8400.0,
        paymentStatus: AppConstants.paymentStatusPaid,
        deliveryStatus: AppConstants.orderStatusDelivered,
        orderDate: now.subtract(const Duration(days: 1, hours: 3)),
        deliveryDate: now.subtract(const Duration(hours: 18)),
        notes: 'Dispatched via Express Van #1.',
      ),
      SalesOrder(
        id: 'ORD-002',
        orderNumber: 'JF-ORD-2026-102',
        customerId: 'CUST-002',
        customerName: 'Hotel Grand Residency',
        customerPhone: '+91 98840 22334',
        customerAddress: 'Bypass Road, Dindigul',
        items: [
          OrderItem(
            productId: 'PRD-003',
            productName: 'Kinnaur Apple Nectar (1 Liter)',
            bottleSize: '1000 ml',
            quantity: 50,
            unitPrice: 85.0,
          ),
          OrderItem(
            productId: 'PRD-005',
            productName: 'Salem Guava Pulp Drink (300ml)',
            bottleSize: '300 ml',
            quantity: 80,
            unitPrice: 35.0,
          ),
        ],
        subtotal: 7050.0,
        discount: 250.0,
        taxAmount: 816.0,
        grandTotal: 7616.0,
        paidAmount: 4000.0,
        paymentStatus: AppConstants.paymentStatusPartial,
        deliveryStatus: AppConstants.orderStatusDispatched,
        orderDate: now.subtract(const Duration(hours: 5)),
        deliveryDate: now.add(const Duration(hours: 2)),
        notes: 'Delivery vehicle in transit.',
      ),
      SalesOrder(
        id: 'ORD-003',
        orderNumber: 'JF-ORD-2026-103',
        customerId: 'CUST-004',
        customerName: 'Southern Beverages Wholesale',
        customerPhone: '+91 99420 55112',
        customerAddress: 'Wholesale Market Complex, Trichy',
        items: [
          OrderItem(
            productId: 'PRD-001',
            productName: 'Alphonso Mango Juice (500ml)',
            bottleSize: '500 ml',
            quantity: 300,
            unitPrice: 42.0, // Wholesale rate
          ),
          OrderItem(
            productId: 'PRD-002',
            productName: 'Nagpur Orange Delight (500ml)',
            bottleSize: '500 ml',
            quantity: 200,
            unitPrice: 38.0,
          ),
        ],
        subtotal: 20200.0,
        discount: 700.0,
        taxAmount: 2340.0,
        grandTotal: 21840.0,
        paidAmount: 0.0,
        paymentStatus: AppConstants.paymentStatusUnpaid,
        deliveryStatus: AppConstants.orderStatusConfirmed,
        orderDate: now.subtract(const Duration(hours: 1)),
        deliveryDate: now.add(const Duration(days: 1)),
        notes: 'Carton boxing in progress in warehouse bay.',
      ),
    ];

    // 8. Expenses
    _expenses = [
      Expense(
        id: 'EXP-001',
        title: 'Factory Electricity Bill (TANGEDCO)',
        category: 'Electricity & Power',
        amount: 14850.0,
        date: now.subtract(const Duration(days: 2)),
        paymentMethod: 'UPI / Net Banking',
        description: 'Monthly commercial high-tension line tariff.',
      ),
      Expense(
        id: 'EXP-002',
        title: 'Boiler & Chiller Maintenance Service',
        category: 'Machinery Maintenance',
        amount: 5200.0,
        date: now.subtract(const Duration(days: 5)),
        paymentMethod: 'Bank Transfer',
        description: 'Scheduled preventive service by Star Refrigeration.',
      ),
      Expense(
        id: 'EXP-003',
        title: 'Delivery Van Diesel Fuel',
        category: 'Transportation & Fuel',
        amount: 3400.0,
        date: now.subtract(const Duration(days: 1)),
        paymentMethod: 'Cash',
        description: 'Fuel for Madurai - Dindigul delivery route.',
      ),
      Expense(
        id: 'EXP-004',
        title: 'Treated RO Water Quality Testing Lab Fees',
        category: 'Water Supply',
        amount: 2200.0,
        date: now.subtract(const Duration(days: 6)),
        paymentMethod: 'UPI',
        description: 'Monthly NABL accredited microbiology test.',
      ),
    ];

    // 9. Staff
    _staffList = [
      Staff(
        id: 'STF-001',
        name: 'Ramasamy Kumar',
        employeeCode: 'EMP-ADM-01',
        role: AppConstants.roleAdmin,
        phone: '+91 98421 55678',
        email: 'kumar@freshvibejuice.com',
        joiningDate: now.subtract(const Duration(days: 500)),
        department: 'Management',
        batchesHandled: 45,
        ordersHandled: 120,
      ),
      Staff(
        id: 'STF-002',
        name: 'Suresh Pandian',
        employeeCode: 'EMP-MGR-02',
        role: AppConstants.roleManager,
        phone: '+91 97890 33441',
        email: 'suresh@freshvibejuice.com',
        joiningDate: now.subtract(const Duration(days: 350)),
        department: 'Factory Operations',
        batchesHandled: 32,
        ordersHandled: 85,
      ),
      Staff(
        id: 'STF-003',
        name: 'Murugan',
        employeeCode: 'EMP-PRD-03',
        role: AppConstants.roleProduction,
        phone: '+91 96290 11223',
        email: 'murugan@freshvibejuice.com',
        joiningDate: now.subtract(const Duration(days: 280)),
        department: 'Juice Processing & Filling',
        batchesHandled: 28,
        ordersHandled: 0,
      ),
      Staff(
        id: 'STF-004',
        name: 'Muthu Vel',
        employeeCode: 'EMP-INV-04',
        role: AppConstants.roleInventory,
        phone: '+91 94860 99887',
        email: 'muthu@freshvibejuice.com',
        joiningDate: now.subtract(const Duration(days: 210)),
        department: 'Cold Stores & Warehouse',
        batchesHandled: 0,
        ordersHandled: 42,
      ),
      Staff(
        id: 'STF-005',
        name: 'Vignesh',
        employeeCode: 'EMP-SLS-05',
        role: AppConstants.roleSales,
        phone: '+91 98400 44556',
        email: 'vignesh@freshvibejuice.com',
        joiningDate: now.subtract(const Duration(days: 180)),
        department: 'Sales & Distribution',
        batchesHandled: 0,
        ordersHandled: 64,
      ),
    ];

    // 10. Notifications
    _notifications = [
      NotificationItem(
        id: 'NOTIF-001',
        title: 'Low Stock Alert: Pineapple Juice (500ml)',
        message: 'Current stock is only 45 units. Minimum reorder level is 80 units.',
        type: 'low_stock',
        priority: 'HIGH',
        createdAt: now.subtract(const Duration(minutes: 40)),
      ),
      NotificationItem(
        id: 'NOTIF-002',
        title: 'QC Attention: Batch #BATCH-2026-ORG-102',
        message: 'Orange Juice batch requires pH re-evaluation before packaging sign-off.',
        type: 'qc_alert',
        priority: 'HIGH',
        createdAt: now.subtract(const Duration(minutes: 25)),
      ),
      NotificationItem(
        id: 'NOTIF-003',
        title: 'Pending Order: Southern Beverages Wholesale',
        message: 'Order JF-ORD-2026-103 worth ₹21,840 is waiting for packed carton dispatch.',
        type: 'pending_order',
        priority: 'MEDIUM',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      NotificationItem(
        id: 'NOTIF-004',
        title: 'Raw Material Low: Nagpur Orange Extract',
        message: 'Only 120 kg remaining in Cold Storage Room B.',
        type: 'low_stock',
        priority: 'MEDIUM',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
    ];

    // 11. Audit Logs
    _auditLogs = [
      AuditLog(
        id: 'AUD-001',
        userName: 'Murugan',
        userRole: 'production_staff',
        action: 'BATCH_COMPLETE',
        module: 'Production',
        recordAffected: 'BATCH-2026-MNG-101',
        details: 'Completed 580 Liters of Alphonso Mango Juice. Wastage recorded at 18L.',
        timestamp: now.subtract(const Duration(minutes: 30)),
      ),
      AuditLog(
        id: 'AUD-002',
        userName: 'Dr. Anitha',
        userRole: 'quality_inspector',
        action: 'QC_APPROVE',
        module: 'Quality Control',
        recordAffected: 'BATCH-2026-MNG-101',
        details: 'Approved batch quality parameters: pH 3.85, Brix 14.5°Bx, Seal intact.',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      AuditLog(
        id: 'AUD-003',
        userName: 'Vignesh',
        userRole: 'sales_staff',
        action: 'ORDER_CREATE',
        module: 'Orders',
        recordAffected: 'JF-ORD-2026-103',
        details: 'Created sales order for Southern Beverages Wholesale (500 bottles).',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      AuditLog(
        id: 'AUD-004',
        userName: 'Ramasamy Kumar',
        userRole: 'admin',
        action: 'STOCK_ADJUST',
        module: 'Inventory',
        recordAffected: 'Alphonso Mango Juice (500ml)',
        details: 'Stock increased to 480 bottles after packaging batch #101.',
        timestamp: now.subtract(const Duration(hours: 2)),
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
