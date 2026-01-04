import 'package:get/get.dart';
import 'package:timeless/services/preferences_service.dart';

class AppearanceControllerM extends GetxController implements GetxService {
  late ThemeService themeService;
  
  RxBool isSwitchedBlurBackground = true.obs;
  RxBool isSwitchedFullScreenMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialisation sécurisée du ThemeService
    try {
      themeService = Get.find<ThemeService>();
    } catch (e) {
      // Si ThemeService n'existe pas encore, l'ajouter
      themeService = Get.put(ThemeService());
    }
    loadSettings();
  }

  void loadSettings() {
    try {
      // PreferencesService.getBool() retourne false par défaut, donc on gère manuellement les valeurs par défaut
      final blurBackgroundValue = PreferencesService.getBool('blurBackground');
      final fullScreenModeValue = PreferencesService.getBool('fullScreenMode');
      
      // Si c'est la première fois, on met les valeurs par défaut à true
      if (PreferencesService.getString('settings_initialized').isEmpty) {
        isSwitchedBlurBackground.value = true;
        isSwitchedFullScreenMode.value = true;
        PreferencesService.setValue('blurBackground', true as String);
        PreferencesService.setValue('fullScreenMode', true as String);
        PreferencesService.setValue('settings_initialized', 'true');
      } else {
        isSwitchedBlurBackground.value = blurBackgroundValue;
        isSwitchedFullScreenMode.value = fullScreenModeValue;
      }
    } catch (e) {
      print('Erreur lors du chargement des paramètres: $e');
      // Valeurs par défaut en cas d'erreur
      isSwitchedBlurBackground.value = true;
      isSwitchedFullScreenMode.value = true;
    }
  }

  // Getter pour le dark mode depuis ThemeService
  bool get isSwitchedDarkMode => themeService.isDarkMode.value;

  void onchangeDarkMode(bool value) {
    // Vérifier si la valeur a vraiment changé pour éviter les toggles inutiles
    if (themeService.isDarkMode.value != value) {
      themeService.toggleTheme();
      update();
    }
  }

  void onchangeBackground(bool value) {
    isSwitchedBlurBackground.value = value;
    PreferencesService.setValue('blurBackground', value as String);
    update();
  }

  void onchangeFullScreenMode(bool value) {
    isSwitchedFullScreenMode.value = value;
    PreferencesService.setValue('fullScreenMode', value as String);
    update();
  }
}

class ThemeService {
  get isDarkMode => null;
  
  void toggleTheme() {}
}
