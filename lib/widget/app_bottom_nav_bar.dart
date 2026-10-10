import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_dimens.dart';
import '../utils/app_theme.dart';

/// The floating tab bar: two tabs, the add button, two tabs.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelected,
    required this.onAdd,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'home'),
    _NavItem(
      Icons.receipt_long_outlined,
      Icons.receipt_long_rounded,
      'transactions',
    ),
    _NavItem(Icons.pie_chart_outline_rounded, Icons.pie_chart_rounded, 'statistics'),
    _NavItem(Icons.settings_outlined, Icons.settings_rounded, 'settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
        child: Container(
          height: AppDimens.bottomNavHeight,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: p.shadow.withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              _tab(context, 0),
              _tab(context, 1),
              Expanded(child: Center(child: _addButton(context))),
              _tab(context, 2),
              _tab(context, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(BuildContext context, int index) {
    final p = context.palette;
    final _NavItem item = _items[index];
    final bool selected = index == currentIndex;
    final Color color = selected ? p.primary : p.textMuted;

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: item.labelKey.tr,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          onTap: () => onSelected(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? p.primarySoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                ),
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  size: 22,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.labelKey.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addButton(BuildContext context) {
    final p = context.palette;
    // Ink with a lime plus on a light bar; solid lime on a dark one, where
    // black would disappear into the bar.
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: 'add_transaction'.tr,
      child: GestureDetector(
        onTap: onAdd,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: dark ? p.accent : null,
            gradient: dark ? null : p.heroGradient,
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium + 2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (dark ? p.accent : p.glowB).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.add_rounded,
            color: dark ? p.onAccent : p.accent,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.activeIcon, this.labelKey);

  final IconData icon;
  final IconData activeIcon;
  final String labelKey;
}
