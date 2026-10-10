import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_dimens.dart';
import '../utils/app_theme.dart';

/// A 44pt rounded-square icon button on a surface, used for every top-bar
/// action so they all read as one set.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.background,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final Color? background;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final Widget button = Material(
      color: background ?? p.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusSmall + 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall + 2),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 21, color: color ?? p.textPrimary),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Back, pointing the right way in both reading directions.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: Icons.arrow_back_rounded,
      onTap: onTap ?? () => Get.back<void>(),
    );
  }
}

class AppCloseButton extends StatelessWidget {
  const AppCloseButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: Icons.close_rounded,
      onTap: onTap ?? () => Get.back<void>(),
    );
  }
}
