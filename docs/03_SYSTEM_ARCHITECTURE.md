# 03. System Architecture & Technical Design

## 1. Architectural Pattern: Clean Offline-First Architecture
JuiceFlow Factory Manager employs a **Clean Layered Architecture** with reactive state management powered by Flutter Provider (`ChangeNotifier`).

```
+-------------------------------------------------------------+
|                      PRESENTATION LAYER                     |
|  - Screens (Dashboard, Production, Inventory, Orders, etc.) |
|  - Custom Widgets (CustomCard, StatBadge, MetricTile)       |
|  - Bilingual Localization (English & தமிழ்)                 |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|                     STATE MANAGEMENT LAYER                  |
|  - AppStateProvider (User Role, Language, Theme, Profile)   |
|  - FactoryDataProvider (Products, Batches, Inventory, Orders)|
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|                      SERVICE & DOMAIN LAYER                 |
|  - DatabaseHelper (SQLite Local Storage Engine)             |
|  - SupabaseService (Cloud PostgreSQL & Sync Manager)        |
|  - PdfInvoiceService & ReportExportService                  |
|  - QrService (Batch Serialization & Parsing)                |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|                      PERSISTENCE LAYER                      |
|  - Local: SQLite (juiceflow_factory.db)                     |
|  - Cloud: Supabase (PostgreSQL with RLS)                    |
+-------------------------------------------------------------+
```

## 2. Key Modules Interaction
1. **Production to Inventory:** When a production batch is marked `Completed`, the system automatically increments the target product's finished stock and logs a traceable stock movement.
2. **Orders to Inventory:** When a sales order is confirmed and created, the requested quantities are automatically deducted from the finished stock.
3. **Traceability:** Each batch encapsulates ingredients used, supplier references, operator ID, and links to subsequent quality inspection records.
