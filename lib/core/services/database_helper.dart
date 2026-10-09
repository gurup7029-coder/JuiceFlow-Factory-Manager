import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('juiceflow_factory.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  FutureOr<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        tamil_name TEXT NOT NULL,
        code TEXT NOT NULL,
        category TEXT NOT NULL,
        fruit TEXT NOT NULL,
        bottle_size TEXT NOT NULL,
        packaging_type TEXT NOT NULL,
        selling_price REAL NOT NULL,
        cost_price REAL NOT NULL,
        gst_rate REAL NOT NULL,
        min_stock_level INTEGER NOT NULL,
        current_stock INTEGER NOT NULL,
        image_url TEXT,
        is_active INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE raw_materials (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        tamil_name TEXT NOT NULL,
        category TEXT NOT NULL,
        supplier_id TEXT NOT NULL,
        supplier_name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        purchase_price REAL NOT NULL,
        batch_number TEXT NOT NULL,
        purchase_date TEXT NOT NULL,
        expiry_date TEXT NOT NULL,
        min_stock_level REAL NOT NULL,
        storage_location TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE production_batches (
        id TEXT PRIMARY KEY,
        batch_number TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        production_date TEXT NOT NULL,
        planned_qty REAL NOT NULL,
        actual_qty REAL NOT NULL,
        wastage_qty REAL NOT NULL,
        unit TEXT NOT NULL,
        ingredients_summary TEXT NOT NULL,
        assigned_staff TEXT NOT NULL,
        start_time TEXT,
        end_time TEXT,
        status TEXT NOT NULL,
        qc_status TEXT NOT NULL,
        expiry_date TEXT NOT NULL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE quality_checks (
        id TEXT PRIMARY KEY,
        batch_id TEXT NOT NULL,
        batch_number TEXT NOT NULL,
        appearance TEXT NOT NULL,
        colour TEXT NOT NULL,
        taste TEXT NOT NULL,
        smell TEXT NOT NULL,
        ph_value REAL NOT NULL,
        temperature REAL NOT NULL,
        brix_sugar REAL NOT NULL,
        packaging_condition TEXT NOT NULL,
        seal_condition TEXT NOT NULL,
        remarks TEXT NOT NULL,
        inspector_name TEXT NOT NULL,
        check_date TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE stock_movements (
        id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        item_name TEXT NOT NULL,
        item_type TEXT NOT NULL,
        movement_type TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        date TEXT NOT NULL,
        performed_by TEXT NOT NULL,
        reference_id TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sales_orders (
        id TEXT PRIMARY KEY,
        order_number TEXT NOT NULL,
        customer_id TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        customer_phone TEXT NOT NULL,
        customer_address TEXT NOT NULL,
        items_json TEXT NOT NULL,
        subtotal REAL NOT NULL,
        discount REAL NOT NULL,
        tax_amount REAL NOT NULL,
        grand_total REAL NOT NULL,
        paid_amount REAL NOT NULL,
        payment_status TEXT NOT NULL,
        delivery_status TEXT NOT NULL,
        order_date TEXT NOT NULL,
        delivery_date TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        business_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        address TEXT NOT NULL,
        customer_type TEXT NOT NULL,
        outstanding_balance REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE suppliers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        contact_person TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        address TEXT NOT NULL,
        materials_supplied TEXT NOT NULL,
        outstanding_amount REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        description TEXT NOT NULL,
        receipt_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE staff (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        employee_code TEXT NOT NULL,
        role TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        joining_date TEXT NOT NULL,
        department TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        batches_handled INTEGER NOT NULL,
        orders_handled INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        priority TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_read INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE audit_logs (
        id TEXT PRIMARY KEY,
        user_name TEXT NOT NULL,
        user_role TEXT NOT NULL,
        action TEXT NOT NULL,
        module TEXT NOT NULL,
        record_affected TEXT NOT NULL,
        details TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE factory_profile (
        id INTEGER PRIMARY KEY,
        factory_name TEXT,
        company_name TEXT,
        address TEXT,
        phone TEXT,
        email TEXT,
        website TEXT,
        gst_number TEXT,
        fssai_license TEXT,
        invoice_prefix TEXT,
        logo_url TEXT
      )
    ''');
  }

  Future<void> clearAllData() async {
    final db = await database;
    final tables = [
      'products',
      'raw_materials',
      'production_batches',
      'quality_checks',
      'stock_movements',
      'sales_orders',
      'customers',
      'suppliers',
      'expenses',
      'staff',
      'notifications',
      'audit_logs',
    ];
    for (var t in tables) {
      await db.delete(t);
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
