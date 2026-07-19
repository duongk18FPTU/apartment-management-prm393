import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System: Modern Haven
///
/// Single source of truth for all visual tokens in the app.
/// Sourced directly from DESIGN.md at the project root.
///
/// Rules enforced by this file:
/// - NO widget in the codebase may use [Color], [Colors.*], or [Color(0xFF...)]
///   directly. Always consume tokens via [Theme.of(context).colorScheme].
/// - All typographic styles use [GoogleFonts.outfit] (Display/Headline) or
///   [GoogleFonts.inter] (Body/Label). No system fonts.
/// - Spacing follows an 8dp grid: xs=4, sm=8, md=16, lg=24, xl=32.

// ---------------------------------------------------------------------------
// Design Tokens (mirror of DESIGN.md YAML front-matter)
// ---------------------------------------------------------------------------

/// Raw color values from DESIGN.md — reference only.
/// Do not import this class into widgets; use [Theme.of(context)] instead.
abstract final class DesignTokens {
  // Primary palette
  static const Color primary = Color(
    0xFF1E293B,
  ); // Slate-800 — authority, structure
  static const Color primaryContainer = Color(0xFF334155); // Slate-700
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary palette — Warm Amber
  static const Color secondary = Color(
    0xFFD97706,
  ); // Amber-600 — warmth, action
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFEF3C7); // Amber-100

  // Tertiary palette — Teal (financial / success states)
  static const Color tertiary = Color(0xFF0D9488); // Teal-600
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFCCFBF1); // Teal-100

  // Surface / Background
  static const Color background = Color(
    0xFFF8FAFC,
  ); // Soft warm slate — easy on eyes
  static const Color surface = Color(0xFFFFFFFF); // Pure white — cards, dialogs
  static const Color surfaceVariant = Color(
    0xFFF1F5F9,
  ); // Slate-100 — subtle dividers

  // Foreground / Text
  static const Color onBackground = Color(
    0xFF0F172A,
  ); // Slate-900 — primary text
  static const Color onSurface = Color(0xFF1E293B); // Slate-800 — card text
  static const Color neutralVariant = Color(
    0xFF64748B,
  ); // Slate-500 — hints, secondary text

  // Semantic states
  static const Color error = Color(0xFFE11D48); // Rose-600
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color warning = Color(0xFFF59E0B); // Amber-500

  // Elevation shadows (DESIGN.md Level 1 & Level 2)
  static const Color shadowColor = Color(0xFF0F172A); // Slate-900 tinted shadow
}

/// Spacing constants from DESIGN.md — 8dp grid.
abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

/// Border radius constants from DESIGN.md.
abstract final class AppRadius {
  static const double sm = 8.0; // Tags, badges, input fields
  static const double md = 12.0; // Cards, buttons, dialogs
  static const double lg = 24.0; // Bottom sheets, FABs, chips

  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
}

// ---------------------------------------------------------------------------
// TextTheme
// ---------------------------------------------------------------------------

/// Builds the [TextTheme] using Google Fonts:
/// - Outfit  → Display, Headline, Title
/// - Inter   → Body, Label
TextTheme _buildTextTheme() {
  return TextTheme(
    // --- Display (Outfit, 700) ---
    displayLarge: GoogleFonts.outfit(
      fontSize: 57,
      fontWeight: FontWeight.w700,
      color: DesignTokens.onBackground,
      letterSpacing: -0.25,
    ),
    displayMedium: GoogleFonts.outfit(
      fontSize: 45,
      fontWeight: FontWeight.w700,
      color: DesignTokens.onBackground,
    ),
    displaySmall: GoogleFonts.outfit(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      color: DesignTokens.onBackground,
    ),

    // --- Headline (Outfit, 600) — screen titles, section headers ---
    headlineLarge: GoogleFonts.outfit(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: DesignTokens.onBackground,
    ),
    headlineMedium: GoogleFonts.outfit(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: DesignTokens.onBackground,
    ),
    headlineSmall: GoogleFonts.outfit(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: DesignTokens.onBackground,
    ),

    // --- Title (Outfit, 500) — card headers, list group titles ---
    titleLarge: GoogleFonts.outfit(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: DesignTokens.onBackground,
    ),
    titleMedium: GoogleFonts.outfit(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: DesignTokens.onSurface,
      letterSpacing: 0.15,
    ),
    titleSmall: GoogleFonts.outfit(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: DesignTokens.onSurface,
      letterSpacing: 0.1,
    ),

    // --- Body (Inter, 400) — readable prose, form fields ---
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: DesignTokens.onBackground,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: DesignTokens.onSurface,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: DesignTokens.neutralVariant,
      height: 1.4,
    ),

    // --- Label (Inter, 500) — buttons, tags, dense UI labels ---
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: DesignTokens.onBackground,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: DesignTokens.neutralVariant,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: DesignTokens.neutralVariant,
      letterSpacing: 0.5,
    ),
  );
}

