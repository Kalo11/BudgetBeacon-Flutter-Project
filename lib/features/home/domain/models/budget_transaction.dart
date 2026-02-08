enum TransactionType { income, expense }

class BudgetTransaction {
  const BudgetTransaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
  });

  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final TransactionType type;

  BudgetTransaction copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    DateTime? date,
    TransactionType? type,
  }) {
    return BudgetTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.name,
    };
  }

  factory BudgetTransaction.fromJson(Map<String, dynamic> json) {
    return BudgetTransaction(
      id: json['id'] as String,
      title: json['title'] as String,
      category: (json['category'] as String?) ?? 'General',
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      type: TransactionType.values.byName(json['type'] as String),
    );
  }
}
