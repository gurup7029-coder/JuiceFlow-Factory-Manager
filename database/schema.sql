-- ==============================================================================
-- JUICEFLOW FACTORY MANAGER -- POSTGRESQL & SUPABASE DATABASE SCHEMA
-- Enterprise Food & Beverage Manufacturing Management System
-- Compatible with both Web / Cloud & Offline-First Mobile SQLite Sync
-- ==============================================================================

-- Enable UUID extension if available
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. FACTORIES
CREATE TABLE IF NOT EXISTS factories (
    id VARCHAR(100) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    factory_name VARCHAR(255) NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    phone VARCHAR(50),
    email VARCHAR(100),
    website VARCHAR(100),
    gst_number VARCHAR(50),
    fssai_license VARCHAR(50),
    invoice_prefix VARCHAR(20) DEFAULT 'JF-INV-',
    logo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. USERS & ROLES
CREATE TABLE IF NOT EXISTS user_profiles (
    id VARCHAR(100) PRIMARY KEY,
    factory_id VARCHAR(100),
    full_name VARCHAR(150) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('admin', 'manager', 'production_staff', 'inventory_staff', 'sales_staff')),
    phone VARCHAR(50),
    department VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. PRODUCT CATEGORIES
CREATE TABLE IF NOT EXISTS product_categories (
    id VARCHAR(100) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. PRODUCTS (Finished Juice Beverages)
CREATE TABLE IF NOT EXISTS products (
    id VARCHAR(100) PRIMARY KEY,
    factory_id VARCHAR(100),
    name VARCHAR(200) NOT NULL,
    tamil_name VARCHAR(200) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    category VARCHAR(100) NOT NULL,
    fruit VARCHAR(100) NOT NULL,
    bottle_size VARCHAR(50) NOT NULL,
    packaging_type VARCHAR(50) NOT NULL,
    selling_price NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    cost_price NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    gst_rate NUMERIC(5, 2) NOT NULL DEFAULT 12.00,
    min_stock_level INT NOT NULL DEFAULT 50,
    current_stock INT NOT NULL DEFAULT 0,
    image_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. SUPPLIERS
CREATE TABLE IF NOT EXISTS suppliers (
    id VARCHAR(100) PRIMARY KEY,
    factory_id VARCHAR(100),
    name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(150),
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    address TEXT,
    materials_supplied TEXT,
    outstanding_amount NUMERIC(12, 2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. RAW MATERIALS (Fruit Pulps, Sugar, Preservatives & Packaging)
CREATE TABLE IF NOT EXISTS raw_materials (
    id VARCHAR(100) PRIMARY KEY,
    factory_id VARCHAR(100),
    name VARCHAR(200) NOT NULL,
    tamil_name VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL,
    supplier_id VARCHAR(100),
    supplier_name VARCHAR(200),
    quantity NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    unit VARCHAR(30) NOT NULL,
    purchase_price NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    batch_number VARCHAR(100),
    purchase_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    min_stock_level NUMERIC(12, 2) NOT NULL DEFAULT 20.00,
    storage_location VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. PRODUCTION BATCHES
CREATE TABLE IF NOT EXISTS production_batches (
    id VARCHAR(100) PRIMARY KEY,
    factory_id VARCHAR(100),
    batch_number VARCHAR(100) UNIQUE NOT NULL,
    product_id VARCHAR(100),
    product_name VARCHAR(200) NOT NULL,
    production_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    planned_qty NUMERIC(10, 2) NOT NULL,
    actual_qty NUMERIC(10, 2) DEFAULT 0.00,
    wastage_qty NUMERIC(10, 2) DEFAULT 0.00,
    unit VARCHAR(30) DEFAULT 'Liters',
    ingredients_summary TEXT,
    assigned_staff VARCHAR(150),
    start_time TIMESTAMP WITH TIME ZONE,
    end_time TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50) DEFAULT 'Planned',
    qc_status VARCHAR(50) DEFAULT 'Pending',
    expiry_date DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. QUALITY CONTROL CHECKS
CREATE TABLE IF NOT EXISTS quality_checks (
    id VARCHAR(100) PRIMARY KEY,
    batch_id VARCHAR(100),
    batch_number VARCHAR(100) NOT NULL,
    appearance VARCHAR(150),
    colour VARCHAR(150),
    taste VARCHAR(150),
    smell VARCHAR(150),
    ph_value NUMERIC(4, 2) NOT NULL,
    temperature NUMERIC(4, 1) NOT NULL,
    brix_sugar NUMERIC(4, 2) NOT NULL,
    packaging_condition VARCHAR(150),
    seal_condition VARCHAR(150),
    remarks TEXT,
    inspector_name VARCHAR(150) NOT NULL,
    check_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status VARCHAR(50) NOT NULL
);

-- 9. CUSTOMERS
CREATE TABLE IF NOT EXISTS customers (
    id VARCHAR(100) PRIMARY KEY,
    factory_id VARCHAR(100),
    name VARCHAR(200) NOT NULL,
    business_name VARCHAR(200) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    address TEXT,
    customer_type VARCHAR(50) NOT NULL,
    outstanding_balance NUMERIC(12, 2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. SALES ORDERS & INVOICES
CREATE TABLE IF NOT EXISTS sales_orders (
    id VARCHAR(100) PRIMARY KEY,
    factory_id VARCHAR(100),
    order_number VARCHAR(100) UNIQUE NOT NULL,
    customer_id VARCHAR(100),
    customer_name VARCHAR(200) NOT NULL,
    customer_phone VARCHAR(50),
    customer_address TEXT,
    items_json JSONB NOT NULL,
    subtotal NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    discount NUMERIC(10, 2) DEFAULT 0.00,
    tax_amount NUMERIC(10, 2) DEFAULT 0.00,
    grand_total NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    paid_amount NUMERIC(12, 2) DEFAULT 0.00,
    payment_status VARCHAR(50) DEFAULT 'Unpaid',
    delivery_status VARCHAR(50) DEFAULT 'New',
    order_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    delivery_date TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. INVENTORY MOVEMENTS / TRANSACTIONS
CREATE TABLE IF NOT EXISTS inventory_transactions (
    id VARCHAR(100) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    item_id VARCHAR(100) NOT NULL,
    item_name VARCHAR(200) NOT NULL,
    item_type VARCHAR(50) NOT NULL,
    movement_type VARCHAR(50) NOT NULL,
    quantity NUMERIC(10, 2) NOT NULL,
    unit VARCHAR(30) NOT NULL,
    performed_by VARCHAR(150),
    reference_id VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 12. EXPENSES
CREATE TABLE IF NOT EXISTS expenses (
    id VARCHAR(100) PRIMARY KEY,
    factory_id VARCHAR(100),
    title VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_method VARCHAR(50) NOT NULL,
    description TEXT,
    receipt_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 13. STAFF MEMBERS
CREATE TABLE IF NOT EXISTS staff (
    id VARCHAR(100) PRIMARY KEY,
    factory_id VARCHAR(100),
    name VARCHAR(150) NOT NULL,
    employee_code VARCHAR(50) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    joining_date DATE NOT NULL DEFAULT CURRENT_DATE,
    department VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    batches_handled INT DEFAULT 0,
    orders_handled INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 14. NOTIFICATIONS
CREATE TABLE IF NOT EXISTS notifications (
    id VARCHAR(100) PRIMARY KEY,
    factory_id VARCHAR(100),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    priority VARCHAR(20) DEFAULT 'MEDIUM',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 15. AUDIT LOGS
CREATE TABLE IF NOT EXISTS audit_logs (
    id VARCHAR(100) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    factory_id VARCHAR(100),
    user_name VARCHAR(150) NOT NULL,
    user_role VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL,
    module VARCHAR(100) NOT NULL,
    record_affected VARCHAR(200) NOT NULL,
    details TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 16. OVER-THE-AIR (OTA) APP RELEASES & REMOTE CONFIGURATION
CREATE TABLE IF NOT EXISTS app_releases (
    id VARCHAR(100) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    version VARCHAR(20) NOT NULL UNIQUE,
    build_number INT NOT NULL,
    release_name VARCHAR(150) NOT NULL,
    release_notes TEXT,
    download_url TEXT NOT NULL,
    is_mandatory BOOLEAN DEFAULT false,
    file_size_bytes BIGINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS remote_configs (
    key VARCHAR(100) PRIMARY KEY,
    value JSONB NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- INDEXES FOR FAST FACTORY SEARCH & REPORTING
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_products_code ON products(code);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_raw_materials_category ON raw_materials(category);
CREATE INDEX IF NOT EXISTS idx_batches_number ON production_batches(batch_number);
CREATE INDEX IF NOT EXISTS idx_batches_date ON production_batches(production_date);
CREATE INDEX IF NOT EXISTS idx_orders_number ON sales_orders(order_number);
CREATE INDEX IF NOT EXISTS idx_orders_date ON sales_orders(order_date);
CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date);
CREATE INDEX IF NOT EXISTS idx_staff_email ON staff(email);
CREATE INDEX IF NOT EXISTS idx_audit_timestamp ON audit_logs(timestamp);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES (Accessible by anon & authenticated keys)
-- ==============================================================================
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE raw_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE production_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE quality_checks ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_releases ENABLE ROW LEVEL SECURITY;
ALTER TABLE remote_configs ENABLE ROW LEVEL SECURITY;

-- Products Policies
DROP POLICY IF EXISTS "Public access products" ON products;
CREATE POLICY "Public access products" ON products FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- Raw Materials Policies
DROP POLICY IF EXISTS "Public access raw_materials" ON raw_materials;
CREATE POLICY "Public access raw_materials" ON raw_materials FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- Production Batches Policies
DROP POLICY IF EXISTS "Public access batches" ON production_batches;
CREATE POLICY "Public access batches" ON production_batches FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- Quality Checks Policies
DROP POLICY IF EXISTS "Public access quality_checks" ON quality_checks;
CREATE POLICY "Public access quality_checks" ON quality_checks FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- Sales Orders Policies
DROP POLICY IF EXISTS "Public access sales_orders" ON sales_orders;
CREATE POLICY "Public access sales_orders" ON sales_orders FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- Customers & Suppliers Policies
DROP POLICY IF EXISTS "Public access customers" ON customers;
CREATE POLICY "Public access customers" ON customers FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public access suppliers" ON suppliers;
CREATE POLICY "Public access suppliers" ON suppliers FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- Expenses Policies
DROP POLICY IF EXISTS "Public access expenses" ON expenses;
CREATE POLICY "Public access expenses" ON expenses FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- Staff Policies
DROP POLICY IF EXISTS "Public access staff" ON staff;
CREATE POLICY "Public access staff" ON staff FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- Notifications & Audit Logs Policies
DROP POLICY IF EXISTS "Public access notifications" ON notifications;
CREATE POLICY "Public access notifications" ON notifications FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public access audit_logs" ON audit_logs;
CREATE POLICY "Public access audit_logs" ON audit_logs FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- OTA Releases & Config Policies
DROP POLICY IF EXISTS "Public access app_releases" ON app_releases;
CREATE POLICY "Public access app_releases" ON app_releases FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public access remote_configs" ON remote_configs;
CREATE POLICY "Public access remote_configs" ON remote_configs FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- ==============================================================================
-- DEFAULT SEED DATA: 5 FACTORY STAFF ROLES & DEFAULT CREDENTIALS
-- Password for all accounts: factory@2026
-- ==============================================================================
INSERT INTO staff (id, name, employee_code, role, phone, email, department, batches_handled, orders_handled)
VALUES 
  ('STF-001', 'Ramasamy Kumar (Owner)', 'EMP-ADM-01', 'admin', '+91 98421 55678', 'admin@juiceflow.com', 'Executive Management', 1, 1),
  ('STF-002', 'Suresh Pandian (Manager)', 'EMP-MGR-02', 'manager', '+91 97890 33441', 'manager@juiceflow.com', 'Plant Operations', 1, 1),
  ('STF-003', 'Vignesh (Sales Head)', 'EMP-SLS-03', 'sales_staff', '+91 98400 44556', 'sales@juiceflow.com', 'Sales & Distribution', 0, 1),
  ('STF-004', 'Murugan (Production Head)', 'EMP-PRD-04', 'production_staff', '+91 94422 66778', 'production@juiceflow.com', 'Production & Processing', 1, 0),
  ('STF-005', 'Muthu Vel (Inventory)', 'EMP-INV-05', 'inventory_staff', '+91 95533 77889', 'inventory@juiceflow.com', 'Raw Materials & Stores', 0, 0)
ON CONFLICT (employee_code) DO UPDATE 
SET name = EXCLUDED.name, email = EXCLUDED.email, role = EXCLUDED.role;

-- ==============================================================================
-- DEFAULT SEED DATA: JUICE BEVERAGE PRODUCTS
-- ==============================================================================
INSERT INTO products (id, name, tamil_name, code, category, fruit, bottle_size, packaging_type, selling_price, cost_price, gst_rate, min_stock_level, current_stock, is_active)
VALUES
  ('PRD-001', 'Alphonso Mango Juice (500ml)', 'அல்போன்சா மாம்பழ சாறு (500மி.லி)', 'JF-MNG-500', 'Pure Juice', 'Mango', '500 ml', 'PET Bottle', 45.0, 24.0, 12.0, 50, 120, true),
  ('PRD-002', 'Nagpur Orange Delight (500ml)', 'நாக்பூர் ஆரஞ்சு பழச்சாறு (500மி.லி)', 'JF-ORG-500', 'Pure Juice', 'Orange', '500 ml', 'PET Bottle', 40.0, 21.0, 12.0, 50, 80, true),
  ('PRD-003', 'Kinnaur Apple Nectar (1 Liter)', 'ஆப்பிள் நெக்டார் (1 லிட்டர்)', 'JF-APL-1000', 'Nectar Blend', 'Apple', '1000 ml (1 Liter)', 'PET Bottle', 85.0, 46.0, 12.0, 30, 40, true),
  ('PRD-004', 'Kerala Queen Pineapple Juice (500ml)', 'அன்னாசி பழச்சாறு (500மி.லி)', 'JF-PNP-500', 'Pure Juice', 'Pineapple', '500 ml', 'PET Bottle', 42.0, 22.0, 12.0, 40, 25, true),
  ('PRD-005', 'Kashmir Pomegranate Elixir (300ml)', 'மாதுளை எலிக்சர் (300மி.லி)', 'JF-POM-300', 'Cold Pressed', 'Pomegranate', '300 ml', 'Glass Bottle', 65.0, 36.0, 12.0, 25, 60, true),
  ('PRD-006', 'South Indian Guava Squash (1 Liter)', 'கொய்யா ஸ்குவாஷ் (1 லிட்டர்)', 'JF-GVA-1000', 'Pulp Squash', 'Guava', '1000 ml (1 Liter)', 'PET Bottle', 75.0, 38.0, 12.0, 30, 50, true)
ON CONFLICT (code) DO NOTHING;
