import 'package:budget_planner/getx_controller/category_controller.dart';
import 'package:budget_planner/getx_controller/home_controller.dart';
import 'package:budget_planner/getx_controller/operation_controller.dart';
import 'package:budget_planner/models/category_model.dart';
import 'package:budget_planner/models/operation_model.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

void main() {
  late OperationController form;
  late HomeController home;

  setUp(() async {
    await seed(user: const UserModel(
      name: 'Yana',
      dailyLimit: 100,
      pin: '1234',
      currencyCode: 'JOD',
    ));
    home = Get.put(HomeController());
    await home.load();
    await Get.put(CategoryController()).load();
    form = Get.put(OperationController());
  });

  tearDown(Get.reset);

  test('needs an amount and a category', () {
    expect(form.canSave, isFalse);
    form.amountController.text = '12.5';
    form.touch();
    expect(form.canSave, isFalse);
    form.setCategory(food);
    expect(form.canSave, isTrue);
    expect(form.amount, 12.5);
  });

  test('comma decimals parse', () {
    form.amountController.text = '7,25';
    expect(form.amount, 7.25);
  });

  test('switching side clears a category from the other side', () {
    form.setCategory(food);
    form.setType(OperationType.income);
    expect(form.category.value, isNull);
    expect(form.categories.every((CategoryModel c) => c.type ==
        OperationType.income), isTrue);
  });

  test('picking a category also picks its side', () {
    form.setCategory(salary);
    expect(form.type.value, OperationType.income);
  });

  test('save stores in the profile currency and refreshes the ledger',
      () async {
    form.amountController.text = '40';
    form.noteController.text = ' Lunch ';
    form.setCategory(food);
    expect(await form.save(), isTrue);

    final OperationModel saved = AppPreferences.instance.operations.single;
    expect(saved.currencyCode, 'JOD');
    expect(saved.note, 'Lunch');
    expect(home.operations, hasLength(1));
  });

  test('editing updates in place and delete removes it', () async {
    final OperationModel existing = op(food, 10, DateTime.now());
    await home.save(existing);

    form.loadForEdit(existing);
    expect(form.isEditing, isTrue);
    expect(form.amountController.text, '10');
    form.amountController.text = '15';
    form.touch();
    await form.save();
    expect(AppPreferences.instance.operations.single.amount, 15);

    await form.delete();
    expect(AppPreferences.instance.operations, isEmpty);
    expect(home.operations, isEmpty);
  });

  test('setDate keeps the picked day', () {
    form.setDate(DateTime(2025, 3, 9));
    expect(form.date.value.year, 2025);
    expect(form.date.value.month, 3);
    expect(form.date.value.day, 9);
  });
}
