import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cores da marca (vêm do logótipo). Os ecrãs usam sempre `colorScheme`;
/// estas constantes só alimentam o tema.
class AppColors {
  static const Color brand = Color(0xFF009EEB); // azul da lente
  static const Color brandDeep = Color(0xFF0B5FD0);
  static const Color accent = Color(0xFFF2504B); // vermelho do logótipo
}

/// Escala de espaçamento (múltiplos de 4) e raios usados em toda a app.
class AppSpacing {
  static const double xs = 4, sm = 8, md = 12, lg = 16, xl = 24, xxl = 32;
}

class AppRadius {
  static const double sm = 12, md = 16, lg = 20, xl = 28;
}

ColorScheme _scheme(Brightness brightness) {
  final base = ColorScheme.fromSeed(
    seedColor: AppColors.brand,
    brightness: brightness,
  );
  if (brightness == Brightness.light) {
    return base.copyWith(
      primary: const Color(0xFF0070C0), // 5.4:1 com texto branco
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD3E8FB),
      onPrimaryContainer: const Color(0xFF00315A),
      tertiary: const Color(0xFFC62F2B),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFFDAD6),
      onTertiaryContainer: const Color(0xFF410002),
      surface: const Color(0xFFF6F8FB),
      onSurface: const Color(0xFF14181F),
      onSurfaceVariant: const Color(0xFF4A5565),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFFFFFFF),
      surfaceContainer: const Color(0xFFEDF1F6),
      surfaceContainerHigh: const Color(0xFFE5EAF1),
      surfaceContainerHighest: const Color(0xFFDDE3EB),
      outlineVariant: const Color(0xFFD3DAE3),
    );
  }
  return base.copyWith(
    primary: const Color(0xFF6BC4FF),
    onPrimary: const Color(0xFF00243F),
    primaryContainer: const Color(0xFF0B3F6B),
    onPrimaryContainer: const Color(0xFFD3E8FB),
    tertiary: const Color(0xFFFF8A83),
    onTertiary: const Color(0xFF4A0A07),
    tertiaryContainer: const Color(0xFF7A1F1B),
    onTertiaryContainer: const Color(0xFFFFDAD6),
    surface: const Color(0xFF0E1116),
    onSurface: const Color(0xFFE6EAF0),
    onSurfaceVariant: const Color(0xFFA9B3C1),
    surfaceContainerLowest: const Color(0xFF0A0D11),
    surfaceContainerLow: const Color(0xFF14181F),
    surfaceContainer: const Color(0xFF181D25),
    surfaceContainerHigh: const Color(0xFF1F252E),
    surfaceContainerHighest: const Color(0xFF282F3A),
    outlineVariant: const Color(0xFF303846),
  );
}

ThemeData _buildTheme(Brightness brightness) {
  final scheme = _scheme(brightness);
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
  );

  final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
      .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

  RoundedRectangleBorder shape(double r) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));

  return base.copyWith(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardTheme(
      color: scheme.surfaceContainerLow,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: scheme.error, width: 1.5),
      ),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      prefixIconColor: scheme.onSurfaceVariant,
      suffixIconColor: scheme.onSurfaceVariant,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: shape(AppRadius.md),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: shape(AppRadius.md),
        side: BorderSide(color: scheme.outlineVariant),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: shape(AppRadius.sm),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 3,
      extendedTextStyle:
          textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      shape: shape(AppRadius.lg),
    ),
    chipTheme: ChipThemeData(
      shape: shape(AppRadius.sm),
      side: BorderSide(color: scheme.outlineVariant),
      labelStyle: textTheme.labelLarge,
      backgroundColor: scheme.surfaceContainerLow,
      selectedColor: scheme.primaryContainer,
      checkmarkColor: scheme.onPrimaryContainer,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: shape(AppRadius.md),
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: shape(AppRadius.xl),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape: shape(AppRadius.md),
      textStyle: textTheme.bodyLarge,
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primaryContainer,
      indicatorShape: shape(AppRadius.lg),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        shape: shape(AppRadius.sm),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }),
  );
}

final ThemeData lightTheme = _buildTheme(Brightness.light);
final ThemeData darkTheme = _buildTheme(Brightness.dark);

ThemeData getTheme(Brightness brightness) {
  return brightness == Brightness.light ? lightTheme : darkTheme;
}
