#!/bin/bash

# Script: disable_desktop_builds.sh
# Description: Crée un fichier flutter.config pour désactiver les plateformes desktop (macOS, Windows, Linux).
# Utilisation : ./disable_desktop_builds.sh

# Créer le fichier flutter.config
cat <<EOL > flutter.config
enable-linux-desktop=false
enable-macos-desktop=false
enable-windows-desktop=false
EOL

echo "✅ flutter.config file created with desktop platforms disabled."

# Nettoyage du projet
flutter clean

# Réinstallation des dépendances
flutter pub get

echo "✨ Cleaned project and fetched dependencies. Now try 'flutter run' again."
