import 'package:flutter/material.dart';

// Système d'espacements et de dimensions harmonisé pour Timeless
// Basé sur une échelle de 4px pour une cohérence parfaite
class AppDimensions {
  // ==========================================
  // ESPACEMENT - ÉCHELLE 4PX
  // ==========================================
  
  static const double xxs = 2.0;    // Très petit espacement
  static const double xs = 4.0;     // Petit espacement
  static const double sm = 8.0;     // Espacement petit-moyen
  static const double md = 12.0;    // Espacement moyen
  static const double lg = 16.0;    // Espacement large
  static const double xl = 20.0;    // Espacement extra-large
  static const double xxl = 24.0;   // Espacement très large
  static const double xxxl = 32.0;  // Espacement maximum
  static const double huge = 40.0;  // Espacement énorme (sections)
  static const double mega = 48.0;  // Espacement mega (pages)
  
  // ==========================================
  // ESPACEMENTS SPÉCIALISÉS
  // ==========================================
  
  // Marges de page standard
  static const double pageHorizontalPadding = lg;  // 16px
  static const double pageVerticalPadding = xl;    // 20px
  
  // Espacement entre sections
  static const double sectionSpacing = xxxl;       // 32px
  
  // Espacement dans les cartes
  static const double cardPadding = lg;            // 16px
  static const double cardSpacing = md;            // 12px
  
  // Espacement formulaires
  static const double formFieldSpacing = lg;       // 16px
  static const double formSectionSpacing = xxl;    // 24px
  
  // ==========================================
  // TAILLES DE COMPOSANTS
  // ==========================================
  
  // Boutons
  static const double buttonHeight = 48.0;         // Hauteur standard bouton
  static const double buttonHeightSmall = 36.0;    // Petit bouton
  static const double buttonHeightLarge = 56.0;    // Grand bouton
  static const double buttonPadding = lg;          // Padding bouton
  static const double buttonRadius = md;           // Rayon bouton
  
  // Champs de texte
  static const double inputHeight = 48.0;          // Hauteur input
  static const double inputPadding = lg;           // Padding input
  static const double inputRadius = md;            // Rayon input
  
  // Cartes
  static const double cardRadius = lg;             // Rayon des cartes
  static const double cardElevation = 2.0;         // Élévation des cartes
  
  // Icons
  static const double iconSizeSmall = 16.0;        // Petite icône
  static const double iconSizeMedium = 20.0;       // Icône moyenne
  static const double iconSizeLarge = 24.0;        // Grande icône
  static const double iconSizeXLarge = 32.0;       // Très grande icône
  
  // ==========================================
  // LAYOUT - CONTRAINTES
  // ==========================================
  
  // Largeurs maximales pour éviter les éléments trop larges
  static const double maxContentWidth = 400.0;     // Largeur max contenu
  static const double maxFormWidth = 320.0;        // Largeur max formulaire
  static const double maxCardWidth = 380.0;        // Largeur max carte
  
  // Hauteurs minimales pour éviter les éléments trop petits
  static const double minTapTarget = 44.0;         // Cible tactile minimale
  static const double minInputHeight = 48.0;       // Hauteur min input
  
  // ==========================================
  // TYPOGRAPHIE - TAILLES
  // ==========================================
  
  static const double fontSizeXXS = 10.0;          // Très petit texte
  static const double fontSizeXS = 12.0;           // Petit texte
  static const double fontSizeSM = 14.0;           // Texte moyen-petit
  static const double fontSizeMD = 16.0;           // Texte standard
  static const double fontSizeLG = 18.0;           // Texte large
  static const double fontSizeXL = 20.0;           // Texte extra-large
  static const double fontSizeXXL = 24.0;          // Titre
  static const double fontSizeXXXL = 28.0;         // Grand titre
  static const double fontSizeHuge = 32.0;         // Très grand titre
  
  // Hauteurs de ligne harmonisées
  static const double lineHeightTight = 1.2;       // Ligne serrée
  static const double lineHeightNormal = 1.4;      // Ligne normale
  static const double lineHeightRelaxed = 1.6;     // Ligne aérée
  
  // ==========================================
  // HELPERS - ESPACEMENTS RAPIDES
  // ==========================================
  
  // Espacement horizontal standard pour les pages
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: pageHorizontalPadding,
    vertical: pageVerticalPadding,
  );
  
  // Espacement pour les cartes
  static const EdgeInsets cardPaddingInsets = EdgeInsets.all(cardPadding);
  
  // Espacement pour les boutons
  static const EdgeInsets buttonPaddingInsets = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  
  // Espacement pour les champs de texte
  static const EdgeInsets inputPaddingInsets = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  
  // Espacement entre les éléments de formulaire
  static const EdgeInsets formFieldMargin = EdgeInsets.only(bottom: formFieldSpacing);
  
  // Espacement entre les sections
  static const EdgeInsets sectionMargin = EdgeInsets.only(bottom: sectionSpacing);
}