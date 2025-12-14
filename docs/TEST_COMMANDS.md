# 🔧 COMMANDES DE TEST - TIMELESS

## 🚀 PRÉPARATION ENVIRONNEMENT

### **Nettoyage & Setup**
```bash
# Nettoyage complet
flutter clean
flutter pub get

# Vérification santé projet
flutter doctor
flutter doctor --android-licenses

# Build de test
flutter build apk --debug
flutter run --debug
```

### **Tests Firebase**
```bash
# Vérifier connexion Firebase
flutter packages pub run build_runner build

# Tester règles Firestore (si configuré)
firebase emulators:start --only firestore
```

---

## 📱 TESTS MANUELS À EFFECTUER

### **Test 1 : Clean Install**
```bash
# Désinstaller app du téléphone
adb uninstall com.timeless.app

# Installer version fraîche
flutter install --debug

# Premier lancement → écran onboarding
```

### **Test 2 : Base de Données**
```bash
# Vérifier état Firestore
# -> Ouvrir Firebase Console
# -> Vérifier collections vides pour fresh start
```

### **Test 3 : Permissions**
```bash
# Vérifier permissions Android
adb shell pm list permissions com.timeless.app

# Reset permissions si nécessaire
adb shell pm clear com.timeless.app
```

---

## 🎬 SCRIPT DEMO TECHNIQUE

### **Étape 1 : Lancement App**
```bash
# Terminal 1 : Lancer app
flutter run --debug --verbose

# Terminal 2 : Logs temps réel
adb logcat | grep -i timeless
```

### **Étape 2 : Monitoring Firebase**
Pendant la démo, avoir ouvert :
- Firebase Console → Authentication
- Firebase Console → Firestore
- Firebase Console → Analytics (temps réel)

### **Étape 3 : Tests Authentification**

#### **Inscription Email** 
```
Données test à utiliser :
- Nom : "Jean Demo"
- Email : "jean.demo.timeless@gmail.com" 
- Mot de passe : "Demo123!"
- Téléphone : "+33612345678"
```

#### **Connexion Google**
```
Compte Google test :
- Email : "demo.timeless.app@gmail.com"
- Mot de passe : [avoir un compte dédié]
```

---

## 🔍 VÉRIFICATIONS FIREBASE TEMPS RÉEL

### **Dans Authentication :**
```
✅ Vérifier après inscription :
- UID généré
- Email vérifié (true/false)
- Provider type (password/google.com)
- Création timestamp
```

### **Dans Firestore :**
```
✅ Collection 'users' :
- Document avec UID utilisateur
- Champs : email, fullName, role, createdAt
- Permissions lecture/écriture selon règles

✅ Collection 'candidate_profiles' :
- Profil candidat créé automatiquement
- Champs : skills, experience, location
```

---

## 🎯 POINTS DE CONTRÔLE DEMO

### **Timing Demo (8 min) :**
```
00:00-01:00 → Introduction + lancement app
01:00-03:00 → Inscription email + vérification Firebase
03:00-05:00 → Connexion Google + sync automatique  
05:00-07:00 → Navigation app + modification profil
07:00-08:00 → Questions jury + Firebase Console final
```

### **Checkpoints Critiques :**
- [ ] **App lance sans erreur**
- [ ] **Inscription crée bien l'utilisateur**
- [ ] **Email confirmation fonctionne**
- [ ] **Google Auth redirige correctement**
- [ ] **Firestore sync en temps réel**
- [ ] **Navigation post-login fluide**

---

## 🚨 DÉPANNAGE RAPIDE

### **Si app crash au lancement :**
```bash
# Vérifier logs
flutter logs

# Rebuild propre
flutter clean && flutter pub get && flutter run
```

### **Si Firebase ne répond pas :**
```bash
# Vérifier config
cat lib/firebase_options.dart

# Tester connexion
ping firestore.googleapis.com
```

### **Si Google Auth échoue :**
```bash
# Vérifier SHA-1 fingerprint
keytool -list -v -keystore ~/.android/debug.keystore

# Comparer avec Firebase Console → Project Settings → SHA-1
```

---

## 📊 MÉTRIQUES À NOTER

### **Performance :**
- Temps lancement app : _____ sec
- Temps inscription : _____ sec  
- Temps connexion Google : _____ sec
- Sync Firestore : _____ ms

### **Fonctionnel :**
- Inscription email : ✅/❌
- Connexion Google : ✅/❌
- Navigation post-auth : ✅/❌
- Sync temps réel : ✅/❌

---

## 🎬 BACKUP PLANS

### **Plan A : Démo Live (idéal)**
Tout fonctionne → démo temps réel complète

### **Plan B : Vidéo Backup** 
Internet instable → vidéo pre-recorded de 3min

### **Plan C : Screenshots**
App crash → présentation statique + code source

### **Plan D : Émulateur**
Téléphone HS → Android Studio emulator ready

---

*Checklist technique pour une démo sans stress ! 🎯*