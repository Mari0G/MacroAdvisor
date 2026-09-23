import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macro_advisor/src/features/settings/domain/app_palette.dart';

@immutable
class TypeCTokens extends ThemeExtension<TypeCTokens> {
  static TypeCTokens of(BuildContext context) =>
      Theme.of(context).extension<TypeCTokens>() ??
      AppTheme.forPalette(AppPalette.lime).extension<TypeCTokens>()!;

  const TypeCTokens({
    required this.background,
    required this.card,
    required this.line,
    required this.soft,
    required this.muted,
    required this.meal,
    required this.notice,
    required this.heroStart,
    required this.heroEnd,
    required this.heroGlow,
  });

  final Color background, card, line, soft, muted, meal, notice;
  final Color heroStart, heroEnd, heroGlow;

  @override
  TypeCTokens copyWith({
    Color? background,
    Color? card,
    Color? line,
    Color? soft,
    Color? muted,
    Color? meal,
    Color? notice,
    Color? heroStart,
    Color? heroEnd,
    Color? heroGlow,
  }) => TypeCTokens(
    background: background ?? this.background,
    card: card ?? this.card,
    line: line ?? this.line,
    soft: soft ?? this.soft,
    muted: muted ?? this.muted,
    meal: meal ?? this.meal,
    notice: notice ?? this.notice,
    heroStart: heroStart ?? this.heroStart,
    heroEnd: heroEnd ?? this.heroEnd,
    heroGlow: heroGlow ?? this.heroGlow,
  );

  @override
  TypeCTokens lerp(ThemeExtension<TypeCTokens>? other, double t) {
    if (other is! TypeCTokens) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return TypeCTokens(
      background: mix(background, other.background),
      card: mix(card, other.card),
      line: mix(line, other.line),
      soft: mix(soft, other.soft),
      muted: mix(muted, other.muted),
      meal: mix(meal, other.meal),
      notice: mix(notice, other.notice),
      heroStart: mix(heroStart, other.heroStart),
      heroEnd: mix(heroEnd, other.heroEnd),
      heroGlow: mix(heroGlow, other.heroGlow),
    );
  }
}

abstract final class AppTheme {
  static ThemeData forPalette(AppPalette palette) {
    final (ink, accent, accentInk, tokens) = switch (palette) {
      AppPalette.lime => (
        const Color(0xfff6f4ff),
        const Color(0xffb7f36b),
        const Color(0xff14200b),
        const TypeCTokens(
          background: Color(0xff111325),
          card: Color(0xff1b1e36),
          line: Color(0xff303450),
          soft: Color(0xff292c49),
          muted: Color(0xffa9a9c0),
          meal: Color(0xff513f72),
          notice: Color(0xff282c4b),
          heroStart: Color(0xff262a4d),
          heroEnd: Color(0xff181a2e),
          heroGlow: Color(0x557357ff),
        ),
      ),
      AppPalette.ocean => (
        const Color(0xfff1f8ff),
        const Color(0xff58d7ff),
        const Color(0xff05202a),
        const TypeCTokens(
          background: Color(0xff091523),
          card: Color(0xff122238),
          line: Color(0xff28405a),
          soft: Color(0xff1a3049),
          muted: Color(0xff9aadc1),
          meal: Color(0xff174b69),
          notice: Color(0xff152d43),
          heroStart: Color(0xff173653),
          heroEnd: Color(0xff0d1c2e),
          heroGlow: Color(0x551ea7ff),
        ),
      ),
      AppPalette.coral => (
        const Color(0xfffff5f1),
        const Color(0xffff906d),
        const Color(0xff2a0d06),
        const TypeCTokens(
          background: Color(0xff211316),
          card: Color(0xff321c21),
          line: Color(0xff55323a),
          soft: Color(0xff43262d),
          muted: Color(0xffc3a6a1),
          meal: Color(0xff6a342f),
          notice: Color(0xff44252a),
          heroStart: Color(0xff4a2428),
          heroEnd: Color(0xff28161a),
          heroGlow: Color(0x55ff654e),
        ),
      ),
      AppPalette.violet => (
        const Color(0xfffbf4ff),
        const Color(0xffdfa1ff),
        const Color(0xff260d32),
        const TypeCTokens(
          background: Color(0xff171021),
          card: Color(0xff281936),
          line: Color(0xff49305e),
          soft: Color(0xff38234a),
          muted: Color(0xffb9a6c5),
          meal: Color(0xff56316b),
          notice: Color(0xff352047),
          heroStart: Color(0xff402457),
          heroEnd: Color(0xff21152e),
          heroGlow: Color(0x55c552ff),
        ),
      ),
    };
    final scheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ).copyWith(
          primary: accent,
          onPrimary: accentInk,
          secondary: accent,
          onSecondary: accentInk,
          surface: tokens.background,
          onSurface: ink,
          surfaceContainerLow: tokens.card,
          surfaceContainer: tokens.card,
          surfaceContainerHigh: tokens.soft,
          surfaceContainerHighest: tokens.soft,
          outline: tokens.line,
          outlineVariant: tokens.line,
          onSurfaceVariant: tokens.muted,
          error: const Color(0xffffb4ab),
          onError: const Color(0xff690005),
        );
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(color: tokens.line),
    );
    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: color, width: width),
        );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: tokens.background,
      canvasColor: tokens.background,
      focusColor: accent.withValues(alpha: .2),
      extensions: [tokens],
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 29,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        toolbarHeight: 76,
        backgroundColor: tokens.background,
        foregroundColor: ink,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: tokens.background,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: tokens.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: tokens.card,
        margin: EdgeInsets.zero,
        elevation: 8,
        shadowColor: const Color(0x33000000),
        shape: rounded,
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.card,
        shape: rounded,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.card,
        border: inputBorder(tokens.line),
        enabledBorder: inputBorder(tokens.line),
        focusedBorder: inputBorder(accent, 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          side: BorderSide(color: tokens.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: accentInk,
        shape: const CircleBorder(),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: tokens.soft,
        circularTrackColor: tokens.soft,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? accentInk : tokens.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? accent : tokens.soft,
        ),
      ),
    );
  }
}
