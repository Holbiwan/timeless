# Guide d'utilisation - Traduction Google

## 🎯 Widgets disponibles

### 1. `LanguageSwitcher` - Widget existant amélioré
```dart
// Utilisation basique
LanguageSwitcher()

// Version compacte
LanguageSwitcher(isCompact: true, showLabel: false)
```

### 2. `ModernLanguageSelector` - Nouveau widget avec plus de langues
```dart
// Interface moderne avec 10+ langues
ModernLanguageSelector()

// Version compacte
ModernLanguageSelector(isCompact: true)

// Sans toggle auto-traduction
ModernLanguageSelector(showAutoTranslateToggle: false)
```

### 3. `FloatingLanguageSelector` - Bouton flottant
```dart
// Dans un Stack
Stack(
  children: [
    YourContent(),
    FloatingLanguageSelector(),
  ],
)
```

## 🔧 Service de traduction

### Utilisation de base
```dart
final translationService = Get.find<ComprehensiveTranslationService>();

// Traduire un texte
String translated = await translationService.translateText("Hello World");

// Détecter une langue
String? detected = await translationService.detectLanguage("Bonjour");

// Changer de langue
translationService.setLanguage('fr');
translationService.setFrench(); // raccourci
```

### Auto-traduction
```dart
// Activer/désactiver
translationService.toggleAutoTranslate();

// Traduire seulement si activé
String result = await translationService.autoTranslateIfEnabled("Hello");
```

### Informations sur la langue actuelle
```dart
String currentLang = translationService.currentLanguage.value; // 'en'
String langName = translationService.currentLanguageName; // 'English'
String flag = translationService.currentFlag; // '🇺🇸'
```

## 💡 Exemples d'intégration

### Dans un AppBar
```dart
AppBar(
  title: Text('My App'),
  actions: [
    ModernLanguageSelector(isCompact: true),
  ],
)
```

### Dans un Drawer
```dart
Drawer(
  child: ListView(
    children: [
      ListTile(
        leading: Icon(Icons.translate),
        title: Text('Language'),
        trailing: LanguageSwitcher(isCompact: true),
      ),
    ],
  ),
)
```

### Traduire du contenu dynamique
```dart
class TranslatedText extends StatelessWidget {
  final String text;
  
  Widget build(BuildContext context) {
    final service = Get.find<ComprehensiveTranslationService>();
    
    return FutureBuilder<String>(
      future: service.autoTranslateIfEnabled(text),
      builder: (context, snapshot) {
        return Text(snapshot.data ?? text);
      },
    );
  }
}
```

### Dans les paramètres
```dart
Card(
  child: Column(
    children: [
      ListTile(
        title: Text('Language Settings'),
        leading: Icon(Icons.language),
      ),
      ModernLanguageSelector(),
    ],
  ),
)
```

## 🌍 Langues supportées
- 🇺🇸 English
- 🇫🇷 Français  
- 🇪🇸 Español
- 🇸🇦 العربية
- 🇩🇪 Deutsch
- 🇮🇹 Italiano
- 🇵🇹 Português
- 🇨🇳 中文
- 🇯🇵 日本語
- 🇰🇷 한국어

## ⚙️ Configuration

Le service est déjà configuré dans `main.dart` :
```dart
Get.put(ComprehensiveTranslationService());
```

Votre clé API est configurée dans `lib/services/google_translation_service.dart`.

## 🔍 Débogage

Pour tester les fonctionnalités :
```dart
import 'package:timeless/example_google_translate_usage.dart';

// Appeler la fonction de test
testTranslationService();
```

## 📱 Recommandations d'utilisation

1. **AppBar** : Utilisez `ModernLanguageSelector(isCompact: true)`
2. **Settings** : Utilisez `ModernLanguageSelector()` complet
3. **Drawer/Menu** : Utilisez `LanguageSwitcher(isCompact: true)`
4. **Page dédiée** : Créez un écran avec le sélecteur complet
5. **Contenu dynamique** : Utilisez `autoTranslateIfEnabled()`