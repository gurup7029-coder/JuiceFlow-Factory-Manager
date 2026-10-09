class AppConstants {
  static const String appName = 'JuiceFlow';
  static const String appFullName = 'JuiceFlow Factory Manager';
  static const String appTaglineEn = 'From Fresh Fruits to Smart Factory Management';
  static const String appTaglineTa = 'இயற்கைப் பழங்கள் முதல் நவீன தொழிற்சாலை மேலாண்மை வரை';
  static const String appVersion = '1.0.0';

  // Role Constants
  static const String roleAdmin = 'admin';
  static const String roleManager = 'manager';
  static const String roleProduction = 'production_staff';
  static const String roleInventory = 'inventory_staff';
  static const String roleSales = 'sales_staff';

  static const List<String> allRoles = [
    roleAdmin,
    roleManager,
    roleProduction,
    roleInventory,
    roleSales,
  ];

  // Supabase Configuration
  // Note: These can be configured in settings or environment variables
  static const String defaultSupabaseUrl = 'https://xyzcompany.supabase.co';
  static const String defaultSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_anon_key';

  // Product Categories
  static const List<String> productCategories = [
    'Pure Juice',
    'Nectar Blend',
    'Pulp Squash',
    'Cold Pressed',
    'Organic Fresh',
    'Carbonated Juice',
  ];

  // Raw Material Categories
  static const List<String> rawMaterialCategories = [
    'Fruits',
    'Sweeteners & Sugar',
    'Water & Minerals',
    'Preservatives & Citric',
    'Bottles (PET / Glass)',
    'Caps & Seals',
    'Labels & Stickers',
    'Carton Boxes',
  ];

  // Units
  static const List<String> measurementUnits = [
    'Kg',
    'Liters',
    'Grams',
    'Units / Pcs',
    'Cartons',
    'Rolls',
  ];

  // Bottle Sizes
  static const List<String> bottleSizes = [
    '200 ml',
    '250 ml',
    '300 ml',
    '500 ml',
    '1000 ml (1 Liter)',
    '2000 ml (2 Liters)',
  ];

  // Production Statuses
  static const String batchStatusPlanned = 'Planned';
  static const String batchStatusInProgress = 'In Progress';
  static const String batchStatusQualityCheck = 'Quality Check';
  static const String batchStatusCompleted = 'Completed';
  static const String batchStatusRejected = 'Rejected';
  static const String batchStatusCancelled = 'Cancelled';

  // Quality Statuses
  static const String qcStatusPassed = 'Passed';
  static const String qcStatusFailed = 'Failed';
  static const String qcStatusNeedsReview = 'Needs Review';
  static const String qcStatusPending = 'Pending';

  // Order Statuses
  static const String orderStatusNew = 'New';
  static const String orderStatusConfirmed = 'Confirmed';
  static const String orderStatusProcessing = 'Processing';
  static const String orderStatusPacked = 'Packed';
  static const String orderStatusDispatched = 'Dispatched';
  static const String orderStatusDelivered = 'Delivered';
  static const String orderStatusCancelled = 'Cancelled';

  // Payment Statuses
  static const String paymentStatusPaid = 'Paid';
  static const String paymentStatusPartial = 'Partial';
  static const String paymentStatusUnpaid = 'Unpaid';

  // Expense Categories
  static const List<String> expenseCategories = [
    'Raw Materials Purchase',
    'Electricity & Power',
    'Water Supply',
    'Transportation & Fuel',
    'Packaging Materials',
    'Machinery Maintenance',
    'Worker Salaries',
    'Factory Rent',
    'Marketing & Branding',
    'Miscellaneous',
  ];

  // Customer Types
  static const List<String> customerTypes = [
    'Retailer',
    'Wholesaler',
    'Supermarket',
    'Hotel & Resort',
    'Restaurant / Cafe',
    'Distributor',
    'Direct Consumer',
  ];
}
