import 'package:flutter/material.dart';

import '../utils/app_dimens.dart';
import '../utils/app_theme.dart';
import 'app_back_button.dart';

/// The frame a pushed screen sits in: a back (or close) button, a title, an
/// optional trailing action, and the content under it.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.showBack = true,
    this.showClose = false,
    this.action,
    this.bottom,
    this.padded = true,
  });

  final Widget body;
  final String? title;
  final bool showBack;

  /// Swaps the back arrow for an X, for screens that behave like a modal.
  final bool showClose;

  final Widget? action;

  /// Pinned under the content, above the safe area -- usually the main button.
  final Widget? bottom;

  final bool padded;

  @override
  Widget build(BuildContext context) {
    final Widget leading = showClose
        ? const AppCloseButton()
        : showBack
            ? const AppBackButton()
            : const SizedBox(width: 44);

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.screenPadding - 4,
                8,
                AppDimens.screenPadding - 4,
                8,
              ),
              child: Row(
                children: <Widget>[
                  leading,
                  Expanded(
                    child: title == null
                        ? const SizedBox.shrink()
                        : Text(
                            title!,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.titleLarge,
                          ),
                  ),
                  action ?? const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: padded
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.screenPadding,
                      ),
                      child: body,
                    )
                  : body,
            ),
            if (bottom != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPadding,
                  8,
                  AppDimens.screenPadding,
                  16,
                ),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}
