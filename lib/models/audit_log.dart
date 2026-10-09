class AuditLog {
  final String id;
  final String userName;
  final String userRole;
  final String action; // CREATE, UPDATE, DELETE, QC_APPROVE, BATCH_START, STOCK_ADJUST
  final String module; // Products, Production, Inventory, Orders, Settings
  final String recordAffected;
  final String details;
  final DateTime timestamp;

  AuditLog({
    required this.id,
    required this.userName,
    required this.userRole,
    required this.action,
    required this.module,
    required this.recordAffected,
    required this.details,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_name': userName,
      'user_role': userRole,
      'action': action,
      'module': module,
      'record_affected': recordAffected,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id']?.toString() ?? '',
      userName: map['user_name']?.toString() ?? 'Admin',
      userRole: map['user_role']?.toString() ?? 'admin',
      action: map['action']?.toString() ?? 'UPDATE',
      module: map['module']?.toString() ?? 'General',
      recordAffected: map['record_affected']?.toString() ?? '',
      details: map['details']?.toString() ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'].toString())
          : DateTime.now(),
    );
  }
}
