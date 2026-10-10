import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimens.dart';

/// The light and dark [ThemeData] the app runs on, both built from
/// [AppPalette] so a widget never has to know which one is active.
class AppTheme {
  const AppTheme._();

  static const String fontFamily = 'Rubik';

  static ThemeData get light => _build(AppPalette.light, Brightness.light);

  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  static TextTheme _textTheme(AppPalette p) {
    TextStyle s(double size, FontWeight weight, Color color,
            {double height = 1.3, double spacing = 0}) =>
        TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: weight,
          color: color,
          height: height,
          letterSpacing: spacing,
        );

    return TextTheme(
      displayMedium: s(40, FontWeight.w700, p.textPrimary, height: 1.1, spacing: -1),
      displaySmall: s(32, FontWeight.w700, p.textPrimary, height: 1.15, spacing: -0.5),
      headlineMedium: s(26, FontWeight.w700, p.textPrimary, height: 1.2),
      headlineSmall: s(22, FontWeight.w700, p.textPrimary, height: 1.25),
      titleLarge: s(19, FontWeight.w600, p.textPrimary),
      titleMedium: s(16, FontWeight.w600, p.textPrimary),
      titleSmall: s(14, FontWeight.w600, p.textPrimary),
      bodyLarge: s(16, FontWeight.w400, p.textPrimary, height: 1.5),
      bodyMedium: s(14, FontWeight.w400, p.textSecondary, height: 1.45),
      bodySmall: s(12, FontWeight.w400, p.textMuted, height: 1.4),
      labelLarge: s(15, FontWeight.w600, p.textPrimary),
      labelMedium: s(13, FontWeight.w500, p.textSecondary),
      labelSmall: s(11, FontWeight.w500, p.textMuted, spacing: 0.2),
    );
  }

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: brightness,
    ).copyWith(
      primary: p.primary,
      onPrimary: p.onPrimary,
      secondary: p.accent,
      onSecondary: p.onAccent,
      surface: p.surface,
      onSurface: p.textPrimary,
      error: p.danger,
      outline: p.border,
    );
    final TextTheme text = _textTheme(p);
    final SystemUiOverlayStyle overlay =
        isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: text,
      scaffoldBackgroundColor: p.background,
      extensions: <ThemeExtension<dynamic>>[p],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: p.textPrimary),
        systemOverlayStyle: overlay,
      ),
      iconTheme: IconThemeData(color: p.textPrimary),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.primary,
        selectionColor: p.primary.withValues(alpha: 0.25),
        selectionHandleColor: p.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceAlt,
        hintStyle: text.bodyLarge?.copyWith(color: p.textMuted),
        labelStyle: text.bodyMedium,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          borderSide: BorderSide(color: p.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          borderSide: BorderSide(color: p.danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          borderSide: BorderSide(color: p.danger, width: 1.6),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusHero),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? p.surfaceAlt : p.textPrimary,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: isDark ? p.textPrimary : p.surface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) =>
              s.contains(WidgetState.selected) ? p.onPrimary : p.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) =>
              s.contains(WidgetState.selected) ? p.primary : p.surfaceAlt,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: p.heroStart,
        headerForegroundColor: p.onHero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
    );
  }
}

/// Short access to the active palette and type ramp.
extension ThemeContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  TextTheme get text => Theme.of(this).textTheme;
}
