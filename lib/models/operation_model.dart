import 'category_model.dart';

/// One row in the actions list: an amount, what it was for, and when.
class OperationModel {
  const OperationModel({
    required this.id,
    required this.category,
    required this.title,
    required this.amount,
    required this.date,
    this.note = '',
    this.currencyCode = 'USD',
  });

  final String id;
  final CategoryModel category;

  /// The free-text description under the category, e.g. "Pizza Day".
  final String title;

  /// Always positive; [category].type decides the sign that is displayed.
  final double amount;

  final DateTime date;
  final String note;
  final String currencyCode;

  bool get isIncome => category.type == OperationType.income;

  /// Signed value, for summing a day or a month in one pass.
  double get signedAmount => isIncome ? amount : -amount;

  factory OperationModel.fromJson(Map<String, dynamic> json) {
    return OperationModel(
      id: json['id'] as String,
      category:
          CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String? ?? '',
      currencyCode: json['currency_code'] as String? ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'category': category.toJson(),
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
        'currency_code': currencyCode,
      };

  OperationModel copyWith({
    CategoryModel? category,
    String? title,
    double? amount,
    DateTime? date,
    String? note,
    String? currencyCode,
  }) {
    return OperationModel(
      id: id,
      category: category ?? this.category,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}
