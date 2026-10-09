class Customer {
  final String id;
  final String name;
  final String businessName;
  final String phone;
  final String email;
  final String address;
  final String customerType; // Retailer, Wholesaler, Supermarket, Hotel, etc.
  final double outstandingBalance;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.businessName,
    required this.phone,
    required this.email,
    required this.address,
    required this.customerType,
    this.outstandingBalance = 0.0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'business_name': businessName,
      'phone': phone,
      'email': email,
      'address': address,
      'customer_type': customerType,
      'outstanding_balance': outstandingBalance,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      businessName: map['business_name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      customerType: map['customer_type']?.toString() ?? 'Retailer',
      outstandingBalance: (map['outstanding_balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }

  Customer copyWith({
    String? id,
    String? name,
    String? businessName,
    String? phone,
    String? email,
    String? address,
    String? customerType,
    double? outstandingBalance,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      customerType: customerType ?? this.customerType,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
