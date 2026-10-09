class RawMaterial {
  final String id;
  final String name;
  final String tamilName;
  final String category;
  final String supplierId;
  final String supplierName;
  final double quantity;
  final String unit; // Kg, Liters, Units, Cartons
  final double purchasePrice; // per unit
  final String batchNumber;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final double minStockLevel;
  final String storageLocation;

  RawMaterial({
    required this.id,
    required this.name,
    required this.tamilName,
    required this.category,
    required this.supplierId,
    required this.supplierName,
    required this.quantity,
    required this.unit,
    required this.purchasePrice,
    required this.batchNumber,
    required this.purchaseDate,
    required this.expiryDate,
    required this.minStockLevel,
    required this.storageLocation,
  });

  bool get isLowStock => quantity <= minStockLevel;
  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isExpiringSoon {
    final diff = expiryDate.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 10;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'tamil_name': tamilName,
      'category': category,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'quantity': quantity,
      'unit': unit,
      'purchase_price': purchasePrice,
      'batch_number': batchNumber,
      'purchase_date': purchaseDate.toIso8601String(),
      'expiry_date': expiryDate.toIso8601String(),
      'min_stock_level': minStockLevel,
      'storage_location': storageLocation,
    };
  }

  factory RawMaterial.fromMap(Map<String, dynamic> map) {
    return RawMaterial(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      tamilName: map['tamil_name']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Fruits',
      supplierId: map['supplier_id']?.toString() ?? '',
      supplierName: map['supplier_name']?.toString() ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit']?.toString() ?? 'Kg',
      purchasePrice: (map['purchase_price'] as num?)?.toDouble() ?? 0.0,
      batchNumber: map['batch_number']?.toString() ?? '',
      purchaseDate: map['purchase_date'] != null
          ? DateTime.parse(map['purchase_date'].toString())
          : DateTime.now(),
      expiryDate: map['expiry_date'] != null
          ? DateTime.parse(map['expiry_date'].toString())
          : DateTime.now().add(const Duration(days: 30)),
      minStockLevel: (map['min_stock_level'] as num?)?.toDouble() ?? 20.0,
      storageLocation: map['storage_location']?.toString() ?? 'Cold Room 1',
    );
  }

  RawMaterial copyWith({
    String? id,
    String? name,
    String? tamilName,
    String? category,
    String? supplierId,
    String? supplierName,
    double? quantity,
    String? unit,
    double? purchasePrice,
    String? batchNumber,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    double? minStockLevel,
    String? storageLocation,
  }) {
    return RawMaterial(
      id: id ?? this.id,
      name: name ?? this.name,
      tamilName: tamilName ?? this.tamilName,
      category: category ?? this.category,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      batchNumber: batchNumber ?? this.batchNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      storageLocation: storageLocation ?? this.storageLocation,
    );
  }
}
