#!/bin/bash

# Script de déploiement Firebase pour Timeless
# Ce script déploie les nouvelles règles Firestore et vérifie la configuration

echo "🚀 Déploiement Firebase Timeless"
echo "================================"

# Vérifier si Firebase CLI est installé
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI non installé"
    echo "Installez avec: npm install -g firebase-tools"
    exit 1
fi

# Se connecter à Firebase (si pas déjà connecté)
echo "🔐 Vérification de la connexion Firebase..."
if ! firebase projects:list &> /dev/null; then
    echo "Connexion à Firebase..."
    firebase login
fi

# Vérifier le projet actuel
echo "📋 Projet Firebase actuel:"
firebase use

# Sauvegarder les anciennes règles
echo "💾 Sauvegarde des anciennes règles..."
cp firebase/firestore.rules firebase/firestore.rules.backup.$(date +%Y%m%d_%H%M%S)

# Copier les nouvelles règles
echo "📝 Application des nouvelles règles..."
cp firebase/firestore_production.rules firebase/firestore.rules

# Déployer les règles Firestore
echo "🚀 Déploiement des règles Firestore..."
if firebase deploy --only firestore:rules; then
    echo "✅ Règles Firestore déployées avec succès!"
else
    echo "❌ Erreur lors du déploiement des règles"
    echo "Restauration des anciennes règles..."
    cp firebase/firestore.rules.backup.* firebase/firestore.rules
    exit 1
fi

# Optionnel: Déployer les index Firestore
echo "📊 Déploiement des index Firestore..."
if [ -f "firebase/firestore.indexes.json" ]; then
    firebase deploy --only firestore:indexes
    echo "✅ Index Firestore déployés!"
else
    echo "⚠️  Aucun fichier d'index trouvé"
fi

echo ""
echo "🎉 Déploiement terminé!"
echo "Votre application Firebase est maintenant fonctionnelle"
echo ""
echo "Pour tester:"
echo "1. Lancez votre app Flutter: flutter run"
echo "2. Utilisez l'écran de démo pour générer des données"
echo "3. Testez l'authentification et les offres d'emploi"
echo ""
echo "Projet Firebase: timeless-6cdf9"
echo "Console: https://console.firebase.google.com/project/timeless-6cdf9"