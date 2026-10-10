import 'package:flutter/painting.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';

/// Which side of the ledger a category or a transaction sits on.
enum OperationType { expense, income }

/// A spending or earning category, drawn as its emoji on a tinted circle.
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
    this.isCustom = false,
  });

  final String id;

  /// The name as typed for a custom category. Built-in categories are shown
  /// through a translation key instead, see [displayName].
  final String name;
  final String emoji;
  final OperationType type;

  /// True for a category the user added; only those can be deleted.
  final bool isCustom;

  /// Built-in categories translate (`cat_food` -> "Food" / "طعام"); a custom
  /// one shows exactly what the user typed.
  String get displayName {
    if (isCustom) return name;
    final String key = 'cat_$id';
    final String translated = key.tr;
    return translated == key ? name : translated;
  }

  Color get tint => AppPalette.tintFor(id);

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] as String;
    return CategoryModel(
      id: id,
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '💳',
      type: json['type'] == 'income'
          ? OperationType.income
          : OperationType.expense,
      isCustom: json['custom'] as bool? ?? id.startsWith('custom_'),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'emoji': emoji,
        'type': type.name,
        'custom': isCustom,
      };
}
