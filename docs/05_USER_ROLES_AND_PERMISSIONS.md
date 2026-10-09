# 05. User Roles & Permission Matrix

| Role | Dashboard | Production | Inventory | Orders & Billing | Expenses | Audit Logs | Settings |
|---|---|---|---|---|---|---|---|
| **Admin (Factory Owner)** | Full View & Analytics | Full Access | Full Access | Full Access | Full Access | Full Access | Full Access |
| **Factory Manager** | Operational View | Full Access | Full Access | Full Access | View & Add | View Only | Limited |
| **Production Staff** | Production Metrics | Create & Update Batches | View Stock | No Access | No Access | No Access | No Access |
| **Inventory Staff** | Stock Metrics | View Batches | Adjust Stock & Materials | View Orders | No Access | No Access | No Access |
| **Sales Staff** | Sales Metrics | No Access | View Finished Stock | Create & Print Invoices | No Access | No Access | No Access |

---

# 06. Juice Factory Manufacturing Workflow

```
[1. RAW FRUIT LOT ARRIVAL]
       │
       ▼
[2. LOT REGISTRATION & COLD STORAGE] (Cold Room A / B, Expiry Date logged)
       │
       ▼
[3. BATCH CREATION & SCHEDULING] (Batch Code e.g. BATCH-2026-MNG-101)
       │
       ▼
[4. PROCESSING & BLENDING] (Heating, Sugar Syrup formulation, Pasteurization at 85°C)
       │
       ▼
[5. BOTTLING & SEALING] (PET / Glass Bottles, Cap Torque Induction Seal)
       │
       ▼
[6. QUALITY ASSURANCE INSPECTION] (Brix Refractometer, pH testing, Sensory & Clarity test)
       │
       ├─► Passed  ──► [7. FINISHED GOODS WAREHOUSE] ──► [8. CUSTOMER SALES DISPATCH]
       │
       └─► Failed  ──► [REJECTED / SEGREGATED REWORK]
```
