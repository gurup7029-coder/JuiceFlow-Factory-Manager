class Expense {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String paymentMethod; // UPI, Cash, Bank Transfer, Cheque
  final String description;
  final String? receiptUrl;

  Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    this.description = '',
    this.receiptUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'payment_method': paymentMethod,
      'description': description,
      'receipt_url': receiptUrl,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Miscellaneous',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] != null
          ? DateTime.parse(map['date'].toString())
          : DateTime.now(),
      paymentMethod: map['payment_method']?.toString() ?? 'Cash',
      description: map['description']?.toString() ?? '',
      receiptUrl: map['receipt_url']?.toString(),
    );
  }
}
