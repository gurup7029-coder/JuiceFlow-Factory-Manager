import 'dart:convert';
import 'package:flutter/material.dart';

class OrderItem {
  final String productId;
  final String productName;
  final String bottleSize;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.bottleSize,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'bottle_size': bottleSize,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['product_id']?.toString() ?? '',
      productName: map['product_name']?.toString() ?? '',
      bottleSize: map['bottle_size']?.toString() ?? '500 ml',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SalesOrder {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double taxAmount;
  final double grandTotal;
  final double paidAmount;
  final String paymentStatus; // Paid, Partial, Unpaid
  final String deliveryStatus; // New, Confirmed, Processing, Packed, Dispatched, Delivered, Cancelled
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String notes;

  SalesOrder({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    this.taxAmount = 0.0,
    required this.grandTotal,
    this.paidAmount = 0.0,
    this.paymentStatus = 'Unpaid',
    this.deliveryStatus = 'New',
    required this.orderDate,
    this.deliveryDate,
    this.notes = '',
  });

  double get balanceAmount => grandTotal - paidAmount;

  Color get statusColor {
    switch (deliveryStatus) {
      case 'Delivered':
        return Colors.green;
      case 'Dispatched':
        return Colors.teal;
      case 'Packed':
        return Colors.blue;
      case 'Processing':
        return Colors.indigo;
      case 'Confirmed':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      case 'New':
      default:
        return Colors.purple;
    }
  }

  Color get paymentColor {
    switch (paymentStatus) {
      case 'Paid':
        return Colors.green;
      case 'Partial':
        return Colors.orange;
      case 'Unpaid':
      default:
        return Colors.red;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'items_json': jsonEncode(items.map((e) => e.toMap()).toList()),
      'subtotal': subtotal,
      'discount': discount,
      'tax_amount': taxAmount,
      'grand_total': grandTotal,
      'paid_amount': paidAmount,
      'payment_status': paymentStatus,
      'delivery_status': deliveryStatus,
      'order_date': orderDate.toIso8601String(),
      'delivery_date': deliveryDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory SalesOrder.fromMap(Map<String, dynamic> map) {
    List<OrderItem> itemsList = [];
    if (map['items_json'] != null) {
      try {
        final decoded = jsonDecode(map['items_json'].toString()) as List;
        itemsList = decoded.map((e) => OrderItem.fromMap(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    return SalesOrder(
      id: map['id']?.toString() ?? '',
      orderNumber: map['order_number']?.toString() ?? '',
      customerId: map['customer_id']?.toString() ?? '',
      customerName: map['customer_name']?.toString() ?? '',
      customerPhone: map['customer_phone']?.toString() ?? '',
      customerAddress: map['customer_address']?.toString() ?? '',
      items: itemsList,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (map['tax_amount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (map['grand_total'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (map['paid_amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: map['payment_status']?.toString() ?? 'Unpaid',
      deliveryStatus: map['delivery_status']?.toString() ?? 'New',
      orderDate: map['order_date'] != null
          ? DateTime.parse(map['order_date'].toString())
          : DateTime.now(),
      deliveryDate: map['delivery_date'] != null
          ? DateTime.parse(map['delivery_date'].toString())
          : null,
      notes: map['notes']?.toString() ?? '',
    );
  }

  SalesOrder copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    List<OrderItem>? items,
    double? subtotal,
    double? discount,
    double? taxAmount,
    double? grandTotal,
    double? paidAmount,
    String? paymentStatus,
    String? deliveryStatus,
    DateTime? orderDate,
    DateTime? deliveryDate,
    String? notes,
  }) {
    return SalesOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      taxAmount: taxAmount ?? this.taxAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      notes: notes ?? this.notes,
    );
  }
}