// ---------------------------------------------------------------------------
// ColorScheme
// ---------------------------------------------------------------------------

/// Material 3 [ColorScheme] built from DESIGN.md tokens.
const ColorScheme _colorScheme = ColorScheme(
  brightness: Brightness.light,

  // Primary — Slate
  primary: DesignTokens.primary,
  onPrimary: DesignTokens.onPrimary,
  primaryContainer: DesignTokens.primaryContainer,
  onPrimaryContainer: DesignTokens.onPrimary,

  // Secondary — Amber
  secondary: DesignTokens.secondary,
  onSecondary: DesignTokens.onSecondary,
  secondaryContainer: DesignTokens.secondaryContainer,
  onSecondaryContainer: DesignTokens.primary,

  // Tertiary — Teal
  tertiary: DesignTokens.tertiary,
  onTertiary: DesignTokens.onTertiary,
  tertiaryContainer: DesignTokens.tertiaryContainer,
  onTertiaryContainer: DesignTokens.primary,

  // Surface (M3 replaces background with surface hierarchy)
  surface: DesignTokens.background,
  onSurface: DesignTokens.onBackground,
  surfaceContainerHighest: DesignTokens.surface,
  onSurfaceVariant: DesignTokens.neutralVariant,

  // Semantic
  error: DesignTokens.error,
  onError: DesignTokens.onError,
  errorContainer: Color(0xFFFEE2E2), // Rose-100
  onErrorContainer: Color(0xFF9F1239), // Rose-800
  // Structural
  outline: DesignTokens.neutralVariant,
  outlineVariant: Color(0xFFE2E8F0), // Slate-200
  shadow: DesignTokens.shadowColor,
  scrim: DesignTokens.primary,
  inverseSurface: DesignTokens.primary,
  onInverseSurface: DesignTokens.onPrimary,
  inversePrimary: DesignTokens.secondary,
  surfaceTint: DesignTokens.primary,
);

// ---------------------------------------------------------------------------
// Component Themes
// ---------------------------------------------------------------------------

AppBarTheme _buildAppBarTheme(TextTheme textTheme) => AppBarTheme(
  backgroundColor: DesignTokens.primary,
  foregroundColor: DesignTokens.onPrimary,
  elevation: 0,
  scrolledUnderElevation: 2,
  shadowColor: DesignTokens.shadowColor.withValues(alpha: 0.15),
  centerTitle: false,
  titleTextStyle: textTheme.titleLarge?.copyWith(
    color: DesignTokens.onPrimary,
    fontWeight: FontWeight.w600,
  ),
  iconTheme: const IconThemeData(color: DesignTokens.onPrimary),
);

CardThemeData _buildCardTheme() => const CardThemeData(
  color: DesignTokens.surface,
  elevation: 0,
  shadowColor: DesignTokens.shadowColor,
  shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
  margin: EdgeInsets.zero,
  surfaceTintColor: Colors.transparent,
);

ElevatedButtonThemeData _buildElevatedButtonTheme(TextTheme textTheme) =>
    ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignTokens.primary,
        foregroundColor: DesignTokens.onPrimary,
        disabledBackgroundColor: DesignTokens.neutralVariant.withValues(
          alpha: 0.12,
        ),
        disabledForegroundColor: DesignTokens.neutralVariant,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        minimumSize: const Size(double.infinity, 52),
      ),
    );

