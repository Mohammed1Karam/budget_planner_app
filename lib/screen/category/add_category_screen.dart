import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/category_controller.dart';
import '../../models/category_model.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_theme.dart';
import '../../widget/app_scaffold.dart';
import '../../widget/category_tile.dart';
import '../../widget/money_field.dart';
import '../../widget/primary_button.dart';
import '../../widget/segmented_toggle.dart';

/// New category: side, name and emoji, with a live preview. Pops with the
/// created category so the transaction form can select it straight away.
class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _name = TextEditingController();

  late OperationType _type;
  String _emoji = '📦';
  bool _saving = false;

  static const List<String> _emojis = <String>[
    '📦', '🍔', '☕', '🛒', '🛍️', '👕', '🚗', '⛽', '🚌', '✈️',
    '🏠', '💡', '📱', '🌐', '💊', '🏥', '📚', '🎓', '🎬', '🎮',
    '⚽', '🏋️', '🐶', '👶', '🎁', '💼', '💻', '💰', '🏦', '📈',
    '🧾', '🔧', '💇', '🌴', '❤️', '⭐',
  ];

  @override
  void initState() {
    super.initState();
    final Object? argument = Get.arguments;
    _type = argument is OperationType ? argument : OperationType.expense;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _canAdd => _name.text.trim().isNotEmpty && !_saving;

  Future<void> _submit() async {
    setState(() => _saving = true);
    final CategoryModel created = await Get.find<CategoryController>()
        .add(name: _name.text, type: _type, emoji: _emoji);
    Get.back<CategoryModel>(result: created);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final CategoryModel preview = CategoryModel(
      id: 'preview_${_name.text}',
      name: _name.text.trim().isEmpty ? 'category_name'.tr : _name.text.trim(),
      emoji: _emoji,
      type: _type,
      isCustom: true,
    );

    return AppScaffold(
      title: 'add_category'.tr,
      showClose: true,
      bottom: PrimaryButton(
        label: 'add_category'.tr,
        icon: Icons.check_rounded,
        loading: _saving,
        onPressed: _canAdd ? _submit : null,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                CategoryAvatar(category: preview, size: 84),
                const SizedBox(height: 10),
                Text(
                  preview.name,
                  style: context.text.titleMedium?.copyWith(
                    color: _name.text.trim().isEmpty ? p.textMuted : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SegmentedToggle(
            labels: <String>['expenses'.tr, 'income'.tr],
            colors: <Color>[p.expense, p.income],
            selectedIndex: _type == OperationType.expense ? 0 : 1,
            onChanged: (int i) => setState(
              () => _type =
                  i == 0 ? OperationType.expense : OperationType.income,
            ),
          ),
          const SizedBox(height: 20),
          AppTextField(
            label: 'name'.tr,
            hint: 'category_name'.tr,
            icon: Icons.label_outline_rounded,
            controller: _name,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 10),
            child: Text(
              'icon'.tr,
              style: context.text.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: <Widget>[
              for (final String emoji in _emojis)
                GestureDetector(
                  onTap: () => setState(() => _emoji = emoji),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: emoji == _emoji ? p.primarySoft : p.surface,
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusSmall),
                      border: Border.all(
                        color: emoji == _emoji ? p.primary : p.border,
                        width: emoji == _emoji ? 1.6 : 1,
                      ),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
