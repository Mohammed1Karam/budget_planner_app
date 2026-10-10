import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/app_controller.dart';
import '../../getx_controller/operation_controller.dart';
import '../../models/category_model.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_format.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';
import '../../widget/app_back_button.dart';
import '../../widget/app_sheets.dart';
import '../../widget/category_tile.dart';
import '../../widget/money_field.dart';
import '../../widget/primary_button.dart';
import '../../widget/segmented_toggle.dart';

/// Add a transaction, or edit one when opened on a saved row: side, amount,
/// category (picked inline, with "+ New"), date and an optional note.
class AddOperationScreen extends StatelessWidget {
  const AddOperationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OperationController controller = Get.put(OperationController());
    final bool editing = controller.isEditing;
    final p = context.palette;

    Future<void> save() async {
      if (await controller.save()) {
        Get.back<void>();
        showToast(
          editing ? 'transaction_updated'.tr : 'transaction_saved'.tr,
        );
      }
    }

    Future<void> delete() async {
      final bool ok = await showConfirmDialog(
        context,
        title: 'delete_transaction_title'.tr,
        message: 'delete_transaction_body'.tr,
        confirmLabel: 'delete'.tr,
      );
      if (!ok) return;
      await controller.delete();
      Get.back<void>();
      showToast('transaction_deleted'.tr, icon: Icons.delete_rounded);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: <Widget>[
                  const AppCloseButton(),
                  Expanded(
                    child: Text(
                      editing ? 'edit_transaction'.tr : 'new_transaction'.tr,
                      textAlign: TextAlign.center,
                      style: context.text.titleLarge,
                    ),
                  ),
                  if (editing)
                    AppIconButton(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'delete'.tr,
                      color: p.danger,
                      background: p.dangerSoft,
                      onTap: delete,
                    )
                  else
                    const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPadding,
                  8,
                  AppDimens.screenPadding,
                  24,
                ),
                children: <Widget>[
                  Obx(
                    () => SegmentedToggle(
                      labels: <String>['expense'.tr, 'income'.tr],
                      icons: const <IconData>[
                        Icons.north_east_rounded,
                        Icons.south_west_rounded,
                      ],
                      colors: <Color>[p.expense, p.income],
                      selectedIndex:
                          controller.type.value == OperationType.expense
                              ? 0
                              : 1,
                      onChanged: (int i) => controller.setType(
                        i == 0 ? OperationType.expense : OperationType.income,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AmountCard(controller: controller),
                  const SizedBox(height: 24),
                  _Label(text: 'category'.tr),
                  _CategoryGrid(controller: controller),
                  const SizedBox(height: 24),
                  _Label(text: 'date'.tr),
                  _DateChips(controller: controller),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'note_optional'.tr,
                    hint: 'note_hint'.tr,
                    icon: Icons.edit_note_rounded,
                    controller: controller.noteController,
                    onChanged: (_) => controller.touch(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.screenPadding,
                8,
                AppDimens.screenPadding,
                16,
              ),
              child: Obx(
                () => PrimaryButton(
                  label: editing ? 'save_changes'.tr : 'save_transaction'.tr,
                  icon: Icons.check_rounded,
                  loading: controller.saving.value,
                  onPressed: controller.canSave ? save : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 10),
      child: Text(
        text,
        style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// The big amount input, tinted by side.
class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.controller});

  final OperationController controller;

  @override
  Widget build(BuildContext context) => Obx(() => _build(context));

  Widget _build(BuildContext context) {
    final p = context.palette;
    final bool expense = controller.type.value == OperationType.expense;
    final Color accent = expense ? p.expense : p.income;
    final String symbol = Get.find<AppController>().currencySymbol;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: expense ? p.expenseSoft : p.incomeSoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
      ),
      child: Column(
        children: <Widget>[
          Text(
            'amount'.tr,
            style: context.text.labelMedium?.copyWith(color: accent),
          ),
          const SizedBox(height: 4),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  symbol,
                  style: context.text.headlineMedium?.copyWith(color: accent),
                ),
                const SizedBox(width: 8),
                IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 60),
                    child: TextField(
                      controller: controller.amountController,
                      autofocus: !controller.isEditing,
                      onChanged: (_) => controller.touch(),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: amountFormatters,
                      textAlign: TextAlign.center,
                      cursorColor: accent,
                      style: context.text.displayMedium?.copyWith(
                        color: p.textPrimary,
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: '0',
                        hintStyle: context.text.displayMedium?.copyWith(
                          color: p.textMuted.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.controller});

  final OperationController controller;

  @override
  Widget build(BuildContext context) => Obx(() => _build(context));

  Widget _build(BuildContext context) {
    final List<CategoryModel> list = controller.categories;
    final String? selectedId = controller.category.value?.id;
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 98,
      ),
      children: <Widget>[
        for (final CategoryModel c in list)
          CategoryChip(
            category: c,
            selected: c.id == selectedId,
            onTap: () => controller.setCategory(c),
          ),
        AddCategoryChip(
          label: 'new'.tr,
          onTap: () async {
            final Object? created = await Get.toNamed<Object?>(
              AppRoutes.addCategory,
              arguments: controller.type.value,
            );
            if (created is CategoryModel) controller.setCategory(created);
          },
        ),
      ],
    );
  }
}

/// Today / Yesterday / a picked date.
class _DateChips extends StatelessWidget {
  const _DateChips({required this.controller});

  final OperationController controller;

  @override
  Widget build(BuildContext context) => Obx(() => _build(context));

  Widget _build(BuildContext context) {
    final p = context.palette;
    final DateTime now = DateTime.now();
    final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    final DateTime picked = controller.date.value;
    final bool isToday = AppFormat.sameDay(picked, now);
    final bool isYesterday = AppFormat.sameDay(picked, yesterday);
    final bool isOther = !isToday && !isYesterday;

    Widget chip(String label, bool selected, VoidCallback onTap,
        {IconData? icon}) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: selected ? p.primary : p.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall + 2),
              border: Border.all(color: selected ? p.primary : p.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(
                    icon,
                    size: 16,
                    color: selected ? p.onPrimary : p.textSecondary,
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelLarge?.copyWith(
                      fontSize: 13,
                      color: selected ? p.onPrimary : p.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: <Widget>[
        chip('today'.tr, isToday, () => controller.setDate(now)),
        const SizedBox(width: 8),
        chip('yesterday'.tr, isYesterday, () => controller.setDate(yesterday)),
        const SizedBox(width: 8),
        chip(
          isOther ? AppFormat.weekdayDayMonth(picked) : 'pick_date'.tr,
          isOther,
          () async {
            final DateTime? date = await showDatePicker(
              context: context,
              initialDate: picked,
              firstDate: DateTime(now.year - 5),
              lastDate: DateTime(now.year + 1, 12, 31),
            );
            if (date != null) controller.setDate(date);
          },
          icon: Icons.calendar_month_rounded,
        ),
      ],
    );
  }
}
