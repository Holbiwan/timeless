#!/bin/bash

# Script de réinstallation pour timeless
echo "🚀 Réinstallation de Timeless..."

# Nettoyer manuellement
echo "📁 Nettoyage des caches..."
rm -rf build/ 2>/dev/null
rm -rf .dart_tool/ 2>/dev/null
rm -rf android/app/build/ 2>/dev/null

echo "✅ Cache nettoyé"

# Instructions pour l'utilisateur
echo ""
echo "🎯 ÉTAPES SUIVANTES :"
echo "1. Ouvre Android Studio"
echo "2. Démarre un émulateur Android OU branche ton téléphone"
echo "3. Lance cette commande dans le terminal VS Code :"
echo "   flutter run"
echo ""
echo "📱 Ou pour Chrome (test Web) :"
echo "   flutter run -d chrome"
echo ""
echo "🔥 Google Sign-In devrait maintenant marcher !"
echo "   (pas de cache OAuth = configuration propre)"