OutlinedButtonThemeData _buildOutlinedButtonTheme(TextTheme textTheme) =>
    OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DesignTokens.primary,
        side: const BorderSide(color: DesignTokens.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        minimumSize: const Size(double.infinity, 52),
      ),
    );

TextButtonThemeData _buildTextButtonTheme(TextTheme textTheme) =>
    TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DesignTokens.secondary,
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
    );

InputDecorationTheme _buildInputDecorationTheme(TextTheme textTheme) =>
    InputDecorationTheme(
      filled: true,
      fillColor: DesignTokens.surface,
      border: OutlineInputBorder(
        borderRadius: AppRadius.borderSm,
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Slate-200
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderSm,
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderSm,
        borderSide: const BorderSide(color: DesignTokens.secondary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderSm,
        borderSide: const BorderSide(color: DesignTokens.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderSm,
        borderSide: const BorderSide(color: DesignTokens.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: DesignTokens.neutralVariant,
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: DesignTokens.neutralVariant,
      ),
      errorStyle: textTheme.bodySmall?.copyWith(color: DesignTokens.error),
    );

ChipThemeData _buildChipTheme(TextTheme textTheme) => ChipThemeData(
  backgroundColor: DesignTokens.surfaceVariant,
  selectedColor: DesignTokens.secondary.withValues(alpha: 0.15),
  labelStyle: textTheme.labelMedium?.copyWith(color: DesignTokens.onSurface),
  shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
  side: BorderSide.none,
  padding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.sm,
    vertical: AppSpacing.xs,
  ),
);

DividerThemeData _buildDividerTheme() => const DividerThemeData(
  color: Color(0xFFE2E8F0), // Slate-200
  thickness: 1,
  space: 1,
);

FloatingActionButtonThemeData _buildFabTheme() =>
    const FloatingActionButtonThemeData(
      backgroundColor: DesignTokens.secondary,
      foregroundColor: DesignTokens.onSecondary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
    );

BottomNavigationBarThemeData _buildBottomNavTheme(TextTheme textTheme) =>
    BottomNavigationBarThemeData(
      backgroundColor: DesignTokens.surface,
      selectedItemColor: DesignTokens.secondary,
      unselectedItemColor: DesignTokens.neutralVariant,
      selectedLabelStyle: textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: textTheme.labelSmall,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    );

NavigationBarThemeData _buildNavigationBarTheme(TextTheme textTheme) =>
    NavigationBarThemeData(
      backgroundColor: DesignTokens.surface,
      indicatorColor: DesignTokens.secondary.withValues(alpha: 0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: DesignTokens.secondary);
        }
        return const IconThemeData(color: DesignTokens.neutralVariant);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return textTheme.labelSmall?.copyWith(
            color: DesignTokens.secondary,
            fontWeight: FontWeight.w600,
          );
        }
        return textTheme.labelSmall?.copyWith(
          color: DesignTokens.neutralVariant,
        );
      }),
      elevation: 3,
    );

// ---------------------------------------------------------------------------
// Public ThemeData factory
// ---------------------------------------------------------------------------

/// Returns the complete [ThemeData] for the app.
///
/// Import this in [app.dart]:
/// ```dart
/// import 'theme.dart';
/// MaterialApp.router(theme: buildAppTheme(), ...)
/// ```
ThemeData buildAppTheme() {
  final textTheme = _buildTextTheme();

  return ThemeData(
    useMaterial3: true,
    colorScheme: _colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: DesignTokens.background,

    // Component themes
    appBarTheme: _buildAppBarTheme(textTheme),
    cardTheme: _buildCardTheme(),
    elevatedButtonTheme: _buildElevatedButtonTheme(textTheme),
    outlinedButtonTheme: _buildOutlinedButtonTheme(textTheme),
    textButtonTheme: _buildTextButtonTheme(textTheme),
    inputDecorationTheme: _buildInputDecorationTheme(textTheme),
    chipTheme: _buildChipTheme(textTheme),
    dividerTheme: _buildDividerTheme(),
    floatingActionButtonTheme: _buildFabTheme(),
    bottomNavigationBarTheme: _buildBottomNavTheme(textTheme),
    navigationBarTheme: _buildNavigationBarTheme(textTheme),

    // Page transitions — subtle fade for mobile feel
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
