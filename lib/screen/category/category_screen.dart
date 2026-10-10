import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/category_controller.dart';
import '../../models/category_model.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';
import '../../widget/app_back_button.dart';
import '../../widget/app_card.dart';
import '../../widget/app_scaffold.dart';
import '../../widget/app_sheets.dart';
import '../../widget/category_tile.dart';
import '../../widget/segmented_toggle.dart';

/// Manage categories: the built-in ones for each side, plus the user's own,
/// which can be deleted.
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  OperationType _type = OperationType.expense;

  CategoryController get _controller => Get.find<CategoryController>();

  Future<void> _delete(CategoryModel category) async {
    final bool ok = await showConfirmDialog(
      context,
      title: 'delete_category_title'.tr,
      message: 'delete_category_body'
          .trParams(<String, String>{'name': category.displayName}),
      confirmLabel: 'delete'.tr,
    );
    if (ok) await _controller.remove(category);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppScaffold(
      title: 'categories'.tr,
      action: AppIconButton(
        icon: Icons.add_rounded,
        tooltip: 'add_category'.tr,
        color: p.primary,
        onTap: () =>
            Get.toNamed<void>(AppRoutes.addCategory, arguments: _type),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 4),
          SegmentedToggle(
            labels: <String>['expenses'.tr, 'income'.tr],
            colors: <Color>[p.expense, p.income],
            selectedIndex: _type == OperationType.expense ? 0 : 1,
            onChanged: (int i) => setState(
              () => _type =
                  i == 0 ? OperationType.expense : OperationType.income,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              final List<CategoryModel> list = _controller.ofType(_type);
              return ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: <Widget>[
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Column(
                      children: <Widget>[
                        for (final CategoryModel c in list)
                          ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            leading: CategoryAvatar(category: c, size: 42),
                            title: Text(
                              c.displayName,
                              style: context.text.titleSmall,
                            ),
                            subtitle: Text(
                              c.isCustom ? 'custom'.tr : 'built_in'.tr,
                              style: context.text.bodySmall,
                            ),
                            trailing: c.isCustom
                                ? IconButton(
                                    tooltip: 'delete'.tr,
                                    onPressed: () => _delete(c),
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      color: p.danger,
                                    ),
                                  )
                                : null,
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
