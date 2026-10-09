class StockMovement {
  final String id;
  final String itemId;
  final String itemName;
  final String itemType; // Raw Material, Packaging, Finished Goods
  final String movementType; // Production In, Production Used, Purchase In, Sales Out, Wastage, Adjustment
  final double quantity;
  final String unit;
  final DateTime date;
  final String performedBy;
  final String referenceId;
  final String notes;

  StockMovement({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.itemType,
    required this.movementType,
    required this.quantity,
    required this.unit,
    required this.date,
    required this.performedBy,
    this.referenceId = '',
    this.notes = '',
  });

  bool get isPositive =>
      movementType == 'Production In' ||
      movementType == 'Purchase In' ||
      quantity > 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_id': itemId,
      'item_name': itemName,
      'item_type': itemType,
      'movement_type': movementType,
      'quantity': quantity,
      'unit': unit,
      'date': date.toIso8601String(),
      'performed_by': performedBy,
      'reference_id': referenceId,
      'notes': notes,
    };
  }

  factory StockMovement.fromMap(Map<String, dynamic> map) {
    return StockMovement(
      id: map['id']?.toString() ?? '',
      itemId: map['item_id']?.toString() ?? '',
      itemName: map['item_name']?.toString() ?? '',
      itemType: map['item_type']?.toString() ?? 'Finished Goods',
      movementType: map['movement_type']?.toString() ?? 'Adjustment',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit']?.toString() ?? 'Units',
      date: map['date'] != null
          ? DateTime.parse(map['date'].toString())
          : DateTime.now(),
      performedBy: map['performed_by']?.toString() ?? 'Staff',
      referenceId: map['reference_id']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
    );
  }
}
