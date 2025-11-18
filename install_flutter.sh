#!/bin/bash

echo "=== Installation Flutter pour Timeless ==="

# Configuration des chemins
FLUTTER_DIR="/mnt/c/flutter"
ANDROID_SDK="/mnt/c/Users/sabri/AppData/Local/Android/Sdk"

# Mettre à jour le PATH
export PATH="$FLUTTER_DIR/bin:$PATH"
export ANDROID_HOME="$ANDROID_SDK"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

echo "Configuration des variables d'environnement..."
echo "FLUTTER_DIR: $FLUTTER_DIR"
echo "ANDROID_HOME: $ANDROID_HOME"

# Vérifier Flutter
echo "=== Vérification Flutter ==="
if [ -f "$FLUTTER_DIR/bin/flutter" ]; then
    echo "Flutter trouvé, tentative d'exécution..."
    # Attendre que Flutter termine son setup initial
    timeout 600 flutter doctor -v || echo "Timeout ou erreur Flutter"
else
    echo "Flutter non trouvé dans $FLUTTER_DIR"
fi

# Configurer le projet
echo "=== Configuration du projet Timeless ==="
cd /mnt/c/Users/sabri/Documents/timeless

# Nettoyer et récupérer les dépendances
echo "Nettoyage du projet..."
flutter clean || echo "Flutter clean échoué"

echo "Installation des dépendances..."
flutter pub get || echo "Flutter pub get échoué"

# Vérifier la configuration Android
echo "=== Vérification Android ==="
flutter doctor --android-licenses || echo "Licences Android non acceptées"

echo "=== Tentative de build debug ==="
flutter build apk --debug || echo "Build échoué"

echo "=== Installation terminée ==="