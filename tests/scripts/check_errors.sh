#!/bin/bash
echo "=== Vérification des erreurs dans comprehensive_translation_service.dart ==="

echo "1. Vérification PreferencesService usage..."
if grep -q "PreferencesService\.getString.*??" lib/services/comprehensive_translation_service.dart; then
    echo "✗ Usage redondant de ?? avec getString"
else
    echo "✓ Usage correct de PreferencesService.getString"
fi

if grep -q "PreferencesService\.getBool.*??" lib/services/comprehensive_translation_service.dart; then
    echo "✗ Usage redondant de ?? avec getBool"
else
    echo "✓ Usage correct de PreferencesService.getBool"
fi

echo "2. Vérification imports..."
if grep -q "import.*get/get.dart" lib/services/comprehensive_translation_service.dart; then
    echo "✓ Import GetX correct"
else
    echo "✗ Import GetX manquant"
fi

echo "3. Vérification méthodes async..."
if grep -q "Future<.*> .*async" lib/services/comprehensive_translation_service.dart; then
    echo "✓ Méthodes async déclarées correctement"
else
    echo "✗ Problème avec les méthodes async"
fi

echo "4. Vérification gestion null safety..."
if grep -q "Get\.context!" lib/services/comprehensive_translation_service.dart; then
    echo "✓ Null safety avec Get.context!"
else
    echo "✗ Problème null safety avec Get.context"
fi

echo "5. Vérification syntaxe try-catch..."
try_count=$(grep -c "try {" lib/services/comprehensive_translation_service.dart)
catch_count=$(grep -c "} catch" lib/services/comprehensive_translation_service.dart)
if [ "$try_count" -eq "$catch_count" ]; then
    echo "✓ Syntaxe try-catch équilibrée ($try_count try / $catch_count catch)"
else
    echo "✗ Déséquilibre try-catch ($try_count try / $catch_count catch)"
fi

echo ""
echo "=== Analyse terminée ==="
