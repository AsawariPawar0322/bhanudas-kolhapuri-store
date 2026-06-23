import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Luxury 'Handcrafted Heritage' Palette
  static const Color primaryColor = Color(0xFFD4AF37); // Champagne Gold
  static const Color primaryDark = Color(0xFFB8860B);  // Dark Goldenrod
  static const Color primaryLight = Color(0xFFF1E5AC); // Soft Pearl
  static const Color secondaryColor = Color(0xFF8B0000); // Deep Velvet Red (Heritage)
  static const Color accentColor = Color(0xFFE9DCC9);  // Linen/Ivory
  static const Color dangerColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF27AE60);

  // Deep Obsidian Theme Colors
  static const Color bgDark = Color(0xFF0A0A0B);
  static const Color bgSurface = Color(0xFF141416);
  static const Color bgCard = Color(0xFF1C1C1E);

  // Refined Text Colors
  static const Color textPrimary = Color(0xFFFDFDFD);
  static const Color textSecondary = Color(0xFFC5C5C7);
  static const Color textMuted = Color(0xFF727274);

  static const LinearGradient luxuryGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient charcoalGradient = LinearGradient(
    colors: [Color(0xFF1C1C1E), Color(0xFF0A0A0B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Backward compatibility aliases
  static const LinearGradient primaryGradient = luxuryGradient;
  static const LinearGradient accentGradient = luxuryGradient;
  static const LinearGradient warmGradient = luxuryGradient;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: bgSurface,
        onSurface: textPrimary,
        error: dangerColor,
      ),
      
      // Luxury Typography
      textTheme: GoogleFonts.montserratTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(fontSize: 34, fontWeight: FontWeight.w900, color: textPrimary, letterSpacing: -0.5),
        displayMedium: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w800, color: textPrimary),
        displaySmall: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
        headlineMedium: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
        bodyLarge: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5),
        bodyMedium: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
      ),

      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.03)),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: bgDark.withOpacity(0.8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: bgDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
      ),
    );
  }
}

class AppDecorations {
  static BoxDecoration get glassCard => BoxDecoration(
        color: AppTheme.bgCard.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      );

  static BoxDecoration get premiumBordered => BoxDecoration(
    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
    borderRadius: BorderRadius.circular(24),
    color: AppTheme.bgSurface,
  );

  static InputDecoration inputDecoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor.withOpacity(0.7), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.03)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
      );

  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.bgDark,
        padding: const EdgeInsets.symmetric(vertical: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 10,
        shadowColor: AppTheme.primaryColor.withOpacity(0.3),
      );

  static ButtonStyle get secondaryButton => OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
        side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      );

  static BoxDecoration get gradientCard => BoxDecoration(
        gradient: AppTheme.luxuryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      );
}

