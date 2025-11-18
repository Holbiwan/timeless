# 🔥 Guide de Configuration Firebase pour Timeless

## ✅ **Configuration déjà en place**

Votre projet a déjà :
- ✅ Firebase configuré (`timeless-6cdf9`)
- ✅ Clés API configurées dans `firebase_options.dart`
- ✅ Authentification Google et Email configurée

---

## 🔧 **Étapes pour activer l'authentification**

### **1. Firebase Console - Activation des méthodes d'auth**

Allez sur [Firebase Console](https://console.firebase.google.com/project/timeless-6cdf9/authentication/providers) :

1. **Authentication > Sign-in method**
2. **Activer Email/Password** :
   - Cliquer sur "Email/Password"
   - Activer "Email/Password" ✅
   - Activer "Email link (passwordless sign-in)" (optionnel)

3. **Activer Google** :
   - Cliquer sur "Google" 
   - Activer ✅
   - Ajouter votre email de support
   - Télécharger le nouveau `google-services.json` si nécessaire

### **2. Firebase Console - Firestore Database**

1. **Firestore Database** > **Créer une base de données**
2. **Mode de production** (nous ajouterons les règles)
3. **Région** : `europe-west1` (Europe)
4. **Règles de sécurité** : 

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null;
    }
    
    // Jobs collection
    match /jobs/{jobId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null;
    }
    
    // Applications collection  
    match /applications/{applicationId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### **3. Vérifier Android Configuration**

Fichier `android/app/google-services.json` doit exister et contenir votre projet.

---

## 🧪 **Test de l'authentification**

### **Commandes pour tester** :
```bash
# Dans votre PowerShell
cd C:\Users\sabri\Documents\timeless
flutter clean
flutter pub get
flutter run
```

### **Flow de test** :
1. **Splash Screen** → **First Page**
2. **"Créer un compte"** → Formulaire d'inscription
3. **Inscription avec email** → Vérifier que ça fonctionne
4. **Connexion Google** → Tester l'auth Google

---

## 🔥 **Services créés pour vous**

### **AuthService** (`lib/services/auth_service.dart`)
- ✅ Inscription email/password
- ✅ Connexion email/password  
- ✅ Authentification Google
- ✅ Récupération de mot de passe
- ✅ Gestion d'erreurs en français

### **DatabaseService** (`lib/services/database_service.dart`)
- ✅ Création de données de test (emplois)
- ✅ Gestion des candidatures
- ✅ Requêtes Firestore optimisées

### **UserModel** (`lib/models/user_model.dart`)
- ✅ Modèle de données utilisateur
- ✅ Sérialisation JSON pour Firestore

---

## 📱 **Test simple de connexion**

Ajoutez ce code de test dans votre sign_up_controller :

```dart
// Test simple d'inscription
Future<void> testSignUp() async {
  AuthService authService = AuthService.instance;
  
  bool success = await authService.signUpWithEmail(
    "test@example.com",
    "password123", 
    "Test User"
  );
  
  if (success) {
    print("✅ Inscription réussie !");
  } else {
    print("❌ Erreur d'inscription");
  }
}

// Test simple de connexion Google
Future<void> testGoogleSignIn() async {
  AuthService authService = AuthService.instance;
  
  bool success = await authService.signInWithGoogle();
  
  if (success) {
    print("✅ Connexion Google réussie !");
  } else {
    print("❌ Erreur connexion Google");
  }
}
```

---

## 🚨 **Problèmes possibles et solutions**

### **Erreur SHA-1 Android**
Si Google Sign-In ne marche pas :
1. Générer SHA-1 : `cd android && ./gradlew signingReport`
2. Ajouter dans Firebase Console > Project Settings > Your apps > Android

### **Erreur "API not enabled"**
Activer les APIs dans [Google Cloud Console](https://console.cloud.google.com/) :
- Google Sign-In API
- Firebase Authentication API

### **Erreur Firestore**
Vérifier que Firestore est activé dans Firebase Console

---

## ✅ **Validation finale**

Une fois que tout fonctionne :
1. **Créer un compte de test** avec votre email
2. **Tester la connexion Google** avec votre compte Google
3. **Vérifier dans Firebase Console** > Authentication que les utilisateurs apparaissent
4. **Vérifier dans Firestore** que les collections `users` et `jobs` sont créées

**🎯 Objectif : Avoir une authentification 100% fonctionnelle pour la démo du 14 décembre !**