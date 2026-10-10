import 'package:flutter/material.dart';

/// The app palette, as a [ThemeExtension] so every widget reads the colours of
/// the active theme (light or dark) through `context.palette`.
///
/// The look is monochrome -- ink black on warm paper, or the reverse in dark
/// mode -- lit by an electric lime accent for progress and highlights, with a
/// lime-and-orange "aurora" glowing behind the black hero surfaces.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.primary,
    required this.primarySoft,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.income,
    required this.incomeSoft,
    required this.expense,
    required this.expenseSoft,
    required this.warning,
    required this.warningSoft,
    required this.warningInk,
    required this.danger,
    required this.dangerSoft,
    required this.heroStart,
    required this.heroEnd,
    required this.onHero,
    required this.glowA,
    required this.glowB,
    required this.shadow,
  });

  final Color background;
  final Color surface;

  /// Inputs, chips and the track behind a progress bar.
  final Color surfaceAlt;
  final Color border;

  final Color primary;
  final Color primarySoft;
  final Color onPrimary;

  /// The lime used for progress and highlights on the hero card.
  final Color accent;
  final Color onAccent;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  final Color income;
  final Color incomeSoft;
  final Color expense;
  final Color expenseSoft;
  final Color warning;
  final Color warningSoft;

  /// A deeper amber for the warning colour on a light surface, where the
  /// gold itself is too pale to read.
  final Color warningInk;
  final Color danger;
  final Color dangerSoft;

  /// The two ends of the gradient on the hero card and the splash screen.
  final Color heroStart;
  final Color heroEnd;
  final Color onHero;

  /// The two glows that drift behind the black hero surfaces -- the
  /// "aurora" that gives the monochrome look its colour.
  final Color glowA;
  final Color glowB;

  final Color shadow;

  LinearGradient get heroGradient => LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: <Color>[heroStart, heroEnd],
      );

  List<BoxShadow> get cardShadow => <BoxShadow>[
        BoxShadow(
          color: shadow,
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static const AppPalette light = AppPalette(
    background: Color(0xFFF4F4F1),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFECECE7),
    border: Color(0xFFE2E2DC),
    primary: Color(0xFF111112),
    primarySoft: Color(0xFFEDF8C8),
    onPrimary: Color(0xFFD4FF3F),
    accent: Color(0xFFD4FF3F),
    onAccent: Color(0xFF111112),
    textPrimary: Color(0xFF111112),
    textSecondary: Color(0xFF5E5E59),
    textMuted: Color(0xFF9D9D96),
    income: Color(0xFF0FA876),
    incomeSoft: Color(0xFFDDF5EA),
    expense: Color(0xFFF2545B),
    expenseSoft: Color(0xFFFDE8E9),
    warning: Color(0xFFF2C12E),
    warningSoft: Color(0xFFFFF6D6),
    warningInk: Color(0xFFB7791F),
    danger: Color(0xFFE5383F),
    dangerSoft: Color(0xFFFDE7E8),
    heroStart: Color(0xFF09090A),
    heroEnd: Color(0xFF26262A),
    onHero: Color(0xFFFFFFFF),
    glowA: Color(0xFFD4FF3F),
    glowB: Color(0xFFFF7A1A),
    shadow: Color(0x1A000000),
  );

  static const AppPalette dark = AppPalette(
    background: Color(0xFF0A0A0B),
    surface: Color(0xFF151517),
    surfaceAlt: Color(0xFF1F1F22),
    border: Color(0xFF2A2A2E),
    primary: Color(0xFFD4FF3F),
    primarySoft: Color(0xFF2A3312),
    onPrimary: Color(0xFF111112),
    accent: Color(0xFFD4FF3F),
    onAccent: Color(0xFF111112),
    textPrimary: Color(0xFFF4F4F2),
    textSecondary: Color(0xFFA8A8A2),
    textMuted: Color(0xFF6E6E69),
    income: Color(0xFF34D399),
    incomeSoft: Color(0xFF11342A),
    expense: Color(0xFFFF6B70),
    expenseSoft: Color(0xFF3A1C1E),
    warning: Color(0xFFFFD04D),
    warningSoft: Color(0xFF3A3110),
    warningInk: Color(0xFFFFD04D),
    danger: Color(0xFFFF6B70),
    dangerSoft: Color(0xFF3A1C1E),
    heroStart: Color(0xFF19191C),
    heroEnd: Color(0xFF2C2C31),
    onHero: Color(0xFFFFFFFF),
    glowA: Color(0xFFD4FF3F),
    glowB: Color(0xFFFF7A1A),
    shadow: Color(0x40000000),
  );

  /// The tints a category avatar can take; picked by hashing the category id
  /// so the same category always gets the same colour.
  static const List<Color> categoryTints = <Color>[
    Color(0xFF8B5CF6),
    Color(0xFF22C3EE),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF10B981),
    Color(0xFF3B82F6),
    Color(0xFFF97316),
    Color(0xFF84CC16),
    Color(0xFF14B8A6),
    Color(0xFFEF4444),
  ];

  static Color tintFor(String id) {
    int hash = 0;
    for (final int unit in id.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return categoryTints[hash % categoryTints.length];
  }

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceAlt: l(surfaceAlt, other.surfaceAlt),
      border: l(border, other.border),
      primary: l(primary, other.primary),
      primarySoft: l(primarySoft, other.primarySoft),
      onPrimary: l(onPrimary, other.onPrimary),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      income: l(income, other.income),
      incomeSoft: l(incomeSoft, other.incomeSoft),
      expense: l(expense, other.expense),
      expenseSoft: l(expenseSoft, other.expenseSoft),
      warning: l(warning, other.warning),
      warningSoft: l(warningSoft, other.warningSoft),
      warningInk: l(warningInk, other.warningInk),
      danger: l(danger, other.danger),
      dangerSoft: l(dangerSoft, other.dangerSoft),
      heroStart: l(heroStart, other.heroStart),
      heroEnd: l(heroEnd, other.heroEnd),
      onHero: l(onHero, other.onHero),
      glowA: l(glowA, other.glowA),
      glowB: l(glowB, other.glowB),
      shadow: l(shadow, other.shadow),
    );
  }
}
