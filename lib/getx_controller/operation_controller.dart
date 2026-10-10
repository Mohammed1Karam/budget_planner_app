import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/category_model.dart';
import '../models/operation_model.dart';
import 'app_controller.dart';
import 'category_controller.dart';
import 'home_controller.dart';

/// The add / edit transaction form.
///
/// Opened with an [OperationModel] as the route argument it edits that row;
/// otherwise it starts a new one. Amounts are always in the profile currency,
/// so every total in the app adds up like for like.
class OperationController extends GetxController {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final Rx<OperationType> type = OperationType.expense.obs;
  final Rxn<CategoryModel> category = Rxn<CategoryModel>();
  final Rx<DateTime> date = DateTime.now().obs;
  final RxBool saving = false.obs;
  final RxInt revision = 0.obs;

  /// Set when the form was opened on an existing row.
  OperationModel? editing;

  bool get isEditing => editing != null;

  @override
  void onInit() {
    super.onInit();
    final Object? argument = Get.arguments;
    if (argument is OperationModel) loadForEdit(argument);
  }

  void loadForEdit(OperationModel operation) {
    editing = operation;
    final double a = operation.amount;
    amountController.text =
        a == a.roundToDouble() ? a.toStringAsFixed(0) : a.toString();
    noteController.text = operation.note;
    type.value = operation.category.type;
    category.value = operation.category;
    date.value = operation.date;
    touch();
  }

  void touch() => revision.value++;

  double get amount =>
      double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;

  bool get canSave {
    revision.value;
    return amount > 0 && category.value != null;
  }

  /// Flipping the side clears a category that belongs to the other one.
  void setType(OperationType value) {
    if (type.value == value) return;
    type.value = value;
    if (category.value?.type != value) category.value = null;
    touch();
  }

  void setCategory(CategoryModel value) {
    category.value = value;
    type.value = value.type;
    touch();
  }

  /// Keeps the time of day, so ordering within a day still works.
  void setDate(DateTime value) {
    final DateTime now = DateTime.now();
    date.value = DateTime(
      value.year,
      value.month,
      value.day,
      now.hour,
      now.minute,
      now.second,
    );
    touch();
  }

  List<CategoryModel> get categories =>
      Get.find<CategoryController>().ofType(type.value);

  /// Saves the row and reports whether it went through.
  Future<bool> save() async {
    if (!canSave) return false;
    saving.value = true;
    try {
      final String note = noteController.text.trim();
      final OperationModel operation = OperationModel(
        id: editing?.id ?? 'op_${DateTime.now().microsecondsSinceEpoch}',
        category: category.value!,
        title: note.isEmpty ? category.value!.name : note,
        amount: amount,
        date: date.value,
        note: note,
        currencyCode: Get.find<AppController>().user.value.currencyCode,
      );
      await Get.find<HomeController>().save(operation);
      return true;
    } finally {
      saving.value = false;
    }
  }

  Future<void> delete() async {
    final OperationModel? current = editing;
    if (current == null) return;
    await Get.find<HomeController>().delete(current.id);
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
