# 02. Functional & Non-Functional Requirements Specification

## 1. Functional Requirements (FR)

### FR-01: User Authentication & Role-Based Access Control
- Support five primary roles: **Admin / Factory Owner**, **Manager**, **Production Staff**, **Inventory Staff**, and **Sales Staff**.
- Seamless switching between user roles for testing and evaluation.

### FR-02: Executive Factory Dashboard
- Real-time display of daily production volume (Liters), sales revenue (₹ INR), active batches, low-stock alerts, pending orders, and unpaid receivables.
- Interactive graphical charts showing 7-day production volume and monthly revenue performance.

### FR-03: Product Catalog & Recipe Formulation
- Management of juice varieties with English and Tamil names, SKU codes, categories, fruit types, bottle sizes (200ml, 500ml, 1000ml), selling price, cost price, and GST rates.

### FR-04: Raw Material & Packaging Inventory
- Track stock quantities, measurement units, purchase prices, lot numbers, purchase dates, expiry dates, and storage locations (e.g., Cold Storage Room A).
- Automatic low-stock warnings and expiring stock alerts.

### FR-05: Production Batch Workflow
- End-to-end production stage management: `Planned` ➔ `In Progress` ➔ `Quality Check` ➔ `Completed` / `Rejected`.
- Automatic deduction of raw ingredients and automatic increment of finished goods inventory upon batch completion.

### FR-06: Quality Control (QC/QA)
- Food & beverage laboratory inspection capturing Brix sugar levels (°Bx), pH readings, temperature (°C), organoleptic sensory testing, and bottle seal integrity.

### FR-07: Sales Orders & Tax Invoicing
- Order creation with dynamic product selection, quantity pricing, discounts, and GST calculations.
- Automatic generation of professional PDF Tax Invoices adhering to Indian commercial standards.

### FR-08: Financial & Expense Tracking
- Category-wise logging of operational costs (raw materials, electricity, boiler maintenance, logistics, salaries, etc.).

### FR-09: Reports & Data Export
- Export of production batches, sales orders, expenses, and inventory to standard RFC-4180 CSV files.
- Export of comprehensive executive factory performance reports to PDF format.

---

## 2. Non-Functional Requirements (NFR)

- **Performance:** App launch in under 2 seconds; instant local query execution via SQLite.
- **Reliability & Offline-First:** 100% operational autonomy offline with graceful cloud synchronization.
- **Security:** RLS policies on Supabase PostgreSQL; local sanitization; no hardcoded API secrets.
- **Maintainability:** Modular architecture passing `dart analyze lib` with zero warnings and zero errors.
