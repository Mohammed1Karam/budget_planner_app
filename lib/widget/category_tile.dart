import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../utils/app_dimens.dart';
import '../utils/app_theme.dart';

/// A category's emoji on a circle tinted with its own colour.
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    super.key,
    required this.category,
    this.size = AppDimens.avatar,
  });

  final CategoryModel category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: category.tint.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(size * 0.34),
      ),
      child: Text(
        category.emoji,
        style: TextStyle(fontSize: size * 0.46, height: 1.1),
      ),
    );
  }
}

/// A selectable category in the transaction form's grid.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final CategoryModel category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      selected: selected,
      button: true,
      label: category.displayName,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? category.tint.withValues(alpha: 0.14) : p.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            border: Border.all(
              color: selected ? category.tint : p.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CategoryAvatar(category: category, size: 38),
              const SizedBox(height: 6),
              Text(
                category.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.text.labelSmall?.copyWith(
                  color: selected ? p.textPrimary : p.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The dashed "+ New" tile at the end of the category grid.
class AddCategoryChip extends StatelessWidget {
  const AddCategoryChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: p.primarySoft.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          border: Border.all(color: p.primary.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 38,
              height: 38,
              child: Icon(Icons.add_rounded, color: p.primary, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelSmall?.copyWith(
                color: p.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
