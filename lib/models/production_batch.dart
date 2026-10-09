import 'package:flutter/material.dart';

class ProductionBatch {
  final String id;
  final String batchNumber;
  final String productId;
  final String productName;
  final DateTime productionDate;
  final double plannedQty; // in Liters or Bottles
  final double actualQty;
  final double wastageQty;
  final String unit; // Liters or Bottles
  final String ingredientsSummary;
  final String assignedStaff;
  final DateTime? startTime;
  final DateTime? endTime;
  final String status; // Planned, In Progress, Quality Check, Completed, Rejected, Cancelled
  final String qcStatus; // Pending, Passed, Failed, Needs Review
  final DateTime expiryDate;
  final String notes;

  ProductionBatch({
    required this.id,
    required this.batchNumber,
    required this.productId,
    required this.productName,
    required this.productionDate,
    required this.plannedQty,
    this.actualQty = 0.0,
    this.wastageQty = 0.0,
    this.unit = 'Liters',
    required this.ingredientsSummary,
    required this.assignedStaff,
    this.startTime,
    this.endTime,
    this.status = 'Planned',
    this.qcStatus = 'Pending',
    required this.expiryDate,
    this.notes = '',
  });

  double get efficiency {
    if (plannedQty <= 0) return 0.0;
    return (actualQty / plannedQty) * 100.0;
  }

  double get wastagePercent {
    final total = actualQty + wastageQty;
    if (total <= 0) return 0.0;
    return (wastageQty / total) * 100.0;
  }

  Color get statusColor {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      case 'Quality Check':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      case 'Cancelled':
        return Colors.grey;
      case 'Planned':
      default:
        return Colors.purple;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batch_number': batchNumber,
      'product_id': productId,
      'product_name': productName,
      'production_date': productionDate.toIso8601String(),
      'planned_qty': plannedQty,
      'actual_qty': actualQty,
      'wastage_qty': wastageQty,
      'unit': unit,
      'ingredients_summary': ingredientsSummary,
      'assigned_staff': assignedStaff,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'status': status,
      'qc_status': qcStatus,
      'expiry_date': expiryDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory ProductionBatch.fromMap(Map<String, dynamic> map) {
    return ProductionBatch(
      id: map['id']?.toString() ?? '',
      batchNumber: map['batch_number']?.toString() ?? '',
      productId: map['product_id']?.toString() ?? '',
      productName: map['product_name']?.toString() ?? '',
      productionDate: map['production_date'] != null
          ? DateTime.parse(map['production_date'].toString())
          : DateTime.now(),
      plannedQty: (map['planned_qty'] as num?)?.toDouble() ?? 0.0,
      actualQty: (map['actual_qty'] as num?)?.toDouble() ?? 0.0,
      wastageQty: (map['wastage_qty'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit']?.toString() ?? 'Liters',
      ingredientsSummary: map['ingredients_summary']?.toString() ?? '',
      assignedStaff: map['assigned_staff']?.toString() ?? '',
      startTime: map['start_time'] != null
          ? DateTime.parse(map['start_time'].toString())
          : null,
      endTime: map['end_time'] != null
          ? DateTime.parse(map['end_time'].toString())
          : null,
      status: map['status']?.toString() ?? 'Planned',
      qcStatus: map['qc_status']?.toString() ?? 'Pending',
      expiryDate: map['expiry_date'] != null
          ? DateTime.parse(map['expiry_date'].toString())
          : DateTime.now().add(const Duration(days: 90)),
      notes: map['notes']?.toString() ?? '',
    );
  }

  ProductionBatch copyWith({
    String? id,
    String? batchNumber,
    String? productId,
    String? productName,
    DateTime? productionDate,
    double? plannedQty,
    double? actualQty,
    double? wastageQty,
    String? unit,
    String? ingredientsSummary,
    String? assignedStaff,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    String? qcStatus,
    DateTime? expiryDate,
    String? notes,
  }) {
    return ProductionBatch(
      id: id ?? this.id,
      batchNumber: batchNumber ?? this.batchNumber,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productionDate: productionDate ?? this.productionDate,
      plannedQty: plannedQty ?? this.plannedQty,
      actualQty: actualQty ?? this.actualQty,
      wastageQty: wastageQty ?? this.wastageQty,
      unit: unit ?? this.unit,
      ingredientsSummary: ingredientsSummary ?? this.ingredientsSummary,
      assignedStaff: assignedStaff ?? this.assignedStaff,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      qcStatus: qcStatus ?? this.qcStatus,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
    );
  }
}
