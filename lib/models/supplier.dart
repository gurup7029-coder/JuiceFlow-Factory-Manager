class Supplier {
  final String id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String materialsSupplied; // e.g. "Alphonso Mangoes, Raw Pulp"
  final double outstandingAmount;
  final DateTime createdAt;

  Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    required this.materialsSupplied,
    this.outstandingAmount = 0.0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'materials_supplied': materialsSupplied,
      'outstanding_amount': outstandingAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      contactPerson: map['contact_person']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      materialsSupplied: map['materials_supplied']?.toString() ?? '',
      outstandingAmount: (map['outstanding_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }

  Supplier copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? materialsSupplied,
    double? outstandingAmount,
    DateTime? createdAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      materialsSupplied: materialsSupplied ?? this.materialsSupplied,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
