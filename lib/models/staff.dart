class Staff {
  final String id;
  final String name;
  final String employeeCode;
  final String role; // admin, manager, production_staff, inventory_staff, sales_staff
  final String phone;
  final String email;
  final DateTime joiningDate;
  final String department;
  final bool isActive;
  final int batchesHandled;
  final int ordersHandled;

  Staff({
    required this.id,
    required this.name,
    required this.employeeCode,
    required this.role,
    required this.phone,
    required this.email,
    required this.joiningDate,
    required this.department,
    this.isActive = true,
    this.batchesHandled = 0,
    this.ordersHandled = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'employee_code': employeeCode,
      'role': role,
      'phone': phone,
      'email': email,
      'joining_date': joiningDate.toIso8601String(),
      'department': department,
      'is_active': isActive ? 1 : 0,
      'batches_handled': batchesHandled,
      'orders_handled': ordersHandled,
    };
  }

  factory Staff.fromMap(Map<String, dynamic> map) {
    return Staff(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      employeeCode: map['employee_code']?.toString() ?? '',
      role: map['role']?.toString() ?? 'production_staff',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      joiningDate: map['joining_date'] != null
          ? DateTime.parse(map['joining_date'].toString())
          : DateTime.now(),
      department: map['department']?.toString() ?? 'Production',
      isActive: map['is_active'] == 1 || map['is_active'] == true,
      batchesHandled: (map['batches_handled'] as num?)?.toInt() ?? 0,
      ordersHandled: (map['orders_handled'] as num?)?.toInt() ?? 0,
    );
  }
}
