// lib/utils/app_theme.dart
// Global design system for Timeless
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class AppTheme {
  // Primary colors
  // Timeless brand identity colors
  static const Color primaryRed = Color(0xFF6E0803);
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color secondaryGold = Color(0xFFFFD23F);
  static const Color accentYellow = Color(0xFFFFE135);
  
  // New button border color (dark blue)
  static const Color buttonBorderColor = Color(0xFF000647);
  
  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF2C2C2C);
  static const Color mediumGrey = Color(0xFF6B6B6B);
  static const Color lightGrey = Color(0xFFE5E5E5);
  static const Color backgroundGrey = Color(0xFFF8F9FA);
  
  // Status colors
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryOrange, secondaryGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient headerGradient = LinearGradient(
    colors: [primaryRed, primaryOrange],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // --- SECTION: TYPOGRAPHY ---

  // TYPOGRAPHIE --- SECTION: 

  
  // Tailles de texte
  static const double fontSizeXSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeRegular = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeTitle = 28.0;
  static const double fontSizeHero = 32.0;
  
  // Styles de texte principaux
  static TextStyle get headingHero => GoogleFonts.poppins(
    fontSize: fontSizeHero,
    fontWeight: FontWeight.bold,
    color: darkGrey,
    letterSpacing: -0.5,
  );
  
  static TextStyle get headingTitle => GoogleFonts.poppins(
    fontSize: fontSizeTitle,
    fontWeight: FontWeight.w600,
    color: darkGrey,
  );
  
  static TextStyle get headingLarge => GoogleFonts.poppins(
    fontSize: fontSizeXLarge,
    fontWeight: FontWeight.w600,
    color: darkGrey,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.normal,
    color: darkGrey,
  );
  
  static TextStyle get bodyRegular => GoogleFonts.poppins(
    fontSize: fontSizeRegular,
    fontWeight: FontWeight.normal,
    color: darkGrey,
  );
  
  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: fontSizeSmall,
    fontWeight: FontWeight.normal,
    color: mediumGrey,
  );
  
  static TextStyle get buttonText => GoogleFonts.poppins(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.w600,
    color: black,
  );
  
  static TextStyle get captionText => GoogleFonts.poppins(
    fontSize: fontSizeXSmall,
    fontWeight: FontWeight.normal,
    color: mediumGrey,
  );
  
  // --- SECTION: SPACING ---

  // ESPACEMENT --- SECTION: 

  
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingRegular = 16.0;
  static const double spacingMedium = 20.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;
  
  // --- SECTION: BORDERS AND RADIUS ---

  // BORDURES ET RAYONS --- SECTION: 

  
  static const double radiusSmall = 8.0;
  static const double radiusRegular = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusCircle = 50.0;
  
  // --- SECTION: SHADOWS ---

  // OMBRES --- SECTION: 

  
  static List<BoxShadow> get shadowLight => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get shadowRegular => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      offset: const Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.16),
      offset: const Offset(0, 6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get shadowLarge => [
    BoxShadow(
      color: Colors.black.withOpacity(0.20),
      offset: const Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
  
  // --- SECTION: UI COMPONENTS ---

  // COMPOSANTS UI --- SECTION: 

  
  
  // Style de carte
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(radiusRegular),
    boxShadow: shadowRegular,
  );
  
  // Style de container principal
  static BoxDecoration get containerDecoration => BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: shadowLight,
  );
  
  // Style de bouton principal
  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
    color: white,
    borderRadius: BorderRadius.all(Radius.circular(radiusRegular)),
    border: Border.all(color: buttonBorderColor, width: 1.0),
  );
  
  // Style de bouton secondaire
  static BoxDecoration get secondaryButtonDecoration => BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(radiusRegular),
    border: Border.all(color: buttonBorderColor, width: 1.0),
  );
  
  // Style de champ de saisie
  static InputDecoration getInputDecoration({
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: fontSizeRegular,
        color: mediumGrey,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: errorText,
      filled: true,
      fillColor: white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingRegular,
        vertical: spacingSmall,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRegular),
        borderSide: const BorderSide(color: buttonBorderColor, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRegular),
        borderSide: const BorderSide(color: buttonBorderColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRegular),
        borderSide: const BorderSide(color: buttonBorderColor, width: 1.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRegular),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRegular),
        borderSide: const BorderSide(color: error, width: 2.0),
      ),
    );
  }
  
  // --- SECTION: FLUTTER THEMES ---

  // THÈMES FLUTTER --- SECTION: 

  
  
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryOrange,
      brightness: Brightness.light,
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,
    scaffoldBackgroundColor: backgroundGrey,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: headingLarge.copyWith(color: darkGrey),
      iconTheme: const IconThemeData(color: darkGrey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: white,
        foregroundColor: black,
        side: BorderSide(color: buttonBorderColor, width: 2.0),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLarge,
          vertical: spacingRegular,
        ),
        textStyle: buttonText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusRegular),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: black,
        backgroundColor: white,
        side: BorderSide(color: buttonBorderColor, width: 2.0),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLarge,
          vertical: spacingRegular,
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusRegular),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusRegular),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: spacingRegular,
        vertical: spacingSmall,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingRegular,
        vertical: spacingSmall,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRegular),
        borderSide: const BorderSide(color: buttonBorderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRegular),
        borderSide: const BorderSide(color: buttonBorderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRegular),
        borderSide: const BorderSide(color: buttonBorderColor, width: 1),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        side: BorderSide(color: buttonBorderColor, width: 2.0),
      ),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.w600,
        color: black,
      ),
      contentTextStyle: GoogleFonts.poppins(
        fontSize: fontSizeRegular,
        color: darkGrey,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radiusLarge),
          topRight: Radius.circular(radiusLarge),
        ),
        side: BorderSide(color: buttonBorderColor, width: 2.0),
      ),
    ),
  );
  
  // --- SECTION: WIDGET HELPERS ---

  // HELPERS POUR LES WIDGETS --- SECTION: 

  
  
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    double? width,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: width,
      padding: padding,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: white,
          foregroundColor: black,
          shadowColor: Colors.transparent,
          side: BorderSide(color: buttonBorderColor, width: 1.0),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingRegular,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusRegular),
          ),
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(buttonBorderColor),
                  ),
                )
              : Text(text, style: buttonText),
        ),
      ),
    );
  }
  
  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    double? width,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: width,
      padding: padding,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: white,
          foregroundColor: black,
          side: BorderSide(color: buttonBorderColor, width: 1.0),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingRegular,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusRegular),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(black),
                ),
              )
            : Text(
                text,
                style: buttonText.copyWith(color: black),
              ),
      ),
    );
  }
  
  static Widget errorMessage(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: spacingRegular,
        vertical: spacingSmall,
      ),
      decoration: BoxDecoration(
        color: error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(radiusSmall),
        border: Border.all(color: error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: error, size: 16),
          const SizedBox(width: spacingSmall),
          Expanded(
            child: Text(
              message,
              style: bodySmall.copyWith(color: error),
            ),
          ),
        ],
      ),
    );
  }
  
  static Widget successMessage(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: spacingRegular,
        vertical: spacingSmall,
      ),
      decoration: BoxDecoration(
        color: success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(radiusSmall),
        border: Border.all(color: success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: success, size: 16),
          const SizedBox(width: spacingSmall),
          Expanded(
            child: Text(
              message,
              style: bodySmall.copyWith(color: success),
            ),
          ),
        ],
      ),
    );
  }

  // --- SECTION: DIALOG HELPERS ---

  // HELPERS POUR LES DIALOGS --- SECTION: 

  
  
  static Future<void> showStandardDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
            side: BorderSide(color: buttonBorderColor, width: 1.0),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: black,
            ),
          ),
          content: Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: fontSizeRegular,
              color: darkGrey,
            ),
          ),
          actions: [
            if (cancelText != null)
              TextButton(
                onPressed: onCancel ?? () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: black,
                  backgroundColor: white,
                  side: BorderSide(color: buttonBorderColor, width: 1.0),
                ),
                child: Text(cancelText),
              ),
            if (confirmText != null)
              TextButton(
                onPressed: onConfirm ?? () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: black,
                  backgroundColor: white,
                  side: BorderSide(color: buttonBorderColor, width: 1.0),
                ),
                child: Text(confirmText),
              ),
          ],
        );
      },
    );
  }

  static void showStandardSnackBar({
    required String title,
    required String message,
    bool isSuccess = false,
    bool isError = false,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: white,
      colorText: black,
      borderColor: buttonBorderColor,
      borderWidth: 2.0,
      borderRadius: radiusRegular,
      margin: const EdgeInsets.all(spacingRegular),
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline : 
        isSuccess ? Icons.check_circle_outline : 
        Icons.info_outline,
        color: isError ? error : 
               isSuccess ? success : 
               black,
      ),
    );
  }
}