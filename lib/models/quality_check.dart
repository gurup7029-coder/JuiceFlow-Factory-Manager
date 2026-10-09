class QualityCheck {
  final String id;
  final String batchId;
  final String batchNumber;
  final String appearance;
  final String colour;
  final String taste;
  final String smell;
  final double phValue;
  final double temperature;
  final double brixSugar;
  final String packagingCondition;
  final String sealCondition;
  final String remarks;
  final String inspectorName;
  final DateTime checkDate;
  final String status; // Passed, Failed, Needs Review

  QualityCheck({
    required this.id,
    required this.batchId,
    required this.batchNumber,
    required this.appearance,
    required this.colour,
    required this.taste,
    required this.smell,
    required this.phValue,
    required this.temperature,
    required this.brixSugar,
    required this.packagingCondition,
    required this.sealCondition,
    required this.remarks,
    required this.inspectorName,
    required this.checkDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batch_id': batchId,
      'batch_number': batchNumber,
      'appearance': appearance,
      'colour': colour,
      'taste': taste,
      'smell': smell,
      'ph_value': phValue,
      'temperature': temperature,
      'brix_sugar': brixSugar,
      'packaging_condition': packagingCondition,
      'seal_condition': sealCondition,
      'remarks': remarks,
      'inspector_name': inspectorName,
      'check_date': checkDate.toIso8601String(),
      'status': status,
    };
  }

  factory QualityCheck.fromMap(Map<String, dynamic> map) {
    return QualityCheck(
      id: map['id']?.toString() ?? '',
      batchId: map['batch_id']?.toString() ?? '',
      batchNumber: map['batch_number']?.toString() ?? '',
      appearance: map['appearance']?.toString() ?? 'Clear & Fresh',
      colour: map['colour']?.toString() ?? 'Natural Vibrant',
      taste: map['taste']?.toString() ?? 'Standard Sweet & Tart',
      smell: map['smell']?.toString() ?? 'Fresh Fruit Aroma',
      phValue: (map['ph_value'] as num?)?.toDouble() ?? 3.8,
      temperature: (map['temperature'] as num?)?.toDouble() ?? 4.0,
      brixSugar: (map['brix_sugar'] as num?)?.toDouble() ?? 12.0,
      packagingCondition: map['packaging_condition']?.toString() ?? 'Intact',
      sealCondition: map['seal_condition']?.toString() ?? 'Hermetically Sealed',
      remarks: map['remarks']?.toString() ?? '',
      inspectorName: map['inspector_name']?.toString() ?? 'QC Officer',
      checkDate: map['check_date'] != null
          ? DateTime.parse(map['check_date'].toString())
          : DateTime.now(),
      status: map['status']?.toString() ?? 'Passed',
    );
  }
}
