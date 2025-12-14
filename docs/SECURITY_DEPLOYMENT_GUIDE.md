# 🔒 Guide de Déploiement Sécurisé - Timeless API

## 📋 Vue d'ensemble

Ce guide détaille la mise en place sécurisée de l'API Timeless pour la gestion des profils candidats, l'upload de CV et le système de candidatures.

## 🔧 1. Configuration Firebase

### 1.1 Sécurité Firestore

**📂 Déployer les règles de sécurité :**
```bash
# Installer Firebase CLI si pas déjà fait
npm install -g firebase-tools

# Se connecter à Firebase
firebase login

# Initialiser le projet (dans le dossier backend/)
firebase init firestore

# Déployer les règles
firebase deploy --only firestore:rules
```

**⚠️ Vérifications importantes :**
- [ ] Les règles interdisent l'accès non authentifié
- [ ] Chaque utilisateur ne peut accéder qu'à ses propres données
- [ ] Les rôles (candidate/recruiter) sont respectés
- [ ] La taille des fichiers CV est limitée (10MB)
- [ ] Les types de fichiers sont restreints (PDF, DOC, DOCX)

### 1.2 Configuration Storage

**📁 Créer les règles Firebase Storage :**
```javascript
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // CVs des candidats
    match /cvs/{userId}/{cvId}/{fileName} {
      allow read, write: if request.auth != null 
                      && request.auth.uid == userId
                      && resource.size < 10 * 1024 * 1024; // 10MB max
      allow read: if request.auth != null 
               && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'recruiter';
    }
    
    // Photos de profil
    match /profile_photos/{userId}/{fileName} {
      allow read, write: if request.auth != null 
                      && request.auth.uid == userId
                      && resource.size < 5 * 1024 * 1024; // 5MB max
    }
    
    // Interdire tout autre accès
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

**Déployer les règles Storage :**
```bash
firebase deploy --only storage
```

### 1.3 Configuration Authentication

**🔐 Paramètres recommandés :**

1. **Providers autorisés :**
   - ✅ Email/Password
   - ✅ Google
   - ❌ Désactiver les providers non nécessaires

2. **Paramètres de sécurité :**
   ```javascript
   // Dans Firebase Console > Authentication > Settings
   - Email enumeration protection: ENABLED
   - Password policy: Strong (8+ chars, mixed case, numbers, symbols)
   - Multi-factor authentication: OPTIONAL (recommandé pour les recruteurs)
   ```

## 🗄️ 2. Structure de Base de Données

### 2.1 Collections principales

```
📁 firestore/
├── 👤 users/{userId}
│   ├── id: string
│   ├── email: string
│   ├── displayName: string
│   ├── role: "candidate" | "recruiter" | "admin"
│   └── createdAt: timestamp
│
├── 👨‍💼 candidate_profiles/{candidateId}
│   ├── [Profil complet du candidat]
│   └── [Voir CandidateProfileModel]
│
├── 📄 cvs/{cvId}
│   ├── [Métadonnées des CVs]
│   └── [Voir CVModel]
│
├── 📝 applications/{applicationId}
│   ├── [Candidatures]
│   └── [Voir ApplicationModel]
│
└── 💼 jobs/{jobId}
    └── [Annonces d'emploi]
```

### 2.2 Index recommandés

**⚡ Créer les index Firestore suivants :**

```javascript
// Candidatures par candidat
candidateId ASC, appliedAt DESC

// Candidatures par job
jobId ASC, appliedAt DESC

// CVs par candidat
candidateId ASC, uploadedAt DESC

// Applications par statut
status ASC, appliedAt DESC
```

**Créer via Firebase Console ou CLI :**
```bash
# Via CLI
firebase firestore:indexes
```

## 🚀 3. Déploiement de l'API

### 3.1 Dépendances Flutter

**📦 Ajouter dans pubspec.yaml :**
```yaml
dependencies:
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  firebase_firestore: ^4.13.6
  firebase_storage: ^11.6.0
  
  # State Management
  get: ^4.6.6
  
  # File handling
  file_picker: ^6.1.1
  
  # Validation
  form_validator: ^2.1.1
```

### 3.2 Configuration de l'app

**🔧 Dans main.dart :**
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(MyApp());
}
```

### 3.3 Initialisation du contrôleur

**📱 Dans votre app :**
```dart
// Enregistrer le contrôleur
Get.put(CandidateController());

// Utiliser dans les widgets
final candidateController = Get.find<CandidateController>();
```

## 🛡️ 4. Mesures de Sécurité Avancées

### 4.1 Validation côté client

**✅ Validations implémentées :**

- Emails : Format valide avec regex
- Téléphones : Format international accepté
- URLs : Validation et nettoyage automatique
- Fichiers : Type, taille, nom validés
- Données : Sanitisation des entrées

### 4.2 Sécurité des uploads

**📤 Protection des uploads :**

```dart
// Validations automatiques dans CandidateApiService
- Taille max : 10MB pour CVs, 5MB pour photos
- Types autorisés : PDF, DOC, DOCX pour CVs
- Scan de virus : À implémenter si nécessaire
- Noms de fichiers : Sanitisation automatique
```

### 4.3 Audit et logs

**📊 Surveillance recommandée :**

```javascript
// Alertes Firebase à configurer
- Tentatives de connexion suspectes
- Uploads de fichiers volumineux
- Accès non autorisés aux données
- Erreurs d'authentification répétées
```

## 🔍 5. Tests et Validation

### 5.1 Tests de sécurité

**🧪 Checklist de tests :**

- [ ] Tentative d'accès aux données d'autres utilisateurs
- [ ] Upload de fichiers malveillants
- [ ] Injection dans les champs de formulaire
- [ ] Tentative de modification des rôles
- [ ] Tests d'authentification / autorisation

### 5.2 Tests fonctionnels

**✅ Scénarios de test :**

```dart
// Tests à implémenter
1. Création de profil candidat
2. Upload de CV multiple
3. Candidature à une annonce
4. Modification de profil
5. Suppression de CV
6. Retrait de candidature
```

## 📈 6. Monitoring et Analytics

### 6.1 Métriques importantes

**📊 KPIs à surveiller :**

- Nombre de créations de profils / jour
- Taux d'upload de CV réussis
- Nombre de candidatures / jour
- Erreurs d'API fréquentes
- Temps de réponse des requêtes

### 6.2 Firebase Analytics

**📱 Événements à tracker :**

```dart
// Événements recommandés
- profile_created
- cv_uploaded
- job_application_sent
- profile_completed
- cv_download
```

## 🚨 7. Procédures d'urgence

### 7.1 En cas de violation de sécurité

**🔒 Actions immédiates :**

1. Révoquer toutes les sessions actives
2. Changer les clés API Firebase
3. Auditer les logs d'accès
4. Notifier les utilisateurs affectés
5. Renforcer les règles de sécurité

### 7.2 Sauvegarde et restauration

**💾 Stratégie de backup :**

```bash
# Export régulier des données
gcloud firestore export gs://timeless-backup/$(date +%Y%m%d)

# Test de restauration mensuel
gcloud firestore import gs://timeless-backup/YYYYMMDD
```

## ✅ 8. Checklist de déploiement

**📋 Avant la mise en production :**

- [ ] Règles Firestore déployées et testées
- [ ] Règles Storage configurées
- [ ] Index Firestore créés
- [ ] Variables d'environnement sécurisées
- [ ] Tests de sécurité passés
- [ ] Monitoring configuré
- [ ] Plan de sauvegarde en place
- [ ] Documentation API complète
- [ ] Formation équipe sur les procédures

## 📞 9. Contact et Support

**🆘 En cas de problème :**

- Documentation technique : `/docs/api/`
- Tests de sécurité : `/tests/security/`
- Logs d'erreur : Firebase Console > Project > Logs
- Support Firebase : Console > Support

---

## 🎯 Utilisation de l'API

### Exemple d'utilisation complète :

```dart
// 1. Initialiser le contrôleur
final controller = Get.put(CandidateController());

// 2. Créer un profil
await controller.createProfile(
  email: 'candidate@example.com',
  fullName: 'John Doe',
  phone: '+33123456789',
  location: 'Paris, France',
);

// 3. Upload un CV
await controller.uploadCV();

// 4. Postuler à une annonce
await controller.applyToJob(
  jobId: 'job123',
  coverLetter: 'Lettre de motivation...',
);
```

Cette API est maintenant prête pour un déploiement sécurisé en production ! 🚀