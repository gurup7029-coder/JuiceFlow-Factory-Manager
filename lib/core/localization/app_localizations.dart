import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App & Branding
      'appName': 'JuiceFlow Factory Manager',
      'tagline': 'From Fresh Fruits to Smart Factory Management',
      'factoryName': 'FreshVibe Juice Industries',

      // Navigation
      'dashboard': 'Dashboard',
      'production': 'Production',
      'inventory': 'Inventory',
      'orders': 'Orders',
      'more': 'More',

      // More Menu & Common Modules
      'products': 'Products',
      'rawMaterials': 'Raw Materials',
      'suppliers': 'Suppliers',
      'customers': 'Customers',
      'expenses': 'Expenses',
      'reports': 'Reports',
      'staff': 'Staff & Workers',
      'notifications': 'Alerts & Notifications',
      'settings': 'Settings',
      'auditLog': 'Audit Trail',
      'qualityControl': 'Quality Control',
      'batchTracker': 'Batch QR Tracker',

      // Roles
      'roleAdmin': 'Factory Owner (Admin)',
      'roleManager': 'Factory Manager',
      'roleProduction': 'Production Supervisor',
      'roleInventory': 'Inventory In-Charge',
      'roleSales': 'Sales Executive',
      'switchRole': 'Switch Role Mode',

      // Actions
      'add': 'Add',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'view': 'View',
      'search': 'Search...',
      'filter': 'Filter',
      'exportPdf': 'Export PDF',
      'exportCsv': 'Export CSV',
      'scanQr': 'Scan QR Code',
      'viewQr': 'View QR Code',
      'refresh': 'Refresh',
      'confirm': 'Confirm',
      'submit': 'Submit',
      'createBatch': 'Create Batch',
      'addStock': 'Add Stock',
      'newOrder': 'New Order',
      'addExpense': 'Add Expense',
      'generateInvoice': 'Generate Invoice',
      'printInvoice': 'Print / Share',

      // Dashboard Metrics
      'todayProduction': "Today's Production",
      'todaySales': "Today's Sales",
      'activeBatches': 'Batches Running',
      'lowStockItems': 'Low Stock Alerts',
      'pendingOrders': 'Pending Orders',
      'pendingPayments': 'Pending Payments',
      'monthlyTurnover': 'Monthly Revenue',
      'productionEfficiency': 'Production Efficiency',
      'wastageRate': 'Wastage Rate',
      'quickActions': 'Quick Factory Actions',
      'recentActivity': 'Recent Factory Activity',
      'weeklyProductionTrend': 'Weekly Production (Liters)',
      'salesPerformance': 'Monthly Sales Overview',

      // Production Flow
      'batchNumber': 'Batch Number',
      'product': 'Product',
      'plannedQty': 'Planned Quantity',
      'actualQty': 'Actual Produced',
      'wastage': 'Wastage',
      'ingredientsUsed': 'Raw Materials Used',
      'startTime': 'Start Time',
      'endTime': 'End Time',
      'assignedStaff': 'Assigned Operator',
      'productionStatus': 'Production Status',
      'qcStatus': 'Quality Status',
      'batchNotes': 'Batch Notes',
      'startProduction': 'Start Production',
      'sendToQc': 'Send to Quality Check',
      'completeBatch': 'Complete & Add to Stock',

      // Statuses
      'statusPlanned': 'Planned',
      'statusInProgress': 'In Progress',
      'statusQualityCheck': 'Quality Check',
      'statusCompleted': 'Completed',
      'statusRejected': 'Rejected',
      'statusCancelled': 'Cancelled',

      // Quality Control
      'qcInspection': 'QC Batch Inspection',
      'appearance': 'Appearance / Clarity',
      'colour': 'Natural Fruit Colour',
      'taste': 'Taste & Sweetness',
      'smell': 'Aroma & Smell',
      'phValue': 'pH Level',
      'temperature': 'Temperature (°C)',
      'brixSugar': 'Brix / Sugar (°Bx)',
      'packagingSeal': 'Bottle Seal Integrity',
      'qcRemarks': 'QC Remarks / Notes',
      'qcInspector': 'Quality Inspector',
      'passed': 'Passed (Approved)',
      'failed': 'Failed (Rejected)',
      'needsReview': 'Needs Review',

      // Inventory
      'finishedGoods': 'Finished Goods',
      'packagingMaterials': 'Packaging',
      'currentStock': 'Available Stock',
      'minStock': 'Reorder Level',
      'stockHealth': 'Stock Health',
      'healthyStock': 'Healthy Stock',
      'lowStock': 'Low Stock',
      'criticalStock': 'Critical Alert',
      'expired': 'Expired',
      'unit': 'Unit',
      'expiryDate': 'Expiry Date',
      'storageLocation': 'Storage Location',

      // Sales & Invoices
      'orderId': 'Order ID',
      'customer': 'Customer',
      'orderDate': 'Order Date',
      'totalAmount': 'Total Amount',
      'discount': 'Discount',
      'tax': 'GST / Tax',
      'grandTotal': 'Grand Total',
      'paymentStatus': 'Payment Status',
      'deliveryStatus': 'Delivery Status',
      'paid': 'Paid',
      'unpaid': 'Unpaid',
      'partial': 'Partial',

      // Settings & Language
      'language': 'Language',
      'english': 'English',
      'tamil': 'தமிழ் (Tamil)',
      'theme': 'Theme Mode',
      'themeLight': 'Light Mode',
      'themeDark': 'Dark Mode',
      'themeSystem': 'System Default',
      'factoryProfile': 'Factory Profile',
      'dataManagement': 'Data & Offline Backup',
      'syncStatus': 'Cloud Sync Status',
      'synced': 'Synced with Cloud',
      'offlineMode': 'Offline Mode (Local Storage)',
      'seedSampleData': 'Load Factory Demo Data',
      'clearData': 'Reset Local Data',
      'aboutApp': 'About JuiceFlow',
      'logout': 'Sign Out',

      // Helpful Village / Grassroots Messages
      'villageFriendlyHelp':
          'Designed for easy factory use. Tap large cards to quickly record juice production, check fruits, or generate bills.',
      'noDataYet': 'No records found. Tap "+" button below to add.',
      'successSaved': 'Saved successfully!',
      'confirmDelete': 'Are you sure you want to delete this item?',
    },
    'ta': {
      // App & Branding
      'appName': 'ஜூஸ்ப்ளோ தொழிற்சாலை மேலாளர்',
      'tagline': 'இயற்கைப் பழங்கள் முதல் நவீன தொழிற்சாலை மேலாண்மை வரை',
      'factoryName': 'ஃப்ரெஷ்வைப் ஜூஸ் இண்டஸ்ட்ரீஸ்',

      // Navigation
      'dashboard': 'டாஷ்போர்டு',
      'production': 'உற்பத்தி',
      'inventory': 'சரக்கு இருப்பு',
      'orders': 'ஆர்டர்கள்',
      'more': 'கூடுதல்',

      // More Menu & Common Modules
      'products': 'தயாரிப்புகள்',
      'rawMaterials': 'மூலப்பொருட்கள்',
      'suppliers': 'விற்பனையாளர்கள்',
      'customers': 'வாடிக்கையாளர்கள்',
      'expenses': 'செலவுகள்',
      'reports': 'அறிக்கைகள்',
      'staff': 'தொழிலாளர்கள்',
      'notifications': 'எச்சரிக்கைகள்',
      'settings': 'அமைப்புகள்',
      'auditLog': 'செயல்பாட்டு பதிவு',
      'qualityControl': 'தரக் கட்டுப்பாடு',
      'batchTracker': 'பேட்ச் QR டிராக்கர்',

      // Roles
      'roleAdmin': 'தொழிற்சாலை உரிமையாளர் (Admin)',
      'roleManager': 'மேலாளர் (Manager)',
      'roleProduction': 'உற்பத்தி மேற்பார்வையாளர்',
      'roleInventory': 'சரக்கு காப்பாளர்',
      'roleSales': 'விற்பனை அலுவலர்',
      'switchRole': 'பொறுப்பை மாற்றவும்',

      // Actions
      'add': 'சேர்',
      'save': 'சேமிக்க',
      'cancel': 'ரத்து',
      'delete': 'நீக்கு',
      'edit': 'திருத்து',
      'view': 'பார்வையிடு',
      'search': 'தேடுக...',
      'filter': 'வடிகட்டு',
      'exportPdf': 'PDF பதிவிறக்கு',
      'exportCsv': 'CSV பதிவிறக்கு',
      'scanQr': 'QR ஸ்கேன் செய்',
      'viewQr': 'QR குறியீடு பார்',
      'refresh': 'புதுப்பி',
      'confirm': 'உறுதி செய்',
      'submit': 'சமர்ப்பி',
      'createBatch': 'புதிய பேட்ச் தொடங்கு',
      'addStock': 'சரக்கு சேர்',
      'newOrder': 'புதிய ஆர்டர்',
      'addExpense': 'செலவு சேர்',
      'generateInvoice': 'பில் தயாரி',
      'printInvoice': 'பில் அச்சிடு / பகிர்',

      // Dashboard Metrics
      'todayProduction': 'இன்றைய உற்பத்தி',
      'todaySales': 'இன்றைய விற்பனை',
      'activeBatches': 'நடக்கும் பேட்ச்கள்',
      'lowStockItems': 'குறைந்த இருப்பு எச்சரிக்கை',
      'pendingOrders': 'நிலுவை ஆர்டர்கள்',
      'pendingPayments': 'வரவேண்டிய பாக்கி',
      'monthlyTurnover': 'மாத வருவாய்',
      'productionEfficiency': 'உற்பத்தி திறன்',
      'wastageRate': 'சேதாரம் / கழிவு %',
      'quickActions': 'விரைவு செயல்பாடுகள்',
      'recentActivity': 'சமீபத்திய நிகழ்வுகள்',
      'weeklyProductionTrend': 'வாராந்திர உற்பத்தி (லிட்டர்)',
      'salesPerformance': 'மாதாந்திர விற்பனை கண்ணோட்டம்',

      // Production Flow
      'batchNumber': 'பேட்ச் எண்',
      'product': 'தயாரிப்பு பொருள்',
      'plannedQty': 'திட்டமிட்ட அளவு',
      'actualQty': 'உண்மையான உற்பத்தி',
      'wastage': 'கழிவு / சேதாரம்',
      'ingredientsUsed': 'பயன்படுத்திய பழங்கள் & பொருட்கள்',
      'startTime': 'தொடக்க நேரம்',
      'endTime': 'முடிவு நேரம்',
      'assignedStaff': 'பொறுப்பு பணியாளர்',
      'productionStatus': 'உற்பத்தி நிலை',
      'qcStatus': 'தர பரிசோதனை நிலை',
      'batchNotes': 'குறிப்புகள்',
      'startProduction': 'உற்பத்தியை தொடங்கு',
      'sendToQc': 'தர பரிசோதனைக்கு அனுப்பு',
      'completeBatch': 'முடித்து சரக்கில் சேர்',

      // Statuses
      'statusPlanned': 'திட்டமிடப்பட்டது',
      'statusInProgress': 'உற்பத்தியில் உள்ளது',
      'statusQualityCheck': 'தர பரிசோதனை',
      'statusCompleted': 'முழுமையடைந்தது',
      'statusRejected': 'நிராகரிக்கப்பட்டது',
      'statusCancelled': 'ரத்து செய்யப்பட்டது',

      // Quality Control
      'qcInspection': 'பேட்ச் தர பரிசோதனை',
      'appearance': 'தோற்றம் / தெளிவு',
      'colour': 'இயற்கை நிறம்',
      'taste': 'சுவை & இனிப்பு',
      'smell': 'நறுமணம்',
      'phValue': 'pH அளவு',
      'temperature': 'வெப்பநிலை (°C)',
      'brixSugar': 'சர்க்கரை அளவு (°Bx)',
      'packagingSeal': 'பாட்டில் மூடி அடைப்பு',
      'qcRemarks': 'பரிசோதனை குறிப்பு',
      'qcInspector': 'தர ஆய்வாளர்',
      'passed': 'வெற்றி (அங்கீகரிக்கப்பட்டது)',
      'failed': 'தோல்வி (நிராகரிப்பு)',
      'needsReview': 'மறுபரிசீலனை தேவை',

      // Inventory
      'finishedGoods': 'தயாரான பாட்டில்கள்',
      'packagingMaterials': 'பேக்கிங் பொருட்கள்',
      'currentStock': 'கையிருப்பு அளவு',
      'minStock': 'குறைந்தபட்ச இருப்பு',
      'stockHealth': 'இருப்பு நிலை',
      'healthyStock': 'போதுமான இருப்பு',
      'lowStock': 'குறைந்த இருப்பு',
      'criticalStock': 'அவசர எச்சரிக்கை',
      'expired': 'காலாவதி ஆனது',
      'unit': 'அளவு முறை',
      'expiryDate': 'காலாவதி தேதி',
      'storageLocation': 'இருப்பிடம்',

      // Sales & Invoices
      'orderId': 'ஆர்டர் எண்',
      'customer': 'வாடிக்கையாளர்',
      'orderDate': 'ஆர்டர் தேதி',
      'totalAmount': 'மொத்தத் தொகை',
      'discount': 'தள்ளுபடி',
      'tax': 'வரி (GST)',
      'grandTotal': 'இறுதித் தொகை',
      'paymentStatus': 'பண நிலை',
      'deliveryStatus': 'விநியோக நிலை',
      'paid': 'செலுத்தப்பட்டது',
      'unpaid': 'செலுத்தப்படவில்லை',
      'partial': 'பகுதி தொகை',

      // Settings & Language
      'language': 'மொழி (Language)',
      'english': 'English (ஆங்கிலம்)',
      'tamil': 'தமிழ் (Tamil)',
      'theme': 'வண்ண அமைப்பு',
      'themeLight': 'பகல் முறை (வெளிச்சம்)',
      'themeDark': 'இரவு முறை (டார்க்)',
      'themeSystem': 'கைபேசி முறை',
      'factoryProfile': 'தொழிற்சாலை சுயவிவரம்',
      'dataManagement': 'தரவு & காப்புப்பிரதி',
      'syncStatus': 'கிளவுட் ஒத்திசைவு',
      'synced': 'கிளவுடில் இணைக்கப்பட்டுள்ளது',
      'offlineMode': 'ஆஃப்லைன் முறை (உள்ளக சேமிப்பு)',
      'seedSampleData': 'மாதிரி தொழிற்சாலை தரவு ஏற்று',
      'clearData': 'தரவை மீட்டமை',
      'aboutApp': 'செயலி பற்றி',
      'logout': 'வெளியேறு',

      // Helpful Village / Grassroots Messages
      'villageFriendlyHelp':
          'எளிய தொழிற்சாலை பயன்பாட்டிற்கு ஏற்றது. பழச்சாறு உற்பத்தி, சரக்கு இருப்பு மற்றும் பில் தயாரிக்க எளிய பொத்தான்களைத் தொடவும்.',
      'noDataYet': 'எந்த பதிவுகளும் இல்லை. சேர்க்க கீழே உள்ள "+" தொடவும்.',
      'successSaved': 'வெற்றிகரமாக சேமிக்கப்பட்டது!',
      'confirmDelete': 'நிச்சயமாக இதை நீக்க விரும்புகிறீர்களா?',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ta'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
