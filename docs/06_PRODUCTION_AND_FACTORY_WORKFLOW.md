# 06. Juice Factory Manufacturing Workflow

## 1. Complete Beverage Production Lifecycle

### Stage 1: Raw Material Receiving & Cold Storage
- Raw materials (e.g. Alphonso Mango pulp, orange concentrates, food-grade sugar, PET bottles, tamper-evident caps) arrive from approved agricultural orchards or packaging suppliers.
- Staff records supplier name, purchase invoice, batch/lot number, unit price, quantity, and expiry date.
- Materials are assigned to specific storage locations (Cold Storage Room A/B or Dry Packaging Bay).

### Stage 2: Batch Scheduling & Recipe Formulation
- Production supervisor initiates a batch for a specific juice SKU (e.g., 500ml Alphonso Mango Juice).
- System auto-generates a unique batch number conforming to food manufacturing standards (`BATCH-YYYY-FLV-XXX`).
- Recipe proportions are calculated (Pulp, Refined Sugar, Treated Water, Citric Acid).
- Batch status moves to `In Progress`.

### Stage 3: Pasteurization & Bottling
- Processing equipment heats juice to pasteurization temperature (~85°C) to eliminate microbiological contaminants.
- Juice is hot-filled into sterilized bottles, capped, induction heat-sealed, and cooled.
- Production volume and wastage are recorded.

### Stage 4: Quality Control & Sensory Verification
- Food technologist / QC inspector draws sample bottles for laboratory testing.
- Key parameters verified:
  - **Brix (°Bx):** Refractometer sugar concentration (target 11.5°Bx – 14.5°Bx).
  - **pH Level:** Acidity stability (target 3.2 – 4.2).
  - **Temperature:** Cold chain maintenance (< 4.5°C).
  - **Organoleptics:** Fruit aroma, color brilliance, and clarity.
  - **Packaging Integrity:** Vacuum leak test on induction seal.
- Outcome marked as `Passed`, `Failed`, or `Needs Review`.

### Stage 5: Finished Goods Inventory & QR Code Labeling
- Approved batches automatically increment finished goods inventory.
- Batch QR codes are generated containing batch ID, product name, production and expiry dates.
- QR labels are printed and affixed to outer shipping cartons.

### Stage 6: Sales Dispatch & Invoicing
- Sales orders are confirmed, picked, packed into cartons, and dispatched via delivery vans.
- System automatically generates a GST Tax Invoice (PDF).
