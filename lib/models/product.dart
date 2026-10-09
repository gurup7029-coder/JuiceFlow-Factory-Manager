class Product {
  final String id;
  final String name;
  final String tamilName;
  final String code;
  final String category;
  final String fruit;
  final String bottleSize;
  final String packagingType;
  final double sellingPrice;
  final double costPrice;
  final double gstRate; // in percent e.g. 12%
  final int minStockLevel;
  final int currentStock;
  final String? imageUrl;
  final bool isActive;

  Product({
    required this.id,
    required this.name,
    required this.tamilName,
    required this.code,
    required this.category,
    required this.fruit,
    required this.bottleSize,
    required this.packagingType,
    required this.sellingPrice,
    required this.costPrice,
    this.gstRate = 12.0,
    required this.minStockLevel,
    this.currentStock = 0,
    this.imageUrl,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'tamil_name': tamilName,
      'code': code,
      'category': category,
      'fruit': fruit,
      'bottle_size': bottleSize,
      'packaging_type': packagingType,
      'selling_price': sellingPrice,
      'cost_price': costPrice,
      'gst_rate': gstRate,
      'min_stock_level': minStockLevel,
      'current_stock': currentStock,
      'image_url': imageUrl,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      tamilName: map['tamil_name']?.toString() ?? '',
      code: map['code']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Pure Juice',
      fruit: map['fruit']?.toString() ?? '',
      bottleSize: map['bottle_size']?.toString() ?? '500 ml',
      packagingType: map['packaging_type']?.toString() ?? 'PET Bottle',
      sellingPrice: (map['selling_price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0.0,
      gstRate: (map['gst_rate'] as num?)?.toDouble() ?? 12.0,
      minStockLevel: (map['min_stock_level'] as num?)?.toInt() ?? 50,
      currentStock: (map['current_stock'] as num?)?.toInt() ?? 0,
      imageUrl: map['image_url']?.toString(),
      isActive: map['is_active'] == 1 || map['is_active'] == true,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? tamilName,
    String? code,
    String? category,
    String? fruit,
    String? bottleSize,
    String? packagingType,
    double? sellingPrice,
    double? costPrice,
    double? gstRate,
    int? minStockLevel,
    int? currentStock,
    String? imageUrl,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      tamilName: tamilName ?? this.tamilName,
      code: code ?? this.code,
      category: category ?? this.category,
      fruit: fruit ?? this.fruit,
      bottleSize: bottleSize ?? this.bottleSize,
      packagingType: packagingType ?? this.packagingType,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      costPrice: costPrice ?? this.costPrice,
      gstRate: gstRate ?? this.gstRate,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      currentStock: currentStock ?? this.currentStock,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
