import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/app_dimensions.dart';

// ==========================================
// HARMONIZED TIMELESS TEXT STYLES
// ==========================================

class AppTextStyles {
  // Style de base avec Poppins
  static TextStyle _baseStyle({
    FontWeight? fontWeight,
    Color? color,
    double? fontSize,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.poppins(
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? ColorRes.textPrimary,
      fontSize: fontSize ?? AppDimensions.fontSizeMD,
      letterSpacing: letterSpacing ?? 0,
      height: height ?? AppDimensions.lineHeightNormal,
      decoration: decoration ?? TextDecoration.none,
    );
  }

  // ==========================================
  // TITLES AND HEADERS
  // ==========================================
  
  static TextStyle get h1 => _baseStyle(
    fontSize: AppDimensions.fontSizeHuge,
    fontWeight: FontWeight.w700,
    height: AppDimensions.lineHeightTight,
  );
  
  static TextStyle get h2 => _baseStyle(
    fontSize: AppDimensions.fontSizeXXXL,
    fontWeight: FontWeight.w600,
    height: AppDimensions.lineHeightTight,
  );
  
  static TextStyle get h3 => _baseStyle(
    fontSize: AppDimensions.fontSizeXXL,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get h4 => _baseStyle(
    fontSize: AppDimensions.fontSizeXL,
    fontWeight: FontWeight.w600,
  );

  // ==========================================
  // CORPS DE TEXTE
  // ==========================================
  
  static TextStyle get bodyLarge => _baseStyle(
    fontSize: AppDimensions.fontSizeLG,
    fontWeight: FontWeight.w400,
  );
  
  static TextStyle get bodyMedium => _baseStyle(
    fontSize: AppDimensions.fontSizeMD,
    fontWeight: FontWeight.w400,
  );
  
  static TextStyle get bodySmall => _baseStyle(
    fontSize: AppDimensions.fontSizeSM,
    fontWeight: FontWeight.w400,
    color: ColorRes.textSecondary,
  );

  // ==========================================
  // LABELS ET BOUTONS
  // ==========================================
  
  static TextStyle get labelLarge => _baseStyle(
    fontSize: AppDimensions.fontSizeMD,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get labelMedium => _baseStyle(
    fontSize: AppDimensions.fontSizeSM,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get labelSmall => _baseStyle(
    fontSize: AppDimensions.fontSizeXS,
    fontWeight: FontWeight.w500,
    color: ColorRes.textSecondary,
  );
  
  static TextStyle get buttonText => _baseStyle(
    fontSize: AppDimensions.fontSizeMD,
    fontWeight: FontWeight.w600,
    color: ColorRes.textOnPrimary,
  );

  // ==========================================
  // SPECIALIZED STYLES
  // ==========================================
  
  // Navigation bottom bar
  static TextStyle get bottomTabActive => _baseStyle(
    fontSize: AppDimensions.fontSizeXS,
    fontWeight: FontWeight.w600,
    color: ColorRes.primaryOrange,
  );
  
  static TextStyle get bottomTabInactive => _baseStyle(
    fontSize: AppDimensions.fontSizeXS,
    fontWeight: FontWeight.w500,
    color: ColorRes.textTertiary,
  );
  
  // Error et validation
  static TextStyle get errorText => _baseStyle(
    fontSize: AppDimensions.fontSizeSM,
    fontWeight: FontWeight.w500,
    color: ColorRes.errorColor,
  );
  
  // Liens
  static TextStyle get linkText => _baseStyle(
    fontSize: AppDimensions.fontSizeMD,
    fontWeight: FontWeight.w500,
    color: ColorRes.primaryBlue,
    decoration: TextDecoration.underline,
  );
  
  // Caption et helper text
  static TextStyle get caption => _baseStyle(
    fontSize: AppDimensions.fontSizeXS,
    fontWeight: FontWeight.w400,
    color: ColorRes.textTertiary,
  );
}

// ==========================================
// COMPATIBILITY WITH OLD CODE
// ==========================================

// Styles pour la bottom navigation bar
final TextStyle bottomTitleStyle = AppTextStyles.bottomTabActive;
final TextStyle bottomTitleStyleDisable = AppTextStyles.bottomTabInactive;

// Generic function for compatibility
TextStyle appTextStyle({
  FontWeight? fontWeight,
  Color? color,
  double? fontSize,
  double? letterSpacing,
  double? height,
  TextDecoration? textDecoration,
}) {
  return GoogleFonts.poppins(
    decoration: textDecoration ?? TextDecoration.none,
    color: color ?? ColorRes.textPrimary,
    fontWeight: fontWeight ?? FontWeight.w400,
    fontSize: fontSize ?? AppDimensions.fontSizeMD,
    letterSpacing: letterSpacing ?? 0,
    height: height ?? AppDimensions.lineHeightNormal,
  );
}
