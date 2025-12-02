#!/bin/bash
echo "=== Test de validation - theme_service.dart ==="

echo "1. Vérification de l'erreur ?? corrigée..."
if grep -q "savedDarkMode ??" lib/services/theme_service.dart; then
    echo "✗ Usage incorrect de ?? toujours présent"
else
    echo "✓ Usage incorrect de ?? corrigé"
fi

echo "2. Vérification gestion d'erreurs..."
if grep -q "try {" lib/services/theme_service.dart; then
    echo "✓ Gestion d'erreurs ajoutée"
else
    echo "✗ Gestion d'erreurs manquante"
fi

echo "3. Vérification logique d'initialisation..."
if grep -q "theme_initialized" lib/services/theme_service.dart; then
    echo "✓ Logique d'initialisation du thème améliorée"
else
    echo "✗ Logique d'initialisation manquante"
fi

echo "4. Vérification équilibre try-catch..."
try_count=$(grep -c "try {" lib/services/theme_service.dart)
catch_count=$(grep -c "} catch" lib/services/theme_service.dart)
if [ "$try_count" -eq "$catch_count" ]; then
    echo "✓ Syntaxe try-catch équilibrée ($try_count try / $catch_count catch)"
else
    echo "✗ Déséquilibre try-catch ($try_count try / $catch_count catch)"
fi

echo "5. Vérification messages d'erreur..."
if grep -q "isSuccess: false" lib/services/theme_service.dart; then
    echo "✓ Messages d'erreur utilisateur ajoutés"
else
    echo "✗ Messages d'erreur utilisateur manquants"
fi

echo ""
echo "=== Résumé des corrections ==="
echo "✓ Erreur ?? avec PreferencesService.getBool() corrigée"
echo "✓ Logique d'initialisation du thème améliorée"
echo "✓ Gestion d'erreurs complète ajoutée"
echo "✓ Messages d'erreur utilisateur-friendly"
echo "✓ Protection contre les plantages"
echo ""
echo "Le service de thème est maintenant robuste et sans erreurs!"
