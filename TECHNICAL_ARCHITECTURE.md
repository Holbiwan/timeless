# 🏗️ TIMELESS - Architecture Technique Détaillée

## 📋 Vue d'ensemble du projet

**Timeless** est une application fullstack de recherche d'emploi développée en Flutter avec Firebase comme backend.

### 🎯 Objectif
Faciliter la recherche d'emploi en connectant candidats et recruteurs via un système de matching intelligent.

---

## 🏛️ Architecture Générale

### 📱 Frontend (Flutter)
- **Framework** : Flutter 3.33.x (Dart)
- **State Management** : GetX
- **UI/UX** : Material Design avec thème personnalisé rouge
- **Navigation** : GetX routing

### 🔥 Backend (Firebase)
- **Authentication** : Firebase Auth (Google, Email/Password)
- **Base de données** : Firestore (NoSQL)
- **Storage** : Firebase Storage (CVs, photos)
- **Notifications** : Firebase Cloud Messaging
- **Hosting** : Firebase Hosting (landing page)

### 🌐 APIs Externes
- **Countries API** : Récupération des pays pour les formulaires
- **Email Service** : Intégration pour notifications email

---

## 🗂️ Structure du projet

```
timeless/
├── 📱 Frontend (Flutter)
│   ├── lib/
│   │   ├── main.dart              # Point d'entrée
│   │   ├── screen/                # Écrans de l'app
│   │   │   ├── auth/              # Authentification
│   │   │   ├── dashboard/         # Tableau de bord
│   │   │   ├── job_detail_screen/ # Détails des emplois
│   │   │   ├── manager_section/   # Interface recruteur
│   │   │   └── ...
│   │   ├── service/               # Services métier
│   │   │   ├── pref_services.dart # Préférences locales
│   │   │   ├── translation_service.dart
│   │   │   └── accessibility_service.dart
│   │   ├── api/                   # Intégrations API
│   │   ├── common/                # Composants réutilisables
│   │   └── utils/                 # Utilitaires
│   └── assets/                    # Images, données
├── 🔥 Backend (Firebase)
│   ├── Authentication             # Gestion des utilisateurs
│   ├── Firestore                  # Base de données
│   ├── Storage                    # Fichiers (CVs, photos)
│   └── Cloud Messaging           # Notifications push
└── 🌐 Web
    └── index.html                 # Landing page
```

---

## 🗄️ Base de données (Firestore)

### Collections principales :

#### 👤 `users`
```javascript
{
  id: string,
  email: string,
  displayName: string,
  photoURL: string,
  role: 'candidate' | 'recruiter',
  createdAt: timestamp,
  profile: {
    skills: string[],
    experience: string,
    location: string
  }
}
```

#### 💼 `jobs`
```javascript
{
  id: string,
  title: string,
  company: string,
  description: string,
  requirements: string[],
  location: string,
  salary: string,
  postedBy: string, // ID du recruteur
  createdAt: timestamp,
  isActive: boolean
}
```

#### 📝 `applications`
```javascript
{
  id: string,
  jobId: string,
  candidateId: string,
  status: 'pending' | 'accepted' | 'rejected',
  cvUrl: string,
  appliedAt: timestamp,
  message?: string
}
```

---

## 🔧 Choix techniques justifiés

### 1. **Flutter** (Frontend)
✅ **Avantages** :
- Cross-platform (Android/iOS/Web)
- Performance native
- UI cohérente sur toutes les plateformes
- Développement rapide avec Hot Reload

### 2. **Firebase** (Backend)
✅ **Avantages** :
- Backend-as-a-Service (pas de serveur à gérer)
- Authentification intégrée
- Base de données temps réel
- Scalabilité automatique
- Intégration parfaite avec Flutter

### 3. **GetX** (State Management)
✅ **Avantages** :
- Léger et performant
- Navigation simplifiée
- Gestion d'état réactive
- Injection de dépendances intégrée

### 4. **Firestore** (Base de données)
✅ **Avantages** :
- NoSQL flexible
- Synchronisation temps réel
- Offline support
- Requêtes puissantes

---

## 🔄 Flux de données

### Authentification
```
User → Flutter App → Firebase Auth → Firestore (user profile)
```

### Recherche d'emploi
```
Candidate → Search → Firestore query → Job results → Flutter UI
```

### Candidature
```
Apply → Upload CV (Storage) → Create application (Firestore) → Notification (FCM)
```

---

## 🚀 Fonctionnalités clés

### 👨‍💼 Côté Candidat
- ✅ Inscription/Connexion (Email + Google)
- ✅ Recherche d'emplois
- ✅ Système de matching intelligent
- ✅ Candidature avec CV
- ✅ Suivi des candidatures
- ✅ Notifications push
- ✅ Mode invité (navigation sans compte)

### 👩‍💼 Côté Recruteur
- ✅ Interface dédiée
- ✅ Publication d'offres
- ✅ Gestion des candidatures
- ✅ Système de filtres
- ✅ Chat avec candidats
- ✅ Analytics de base

### 🌍 Fonctionnalités avancées
- ✅ Support multilingue
- ✅ Accessibilité
- ✅ Mode sombre/clair
- ✅ Traduction automatique

---

## 🔒 Sécurité

### Authentification
- Firebase Auth avec tokens JWT
- Validation côté client et serveur
- Règles de sécurité Firestore

### Données
- Chiffrement des données en transit (HTTPS)
- Règles d'accès granulaires dans Firestore
- Validation des inputs utilisateur

---

## 📈 Performance et optimisation

### Frontend
- Lazy loading des écrans
- Images optimisées
- Cache local (SharedPreferences)
- Gestion mémoire efficace

### Backend
- Indexes Firestore optimisés
- Requêtes paginées
- Offline sync

---

## 🧪 Tests et qualité

### Stratégie de test
- Tests unitaires (services)
- Tests d'intégration (Firebase)
- Tests UI (flow principal)

### Outils de qualité
- Linter Flutter
- Analyse statique du code
- Monitoring Firebase

---

## 🚀 Déploiement

### Environnements
- **Dev** : Émulateur local + Firebase dev
- **Staging** : Firebase staging
- **Production** : Firebase production + Store

### CI/CD (à implémenter)
```
GitHub → Actions → Build → Test → Deploy → Store
```

---

## 📊 Monitoring

### Analytics
- Firebase Analytics
- Crash reporting
- Performance monitoring

### KPIs
- Nombre d'inscriptions
- Taux de matching
- Conversions candidatures

---

## 🔮 Évolutions futures

### Court terme (next sprint)
- [ ] Tests automatisés complets
- [ ] Optimisation performances
- [ ] Mode hors-ligne avancé

### Moyen terme
- [ ] IA pour matching avancé
- [ ] Vidéo calls intégrées
- [ ] API REST publique

### Long terme
- [ ] Version Web complète
- [ ] Intégration LinkedIn
- [ ] Blockchain pour vérifications