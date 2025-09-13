# Guide de Debug Firebase - Timeless

## ✅ Corrections appliquées

### 1. Configuration Gradle
- **Ajouté** le plugin Google Services dans `android/build.gradle.kts` (version 4.4.2)
- **Corrigé** les chemins dans `android/local.properties` pour compatibilité WSL
- **Vérifié** que `google-services.json` est présent et configuré

### 2. Implémentation Google Sign-In
- **Créé** `lib/service/google_auth_service.dart` - service centralisé
- **Amélioré** la gestion d'erreurs dans `sign_in_controller.dart`
- **Ajouté** des logs de debug détaillés
- **Implémenté** double stratégie : `google_sign_in` package + Firebase Auth

### 3. Service de test
- **Créé** `lib/dev/firebase_test.dart` pour diagnostiquer les problèmes

## 🔍 Comment tester

### Test rapide depuis l'app
```dart
// Ajoutez dans main.dart ou un écran de debug :
import 'package:timeless/dev/firebase_test.dart';

// Dans un bouton ou au démarrage :
await FirebaseTestService.runAllTests();
```

### Test depuis Android Studio
1. **Lancer l'app** avec `flutter run`
2. **Observer les logs** dans la console Android Studio
3. **Chercher les messages** :
   - `✅` = succès
   - `❌` = échec 
   - `⚠️` = avertissement

## 🐛 Diagnostics courants

### Google Sign-In ne fonctionne pas
**Symptômes** : Popup ne s'ouvre pas ou erreur `DEVELOPER_ERROR`

**Vérifications** :
1. **SHA1/SHA256** dans Firebase Console :
   ```bash
   cd android
   ./gradlew signingReport
   # Copier les empreintes dans Firebase Console > Project Settings > General
   ```

2. **Package name** : Doit être `com.example.timeless` partout
3. **Web Client ID** configuré dans GoogleSignIn (fait ✅)

### Firestore connexion échoue
**Symptômes** : `permission-denied` ou timeout

**Vérifications** :
1. **Rules Firestore** : Vérifier dans Firebase Console > Firestore > Rules
2. **Réseau** : Tester avec données mobiles si WiFi pose problème
3. **Auth state** : S'assurer que l'utilisateur est connecté avant l'accès

### Firebase initialization fails
**Symptômes** : App crash au démarrage

**Vérifications** :
1. **google-services.json** présent dans `android/app/`
2. **firebase_options.dart** généré correctement
3. **Plugins Gradle** appliqués correctement

## 📱 Test dans Android Studio

### Logs à surveiller
```bash
# Pour voir tous les logs Firebase
flutter run --verbose

# Ou filtrer dans Android Studio Logcat :
firebase
google
timeless
```

### Messages de succès attendus
```
✅ Firebase Auth initialized
✅ Firestore connection successful  
✅ Google Sign-In successful
✅ User data saved to Firestore
```

## 🚨 Actions de dépannage

### Si Google Sign-In échoue
1. **Vérifier SHA1** : Générer et ajouter dans Firebase Console
2. **Clear cache** :
   ```bash
   flutter clean
   cd android && ./gradlew clean
   flutter pub get
   ```

### Si Firestore échoue
1. **Test avec rules permissives** (temporairement) :
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true; // TEMPORAIRE SEULEMENT
       }
     }
   }
   ```

### Si Firebase initialization échoue
1. **Re-run FlutterFire CLI** :
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

## 🎯 Points de contrôle finaux

- [ ] App démarre sans crash
- [ ] Firebase Auth initialized (voir logs)
- [ ] Firestore connexion OK (voir logs) 
- [ ] Google Sign-In ouvre popup/intent Android
- [ ] Utilisateur connecté arrivé au dashboard
- [ ] Données sauvées dans Firestore

## 📞 Support

Si les problèmes persistent :
1. **Activer tous les logs** avec `flutter run --verbose`
2. **Copier les logs d'erreur** complets
3. **Vérifier la console Firebase** pour les erreurs côté serveur
4. **Tester sur device physique** si émulateur pose problème