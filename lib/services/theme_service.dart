// lib/services/theme_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/app_theme.dart';

class ThemeService extends GetxController {
  static ThemeService get instance => Get.find();
  
  var isDarkMode = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadThemeFromPreferences();
  }
  
  void loadThemeFromPreferences() {
    try {
      // Détecter le thème système par défaut si aucune préférence
      final systemBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final savedDarkMode = PreferencesService.getBool('isDarkMode');
      final themeInitialized = PreferencesService.getString('theme_initialized').isNotEmpty;
      
      // Si aucune préférence sauvegardée (false par défaut), suivre le système
      if (!savedDarkMode && !themeInitialized) {
        isDarkMode.value = systemBrightness == Brightness.dark;
        PreferencesService.setValue('theme_initialized', 'true');
      } else {
        isDarkMode.value = savedDarkMode;
      }
    } catch (e) {
      print('Erreur lors du chargement du thème: $e');
      // Valeur par défaut en cas d'erreur
      isDarkMode.value = false;
    }
  }
  
  void toggleTheme() {
    try {
      isDarkMode.value = !isDarkMode.value;
      PreferencesService.setValue('isDarkMode', isDarkMode.value);
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
      
      // Notification avec snackbar
      AppTheme.showStandardSnackBar(
        title: isDarkMode.value ? "Mode Sombre Activé" : "Mode Clair Activé",
        message: "Le thème a été changé avec succès",
        isSuccess: true,
      );
    } catch (e) {
      print('Erreur lors du changement de thème: $e');
      AppTheme.showStandardSnackBar(
        title: "Erreur",
        message: "Impossible de changer le thème",
        isSuccess: false,
      );
    }
  }
  
  // Suivre automatiquement le système
  void setSystemTheme() {
    try {
      Get.changeThemeMode(ThemeMode.system);
      PreferencesService.setValue('followSystemTheme', true);
      
      AppTheme.showStandardSnackBar(
        title: "Thème Automatique",
        message: "L'app suit maintenant le thème du système",
        isSuccess: true,
      );
    } catch (e) {
      print('Erreur lors de la configuration du thème système: $e');
      AppTheme.showStandardSnackBar(
        title: "Erreur",
        message: "Impossible de configurer le thème automatique",
        isSuccess: false,
      );
    }
  }
  
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF000647),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8F9FA),
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        side: const BorderSide(color: Color(0xFF000647), width: 2.0),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFF000647),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      titleLarge: TextStyle(color: Colors.black),
    ),
  );
  
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF000647),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      shadowColor: Colors.white.withOpacity(0.1),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF000647), width: 2.0),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFF000647),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
    ),
  );
}