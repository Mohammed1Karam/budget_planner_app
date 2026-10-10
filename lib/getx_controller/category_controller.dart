import 'package:get/get.dart';

import '../api/budget_api.dart';
import '../models/category_model.dart';

/// The category catalogue: the built-in set plus anything the user adds.
class CategoryController extends GetxController {
  CategoryController({BudgetApi? api}) : _api = api ?? BudgetApi();

  final BudgetApi _api;

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  static const List<CategoryModel> defaultExpenses = <CategoryModel>[
    CategoryModel(id: 'food', name: 'Food', emoji: '🍔', type: OperationType.expense),
    CategoryModel(id: 'shopping', name: 'Shopping', emoji: '🛍️', type: OperationType.expense),
    CategoryModel(id: 'travel', name: 'Transport', emoji: '🚗', type: OperationType.expense),
    CategoryModel(id: 'bills', name: 'Bills', emoji: '🧾', type: OperationType.expense),
    CategoryModel(id: 'accommodation', name: 'Home', emoji: '🏠', type: OperationType.expense),
    CategoryModel(id: 'medicine', name: 'Health', emoji: '💊', type: OperationType.expense),
    CategoryModel(id: 'education', name: 'Education', emoji: '📚', type: OperationType.expense),
    CategoryModel(id: 'entertainment', name: 'Entertainment', emoji: '🎬', type: OperationType.expense),
    CategoryModel(id: 'sport', name: 'Sport', emoji: '⚽', type: OperationType.expense),
    CategoryModel(id: 'cash', name: 'Cash', emoji: '💵', type: OperationType.expense),
    CategoryModel(id: 'other_expense', name: 'Other', emoji: '📦', type: OperationType.expense),
  ];

  static const List<CategoryModel> defaultIncomes = <CategoryModel>[
    CategoryModel(id: 'salary', name: 'Salary', emoji: '💼', type: OperationType.income),
    CategoryModel(id: 'freelance', name: 'Freelance', emoji: '💻', type: OperationType.income),
    CategoryModel(id: 'sales', name: 'Sales', emoji: '💰', type: OperationType.income),
    CategoryModel(id: 'premium', name: 'Bonus', emoji: '🏆', type: OperationType.income),
    CategoryModel(id: 'gift', name: 'Gift', emoji: '🎁', type: OperationType.income),
    CategoryModel(id: 'other_income', name: 'Other', emoji: '📦', type: OperationType.income),
  ];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final List<CategoryModel> custom = await _api.fetchCustomCategories();
    categories.assignAll(<CategoryModel>[
      ...defaultExpenses,
      ...defaultIncomes,
      ...custom,
    ]);
  }

  List<CategoryModel> ofType(OperationType type) =>
      categories.where((c) => c.type == type).toList();

  Future<CategoryModel> add({
    required String name,
    required OperationType type,
    String emoji = '📦',
  }) async {
    final CategoryModel category = CategoryModel(
      id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      emoji: emoji,
      type: type,
      isCustom: true,
    );
    await _api.saveCustomCategory(category);
    categories.add(category);
    return category;
  }

  /// Only a custom category can go. Transactions already saved against it
  /// keep their own copy, so they still show the right name and emoji.
  Future<void> remove(CategoryModel category) async {
    if (!category.isCustom) return;
    await _api.deleteCustomCategory(category.id);
    categories.removeWhere((c) => c.id == category.id);
  }
}
