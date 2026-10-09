import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type; // 'low_stock', 'expiry', 'pending_order', 'qc_alert', 'production_delay'
  final String priority; // 'HIGH', 'MEDIUM', 'LOW'
  final DateTime createdAt;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.priority = 'MEDIUM',
    required this.createdAt,
    this.isRead = false,
  });

  Color get priorityColor {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.amber.shade800;
      case 'LOW':
      default:
        return Colors.blue;
    }
  }

  IconData get icon {
    switch (type) {
      case 'low_stock':
        return Icons.inventory_2_outlined;
      case 'expiry':
        return Icons.warning_amber_rounded;
      case 'pending_order':
        return Icons.shopping_bag_outlined;
      case 'qc_alert':
        return Icons.biotech_outlined;
      case 'production_delay':
      default:
        return Icons.precision_manufacturing_outlined;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead ? 1 : 0,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      type: map['type']?.toString() ?? 'alert',
      priority: map['priority']?.toString() ?? 'MEDIUM',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
      isRead: map['is_read'] == 1 || map['is_read'] == true,
    );
  }
}
