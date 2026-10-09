# 🥤 JuiceFlow Factory Manager
> **"From Fresh Fruits to Smart Factory Management."**  
> *"இயற்கைப் பழங்கள் முதல் நவீன தொழிற்சாலை மேலாண்மை வரை"*

A production-grade, enterprise-class Flutter mobile application engineered for juice manufacturing plants, beverage processing units, and agro-food packaging businesses.

---

## 🌟 Key Highlights & Real-World Features

- **Multi-Role Factory Operations:** Tailored views and permissions for **Factory Owner (Admin)**, **Factory Manager**, **Production Supervisor**, **Inventory Keeper**, and **Sales Executive**.
- **100% Bilingual (English & தமிழ்):** Native language switcher for all navigation, metrics, recipes, orders, alerts, and settings—accessible for grassroots and village factory workers.
- **Batch Traceability & QR Codes:** Unique batch ID generation, QR code packaging labels, and built-in camera/visual QR code batch scanner.
- **Beverage Quality Control (QC/QA):** In-depth testing parameters: Brix refractometer sugar reading (°Bx), pH level testing, temperature (°C), organoleptic sensory testing (appearance, aroma, taste), and induction seal integrity.
- **Offline-First Resilience:** Fully operational on local SQLite database even without internet in rural processing centers; gracefully syncs with Supabase PostgreSQL cloud backend.
- **Sales & Automatic Invoicing:** GST Tax Invoice generation with instant PDF export, direct sharing, and thermal/A4 printing support.
- **Automated USB Deployment (`run_on_phone.bat`):** 1-click batch script that detects connected Android phones via ADB, verifies code quality, builds the APK, installs it, and launches the app automatically.
- **Zero-Warning Clean Architecture:** Strictly analyzed using `dart analyze lib` (0 errors, 0 warnings).

---

## 🏗️ Architecture & Technology Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.47+ / Dart 3.13+ |
| **Design System** | Material 3 (White Base + Fresh Green + Citrus Orange + Dark Charcoal) |
| **State Management** | Provider (`ChangeNotifier`) with decoupled service layer |
| **Local Database** | SQLite via `sqflite` (Offline-first architecture) |
| **Cloud Backend** | Supabase (PostgreSQL with Row Level Security) |
| **Visual Analytics** | `fl_chart` (Weekly Liters Output, Monthly Revenue) |
| **Document Engine** | `pdf` & `printing` (Tax Invoices & Executive PDF reports) |
| **Data Interchange**| RFC-4180 CSV Export (`share_plus`, `path_provider`) |
| **Traceability** | `qr_flutter` (Batch QR generation & parsing) |
| **Localization** | `flutter_localizations`, `intl` (English & தமிழ்) |

---

## 📁 Project Folder Structure

```
c:/projects/Juice shop/
├── android/                   # Native Android host & Gradle configuration
├── database/
│   └── schema.sql             # Supabase & PostgreSQL database migration script
├── docs/                      # Enterprise & MCA Academic documentation suite
│   ├── 01_PROJECT_OVERVIEW.md
│   ├── 02_REQUIREMENTS_SPECIFICATION.md
│   ├── 03_SYSTEM_ARCHITECTURE.md
│   ├── 04_DATABASE_DESIGN_AND_SUPABASE.md
│   ├── 05_USER_ROLES_AND_PERMISSIONS.md
│   ├── 06_PRODUCTION_AND_FACTORY_WORKFLOW.md
│   ├── 07_INSTALLATION_AND_DEPLOYMENT_GUIDE.md
│   ├── 08_TESTING_AND_VERIFICATION.md
│   ├── 09_FUTURE_ENHANCEMENTS.md
│   └── 10_MCA_ACADEMIC_PROJECT_REPORT.md
├── lib/
│   ├── core/
│   │   ├── constants/         # AppConstants, roles, categories, defaults
│   │   ├── localization/      # English & Tamil dictionary & delegates
│   │   ├── services/          # DatabaseHelper, SupabaseService, PdfInvoiceService, etc.
│   │   ├── theme/             # Material 3 light/dark palettes & typography
│   │   └── utils/             # Formatters (INR currency, dates, quantities)
│   ├── models/                # Product, Batch, QC, Order, Customer, Supplier, Expense, Staff
│   ├── providers/             # AppStateProvider & FactoryDataProvider
│   ├── screens/
│   │   ├── auth/              # Role-aware LoginScreen
│   │   ├── dashboard/         # Executive Dashboard & Charts
│   │   ├── production/        # Batch List, Creation, Details & QC Inspection
│   │   ├── inventory/         # Raw Materials, Packaging, Finished Goods & Movement Log
│   │   ├── products/          # Beverage Catalog & Formulation
│   │   ├── orders/            # Order Management & PDF Invoicing
│   │   ├── customers/         # Retailers & Distributors CRM
│   │   ├── suppliers/         # Fruit Orchards & Vendor Supply Chain
│   │   ├── expenses/          # Factory Utilities & Wages Tracker
│   │   ├── reports/           # Productivity Analytics & CSV/PDF Export
│   │   ├── staff/             # Workforce Management
│   │   ├── notifications/     # Smart Alerts Center
│   │   ├── audit/             # Traceable Audit Trail
│   │   ├── settings/          # Factory Profile, Language & Sync Settings
│   │   ├── setup/             # 7-Step Setup Wizard
│   │   ├── onboarding/        # Modern Onboarding Walkthrough
│   │   └── splash_screen.dart # Animated Branding Splash Screen
│   ├── widgets/               # Reusable Cards, Badges, Header, QR Scanner & Dialogs
│   └── main.dart              # Application Bootstrap
├── pubspec.yaml               # Dependencies & Asset configuration
├── run_on_phone.bat           # 1-Click Automated Android Phone Deployment
└── README.md                  # Project Documentation
```

---

## 🚀 How to Run & Deploy

### Option 1: Automated 1-Click USB Deployment to Android Phone
1. Connect your Android phone to your PC via USB cable.
2. Enable **Developer Options** and **USB Debugging** on your phone.
3. Double-click or run from terminal:
   ```cmd
   run_on_phone.bat
   ```
4. The script will:
   - Locate Android SDK ADB dynamically.
   - Verify device authorization.
   - Run `dart analyze lib` (0 errors check).
   - Build `build\app\outputs\flutter-apk\app-debug.apk`.
   - Install the APK on your device.
   - Automatically launch **JuiceFlow** on your phone screen!

### Option 2: Running via Flutter CLI
```bash
# Verify environment
flutter doctor

# Check available devices
flutter devices

# Run in debug mode
flutter run
```

---

## 🔒 Security & Offline-First Design

- **Offline-First by Design:** Works smoothly in rural factories without dependable broadband. All transactions, production logs, quality approvals, and customer orders are committed locally to SQLite.
- **Supabase Cloud Synchronization:** Automatic sync to remote PostgreSQL when connectivity is available.
- **Audit History:** Every critical transaction (e.g. stock adjustment, batch completion, order dispatch) is permanently logged with timestamp, user ID, role, and details.
