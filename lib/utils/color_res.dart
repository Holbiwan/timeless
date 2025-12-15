import 'package:flutter/material.dart';

/// Palette de couleurs Timeless - Design moderne et harmonieux
/// Couleurs autorisées: Bleu foncé, Noir, Blanc, Gris, Orange
class ColorRes {
  // ==========================================
  // PALETTE PRINCIPALE TIMELESS
  // ==========================================
  
  /// Bleu foncé principal - identité de marque
  static const primaryBlue = Color(0xFF1E40AF);      // Bleu foncé profond
  static const primaryBlueDark = Color(0xFF1E3A8A);  // Bleu très foncé
  static const primaryBlueLight = Color(0xFF3B82F6); // Bleu moyen
  
  /// Orange pour accents et éléments de surbrillance
  static const primaryOrange = Color(0xFFF97316);     // Orange principal
  static const primaryOrangeLight = Color(0xFFEA580C); // Orange foncé
  static const primaryOrangeSoft = Color(0xFFFF9742); // Orange doux
  
  // ==========================================
  // FONDAMENTAUX
  // ==========================================
  
  /// Couleurs de base
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const transparent = Colors.transparent;
  
  // ==========================================
  // FONDS ET SURFACES
  // ==========================================
  
  static const backgroundColor = Color(0xFFF8FAFC);   // Fond général très clair
  static const surfaceColor = Color(0xFFFFFFFF);      // Surface blanche
  static const cardColor = Color(0xFFFFFFFF);         // Cartes blanches
  static const overlayColor = Color(0x80000000);      // Overlay sombre
  
  // ==========================================
  // TEXTES
  // ==========================================
  
  static const textPrimary = Color(0xFF000000);       // Texte principal noir
  static const textSecondary = Color(0xFF374151);     // Texte secondaire gris foncé
  static const textTertiary = Color(0xFF6B7280);      // Texte tertiaire gris moyen
  static const textDisabled = Color(0xFF9CA3AF);      // Texte désactivé gris clair
  static const textOnPrimary = Color(0xFFFFFFFF);     // Texte sur fond bleu/orange
  
  // ==========================================
  // GRIS - ÉCHELLE HARMONISÉE
  // ==========================================
  
  static const grey100 = Color(0xFFF3F4F6);          // Gris très clair
  static const grey200 = Color(0xFFE5E7EB);          // Gris clair
  static const grey300 = Color(0xFFD1D5DB);          // Gris moyen-clair
  static const grey400 = Color(0xFF9CA3AF);          // Gris moyen
  static const grey500 = Color(0xFF6B7280);          // Gris standard
  static const grey600 = Color(0xFF4B5563);          // Gris foncé
  static const grey700 = Color(0xFF374151);          // Gris très foncé
  static const grey800 = Color(0xFF1F2937);          // Gris presque noir
  static const grey900 = Color(0xFF111827);          // Gris noir
  
  // ==========================================
  // BORDURES ET SÉPARATEURS
  // ==========================================
  
  static const borderColor = grey200;                // Bordures standard
  static const borderColorFocus = primaryBlue;       // Bordures focus
  static const dividerColor = grey100;               // Séparateurs
  
  // ==========================================
  // ÉTATS FONCTIONNELS
  // ==========================================
  
  static const successColor = primaryBlue;           // Succès en bleu
  static const warningColor = primaryOrange;         // Avertissement en orange
  static const errorColor = grey700;                 // Erreur en gris foncé
  static const infoColor = primaryBlueLight;         // Information en bleu clair
  
  // ==========================================
  // ALIASES POUR COMPATIBILITÉ
  // ==========================================
  
  // Couleurs héritées - remappées sur la nouvelle palette
  static const royalBlue = primaryBlue;
  static const darkBlue = primaryBlueDark;
  static const blueColor = primaryBlue;
  static const orange = primaryOrange;
  static const darkGold = primaryOrangeLight;
  static const goldAccent = primaryOrange;
  static const containerColor = primaryOrange;
  static const iconColor = primaryOrange;
  static const starColor = primaryOrange;
  
  // Textes (compatibilité)
  static const textColor = textPrimary;
  static const black2 = textSecondary;
  static const lightBlack = textTertiary;
  static const grey = grey500;
  static const lightGrey = grey100;
  static const charcoal = grey800;
  
  // Surfaces (compatibilité)
  static const white2 = backgroundColor;
  static const creamWhite = backgroundColor;
  static const deleteColor = grey100;
  static const invalidColor = grey100;
  
  // Anciens rouges/verts -> remappés
  static const vibrantRed = primaryBlue;
  static const red = primaryBlue;
  static const successGreen = primaryBlue;
  static const lightGreen = primaryBlueLight;
  static const darkGreen = primaryBlueDark;
  static const appleGreen = primaryOrange;
  static const lightAppleGreen = primaryOrangeSoft;
  
  // Nettoyage des couleurs sables
  static const softSand = backgroundColor;
  static const warmSand = primaryOrange;
  static const darkSand = grey200;
  
  // Logo et splash
  static const logoColor = primaryBlue;
  static const splashLogoColor = primaryBlue;
  
  // Couleurs diverses
  static const primaryAccent = primaryBlue;
  static const secondaryAccent = primaryOrange;
  static const gradientColor = primaryBlue;
  
  // Ajouts pour compatibility avec l'ancien code
  static const brightYellow = primaryOrange;         // Remplacé par orange
  static const deepBordeaux = primaryBlueDark;       // Remplacé par bleu foncé
}