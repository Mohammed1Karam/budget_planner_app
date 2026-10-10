import '../models/category_model.dart';
import '../models/operation_model.dart';
import '../models/user_model.dart';
import '../preferences/app_preferences.dart';
import 'api_client.dart';

/// Every read and write the app performs, in one place.
///
/// Today each call resolves against [AppPreferences]; the [ApiClient] field is
/// already threaded through so the bodies can move to the network one at a
/// time without touching the controllers.
class BudgetApi {
  BudgetApi({ApiClient? client, AppPreferences? preferences})
      : _client = client ?? ApiClient(),
        _preferences = preferences ?? AppPreferences.instance;

  // ignore: unused_field -- held for the eventual move off local storage.
  final ApiClient _client;
  final AppPreferences _preferences;

  Future<UserModel> fetchUser() async => _preferences.user;

  Future<void> saveUser(UserModel user) => _preferences.saveUser(user);

  Future<List<OperationModel>> fetchOperations() async {
    final List<OperationModel> operations = _preferences.operations;
    operations.sort((a, b) => b.date.compareTo(a.date));
    return operations;
  }

  Future<void> saveOperation(OperationModel operation) async {
    final List<OperationModel> operations = _preferences.operations;
    final int index = operations.indexWhere((o) => o.id == operation.id);
    if (index >= 0) {
      operations[index] = operation;
    } else {
      operations.add(operation);
    }
    await _preferences.saveOperations(operations);
  }

  Future<void> deleteOperation(String id) async {
    final List<OperationModel> operations = _preferences.operations
      ..removeWhere((o) => o.id == id);
    await _preferences.saveOperations(operations);
  }

  Future<void> clearOperations() =>
      _preferences.saveOperations(<OperationModel>[]);

  Future<List<CategoryModel>> fetchCustomCategories() async =>
      _preferences.customCategories;

  Future<void> saveCustomCategory(CategoryModel category) async {
    final List<CategoryModel> categories = _preferences.customCategories;
    final int index = categories.indexWhere((c) => c.id == category.id);
    if (index >= 0) {
      categories[index] = category;
    } else {
      categories.add(category);
    }
    await _preferences.saveCustomCategories(categories);
  }

  Future<void> deleteCustomCategory(String id) async {
    final List<CategoryModel> categories = _preferences.customCategories
      ..removeWhere((c) => c.id == id);
    await _preferences.saveCustomCategories(categories);
  }
}
