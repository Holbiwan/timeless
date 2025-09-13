# 🔒 Configuration de Sécurité Firebase - Timeless

## ⚠️ URGENT - Fichiers supprimés de l'historique Git

Les fichiers suivants ont été supprimés de l'historique Git pour des raisons de sécurité :
- `android/app/google-services.json`
- `lib/firebase_options.dart`

Ces fichiers contenaient des clés API et identifiants Firebase qui étaient exposés publiquement.

## 🔧 Configuration nécessaire

### 1. Recreer les fichiers Firebase

**Pour `android/app/google-services.json` :**
1. Aller sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionner votre projet `timeless-6cdf9`
3. Aller dans Paramètres du projet > Applications
4. Télécharger le fichier `google-services.json` pour Android
5. Le placer dans `android/app/google-services.json`

**Pour `lib/firebase_options.dart` :**
1. Exécuter `flutter pub global activate flutterfire_cli`
2. Exécuter `flutterfire configure` dans le répertoire du projet
3. Sélectionner le projet Firebase existant
4. Cela régénérera automatiquement `lib/firebase_options.dart`

### 2. Fichiers d'exemple fournis

Des fichiers d'exemple ont été créés :
- `android/app/google-services.json.example`
- `lib/firebase_options.dart.example`

Remplacez les valeurs `VOTRE_*` par vos vraies valeurs Firebase.

## 🛡️ Sécurité renforcée

### Actions déjà prises :
✅ `.gitignore` mis à jour pour protéger les fichiers sensibles
✅ Historique Git nettoyé avec git filter-branch
✅ Fichiers sensibles supprimés des commits précédents

### Actions recommandées :
🔄 **Regénérer les clés API Firebase** (fortement recommandé)
🔄 **Changer les secrets OAuth** si exposés
🔄 **Mettre à jour les règles Firestore** pour restreindre l'accès

## 📝 Notes importantes

1. **Ne jamais commiter** les vrais fichiers Firebase
2. **Toujours vérifier** avec `git status` avant de commiter
3. **Utiliser des variables d'environnement** pour la production
4. **Activer les restrictions IP** dans Firebase Console si possible

## 🚀 Après configuration

Une fois les fichiers recréés, testez l'application :
```bash
flutter clean
flutter pub get
flutter run
```

## 📞 Support

Si vous rencontrez des problèmes, vérifiez :
1. Que Firebase est correctement configuré
2. Que les permissions sont correctes
3. Que les packages Firebase sont à jour dans `pubspec.yaml`