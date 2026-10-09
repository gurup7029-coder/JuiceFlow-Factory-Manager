# 04. Database Design & Supabase Cloud Integration

## 1. Database Architecture
JuiceFlow uses a synchronized hybrid database architecture:
- **Client Side (Edge):** Local SQLite (`juiceflow_factory.db`) managed via `sqflite`.
- **Cloud Side:** Supabase managed PostgreSQL instance with normalized relations and Row Level Security (RLS).

## 2. Entity Relationship Diagram (ERD) Overview

```
+---------------+        1:N       +-------------------+
|   factories   | ---------------- |     products      |
+---------------+                  +-------------------+
        |                                    | 1:N
        | 1:N                                v
+---------------+                  +-------------------+
| raw_materials |                  |production_batches |
+---------------+                  +-------------------+
        ^                                    | 1:1
        |                                    v
+---------------+                  +-------------------+
|   suppliers   |                  |  quality_checks   |
+---------------+                  +-------------------+
                                             |
                                             v
+---------------+        1:N       +-------------------+
|   customers   | ---------------- |   sales_orders    |
+---------------+                  +-------------------+
```

## 3. Database Tables
1. **`factories`**: Multi-tenant factory metadata, FSSAI registration, GSTIN, and corporate profile.
2. **`products`**: Finished juice beverage SKUs, bottle sizes, pricing, and stock buffers.
3. **`raw_materials`**: Pulp, fruit extracts, sugar, bottles, caps, and labels.
4. **`production_batches`**: Manufacturing runs, recipe formulas, operator assignments, and output volumes.
5. **`quality_checks`**: Food technologist inspection records (Brix, pH, temperature, organoleptics).
6. **`suppliers` & `customers`**: B2B supply chain directory and customer accounts.
7. **`sales_orders`**: Commercial orders, delivery tracking, and invoice itemizations.
8. **`expenses`**: Factory overheads, utilities, power bills, and maintenance.
9. **`staff`**: Worker directory and productivity counters.
10. **`audit_logs`**: Permanent compliance log of all system changes.
