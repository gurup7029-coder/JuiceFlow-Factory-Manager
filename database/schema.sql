-- ==============================================================================
-- JUICEFLOW FACTORY MANAGER -- POSTGRESQL & SUPABASE DATABASE SCHEMA
-- Enterprise Food & Beverage Manufacturing Management System
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. FACTORIES
CREATE TABLE IF NOT EXISTS factories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    factory_id UUID REFERENCES factories(id) ON DELETE SET NULL,
    full_name VARCHAR(150) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('admin', 'manager', 'production_staff', 'inventory_staff', 'sales_staff')),
    phone VARCHAR(50),
    department VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. PRODUCT CATEGORIES
CREATE TABLE IF NOT EXISTS product_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. PRODUCTS (Finished Juice Beverages)
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    factory_id UUID REFERENCES factories(id) ON DELETE CASCADE,
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
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    factory_id UUID REFERENCES factories(id) ON DELETE CASCADE,
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
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    factory_id UUID REFERENCES factories(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    tamil_name VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL,
    supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL,
    supplier_name VARCHAR(200),
    quantity NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    unit VARCHAR(30) NOT NULL, -- 'Kg', 'Liters', 'Units / Pcs', etc.
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
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    factory_id UUID REFERENCES factories(id) ON DELETE CASCADE,
    batch_number VARCHAR(100) UNIQUE NOT NULL,
    product_id UUID REFERENCES products(id) ON DELETE RESTRICT,
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
    status VARCHAR(50) DEFAULT 'Planned' CHECK (status IN ('Planned', 'In Progress', 'Quality Check', 'Completed', 'Rejected', 'Cancelled')),
    qc_status VARCHAR(50) DEFAULT 'Pending' CHECK (qc_status IN ('Pending', 'Passed', 'Failed', 'Needs Review')),
    expiry_date DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. QUALITY CONTROL CHECKS
CREATE TABLE IF NOT EXISTS quality_checks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    batch_id UUID REFERENCES production_batches(id) ON DELETE CASCADE,
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
    status VARCHAR(50) NOT NULL CHECK (status IN ('Passed', 'Failed', 'Needs Review'))
);

-- 9. CUSTOMERS
CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    factory_id UUID REFERENCES factories(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    business_name VARCHAR(200) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    address TEXT,
    customer_type VARCHAR(50) NOT NULL, -- Retailer, Wholesaler, Supermarket, Hotel, etc.
    outstanding_balance NUMERIC(12, 2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. SALES ORDERS & INVOICES
CREATE TABLE IF NOT EXISTS sales_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    factory_id UUID REFERENCES factories(id) ON DELETE CASCADE,
    order_number VARCHAR(100) UNIQUE NOT NULL,
    customer_id UUID REFERENCES customers(id) ON DELETE RESTRICT,
    customer_name VARCHAR(200) NOT NULL,
    customer_phone VARCHAR(50),
    customer_address TEXT,
    items_json JSONB NOT NULL,
    subtotal NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    discount NUMERIC(10, 2) DEFAULT 0.00,
    tax_amount NUMERIC(10, 2) DEFAULT 0.00,
    grand_total NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    paid_amount NUMERIC(12, 2) DEFAULT 0.00,
    payment_status VARCHAR(50) DEFAULT 'Unpaid' CHECK (payment_status IN ('Paid', 'Partial', 'Unpaid')),
    delivery_status VARCHAR(50) DEFAULT 'New' CHECK (delivery_status IN ('New', 'Confirmed', 'Processing', 'Packed', 'Dispatched', 'Delivered', 'Cancelled')),
    order_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    delivery_date TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. INVENTORY MOVEMENTS / TRANSACTIONS
CREATE TABLE IF NOT EXISTS inventory_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id VARCHAR(100) NOT NULL,
    item_name VARCHAR(200) NOT NULL,
    item_type VARCHAR(50) NOT NULL, -- 'Raw Material', 'Packaging', 'Finished Goods'
    movement_type VARCHAR(50) NOT NULL, -- 'Production In', 'Production Used', 'Purchase In', 'Sales Out', 'Wastage', 'Adjustment'
    quantity NUMERIC(10, 2) NOT NULL,
    unit VARCHAR(30) NOT NULL,
    performed_by VARCHAR(150),
    reference_id VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 12. EXPENSES
CREATE TABLE IF NOT EXISTS expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    factory_id UUID REFERENCES factories(id) ON DELETE CASCADE,
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
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    factory_id UUID REFERENCES factories(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    employee_code VARCHAR(50) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    joining_date DATE NOT NULL DEFAULT CURRENT_DATE,
    department VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    batches_handled INT DEFAULT 0,
    orders_handled INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 14. NOTIFICATIONS
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    factory_id UUID REFERENCES factories(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    priority VARCHAR(20) DEFAULT 'MEDIUM' CHECK (priority IN ('HIGH', 'MEDIUM', 'LOW')),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 15. AUDIT LOGS
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    factory_id UUID REFERENCES factories(id) ON DELETE CASCADE,
    user_name VARCHAR(150) NOT NULL,
    user_role VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL,
    module VARCHAR(100) NOT NULL,
    record_affected VARCHAR(200) NOT NULL,
    details TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
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
CREATE INDEX IF NOT EXISTS idx_audit_timestamp ON audit_logs(timestamp);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE raw_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE production_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE quality_checks ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users access to factory data
CREATE POLICY "Allow authenticated read products" ON products FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated write products" ON products FOR ALL TO authenticated USING (true);

CREATE POLICY "Allow authenticated read batches" ON production_batches FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated write batches" ON production_batches FOR ALL TO authenticated USING (true);

CREATE POLICY "Allow authenticated read orders" ON sales_orders FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated write orders" ON sales_orders FOR ALL TO authenticated USING (true);
