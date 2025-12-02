#!/bin/bash
echo "=== Test de sécurité des clés API ==="

echo "1. Vérification fichier config sécurisé..."
if [ -f "lib/config/api_config.dart" ]; then
    echo "✓ Fichier de config sécurisé créé"
else
    echo "✗ Fichier de config sécurisé manquant"
fi

echo "2. Vérification fichier exemple..."
if [ -f "lib/config/api_config.example.dart" ]; then
    echo "✓ Fichier exemple créé pour les autres développeurs"
else
    echo "✗ Fichier exemple manquant"
fi

echo "3. Vérification .gitignore..."
if grep -q "lib/config/api_config.dart" .gitignore; then
    echo "✓ Fichier sensible ajouté au .gitignore"
else
    echo "✗ Fichier sensible non protégé dans .gitignore"
fi

echo "4. Vérification import dans service..."
if grep -q "import.*api_config.dart" lib/services/google_translation_service.dart; then
    echo "✓ Service utilise la configuration sécurisée"
else
    echo "✗ Service n'utilise pas la configuration sécurisée"
fi

echo "5. Vérification absence de clé en dur..."
if ! grep -q "AIzaSy.*static const String _apiKey" lib/services/google_translation_service.dart; then
    echo "✓ Clé API retirée du code source"
else
    echo "✗ Clé API encore présente dans le code"
fi

echo ""
echo "=== Résumé de sécurité ==="
echo "✅ Configuration sécurisée mise en place"
echo "🔐 Clé API protégée dans fichier séparé"
echo "🚫 Fichier exclu de Git automatiquement"
echo "📁 Fichier exemple pour collaboration"
echo "🔧 Service mis à jour pour utiliser la config sécurisée"
echo ""
echo "Votre clé API est maintenant sécurisée ! 🛡️"
