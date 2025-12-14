# 📱 Guide des Commandes Flutter - Projet Timeless

## 🚀 Commandes de Développement

### Lancement et Tests
```bash
# Lancer l'app en mode debug
flutter run

# Lancer avec un device spécifique
flutter run -d <device-id>

# Voir les devices disponibles
flutter devices
```

### Hot Reload (Développement en temps réel)
```bash
# Dans flutter run actif:
r    # Hot reload (changements UI rapides)
R    # Hot restart (redémarrage complet)
q    # Quitter flutter run
```

### Build et Installation

#### Version Debug
```bash
# Build APK debug
flutter build apk --debug

# Build et installer directement
flutter install
```

#### Version Release (Production)
```bash
# Build APK release optimisée
flutter build apk --release

# Build AAB pour Google Play Store
flutter build appbundle --release
```

### Gestion des Dépendances
```bash
# Installer les packages
flutter pub get

# Mettre à jour les packages
flutter pub upgrade

# Nettoyer le cache
flutter pub cache repair

# Analyser les packages obsolètes
flutter pub outdated
```

### Nettoyage et Maintenance
```bash
# Nettoyer les builds précédents
flutter clean

# Nettoyer puis réinstaller
flutter clean && flutter pub get
```

### Analyse du Code
```bash
# Analyser le code (erreurs, warnings)
flutter analyze

# Formatter le code
flutter format .

# Tests
flutter test
```

## 🛠️ Commandes de Debug et Diagnostic

### Informations Système
```bash
# État de Flutter
flutter doctor

# Informations détaillées
flutter doctor -v

# Informations sur les devices
flutter devices -v
```

### Logs et Debug
```bash
# Logs en temps réel
flutter logs

# Logs d'un device spécifique
flutter logs -d <device-id>
```

## 📦 Workflow de Développement Recommandé

### 1. Démarrage quotidien
```bash
flutter doctor          # Vérifier l'environnement
flutter devices         # Vérifier les devices connectés
flutter pub get         # S'assurer que les dépendances sont à jour
flutter run             # Lancer l'app
```

### 2. Pendant le développement
- Modifier le code
- Appuyer sur `r` pour hot reload
- Appuyer sur `R` si problèmes avec hot reload

### 3. Avant de commit
```bash
flutter analyze         # Vérifier les erreurs
flutter format .        # Formatter le code
flutter test           # Lancer les tests (si présents)
```

### 4. Build final
```bash
flutter clean           # Nettoyer
flutter pub get         # Réinstaller les dépendances
flutter build apk --release  # Build release
```

## 🔧 Résolution des Problèmes Courants

### Erreurs de Build
```bash
# Nettoyer complètement
flutter clean
flutter pub get
flutter pub cache repair

# Si problème persiste
rm -rf pubspec.lock
flutter pub get
```

### Problèmes de Permissions Android
```bash
# Redémarrer ADB
adb kill-server
adb start-server

# Autoriser debug USB
adb devices
```

### Problèmes de Dépendances
```bash
# Forcer la mise à jour
flutter pub deps
flutter pub upgrade --major-versions
```

## 📱 Spécifique Android

### APK Installation
```bash
# Installer APK manuellement
adb install build/app/outputs/flutter-apk/app-release.apk

# Désinstaller l'app
adb uninstall com.example.timeless
```

### Informations Device
```bash
# Informations Android
adb shell getprop ro.build.version.release
adb shell getprop ro.product.model
```

## 🔄 Git + Flutter

### Fichiers à ignorer (.gitignore)
Les fichiers suivants sont déjà dans .gitignore :
- `build/`
- `pubspec.lock` (optionnel)
- `.dart_tool/`
- `.packages`

### Workflow Git recommandé
```bash
git add .
git commit -m "Description des changements"
git push origin main

# Puis sur autre machine:
git pull
flutter pub get
flutter run
```

## 💡 Conseils de Performance

### Build Optimisée
```bash
# Build avec optimisations maximales
flutter build apk --release --shrink

# Build avec obfuscation (sécurité)
flutter build apk --release --obfuscate --split-debug-info=build/debug_info
```

### Analyse de Taille
```bash
# Analyser la taille de l'APK
flutter build apk --analyze-size
```

---

## 📞 Support

Si vous rencontrez des problèmes :
1. `flutter doctor` pour diagnostiquer
2. Consulter les logs avec `flutter logs`
3. Nettoyer avec `flutter clean && flutter pub get`
4. Redémarrer l'IDE et reconnecter le device

**Version Flutter recommandée :** Stable channel  
**Mise à jour Flutter :** `flutter upgrade`