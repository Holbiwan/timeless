# 🏗️ ARCHITECTURE COMPLÈTE - APPLICATION TIMELESS

## 📑 Table des matières
1. [Vue d'ensemble](#vue-densemble)
2. [Frontend Flutter](#frontend-flutter)
3. [Backend Node.js](#backend-nodejs)
4. [Base de données](#base-de-données)
5. [Authentification & Sécurité](#authentification--sécurité)
6. [Communication API](#communication-api)
7. [Flux de données](#flux-de-données)
8. [Architecture technique détaillée](#architecture-technique-détaillée)
9. [Sécurité & Protection](#sécurité--protection)
10. [Déploiement & Production](#déploiement--production)

---

## 🎯 Vue d'ensemble

**Timeless** est une application complète de recherche d'emploi construite avec une architecture moderne Flutter + Firebase/Node.js. L'application permet aux candidats de chercher des emplois, postuler, et gérer leurs candidatures, tout en offrant aux recruteurs une plateforme pour publier des offres et gérer les candidatures.

### Architecture générale
```
📱 Frontend Flutter (Client)
    ↕️ HTTP/HTTPS + WebSockets
🔥 Firebase (Auth + Firestore)
    ↕️ REST API
🖥️ Backend Node.js/Express (API)
    ↕️ ODM/ORM
💾 MongoDB Atlas (Base de données)
```

---

## 📱 Frontend Flutter

### 🏗️ Structure du projet Flutter

```
lib/
├── 📁 common/               # Composants réutilisables
│   └── widgets/            # Widgets communs (TextField, Loader, etc.)
├── 📁 screen/              # Écrans de l'application
│   ├── auth/              # Authentification (Sign up, Sign in, Reset)
│   ├── dashboard/         # Tableau de bord principal
│   ├── job_detail_screen/ # Détails des emplois
│   └── manager_section/   # Section recruteurs
├── 📁 service/            # Services de communication
│   ├── google_auth_service.dart    # Authentification Google
│   ├── candidate_api_service.dart  # API candidats
│   └── translation_service.dart    # Traduction automatique
├── 📁 models/             # Modèles de données
└── 📁 controllers/        # Contrôleurs GetX
```

### 🔧 Technologies utilisées

| Technologie | Usage | Version |
|-------------|-------|---------|
| **Flutter** | Framework UI | SDK >=3.0.0 |
| **Firebase Auth** | Authentification | ^6.0.2 |
| **Cloud Firestore** | Base NoSQL temps réel | ^6.0.1 |
| **Firebase Storage** | Stockage fichiers | ^13.0.1 |
| **GetX** | Gestion d'état | ^4.7.2 |
| **Google Sign-In** | OAuth Google | 6.2.1 |

### 🎨 Architecture de l'UI

#### Pattern MVC avec GetX
```dart
// Contrôleur
class HomeController extends GetxController {
  var jobs = <JobModel>[].obs;
  
  @override
  void onInit() {
    fetchJobs();
  }
  
  void fetchJobs() async {
    // Logic métier
  }
}

// Vue
class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());
  
  Widget build(context) => Obx(() =>
    ListView.builder(
      itemCount: controller.jobs.length,
      // UI reactive
    )
  );
}
```

#### Widgets réutilisables
- **CommonTextField**: Champs de saisie standardisés
- **CommonLoader**: Indicateurs de chargement
- **CommonErrorBox**: Gestion d'erreurs unified

---

## 🖥️ Backend Node.js

### 🏗️ Architecture serveur

```javascript
// server.js - Point d'entrée
const express = require('express');
const app = express();

// Middlewares de sécurité
app.use(helmet());
app.use(cors());
app.use(rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // 100 requests par IP
}));

// Routes principales
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/jobs', jobRoutes);
app.use('/api/applications', applicationRoutes);
```

### 📊 Modèle de données MongoDB

```javascript
// models/User.js
const userSchema = new mongoose.Schema({
  // Informations de base
  email: { type: String, required: true, unique: true },
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  
  // Informations professionnelles
  title: String,
  bio: String,
  skills: [String],
  experience: { type: String, enum: ['junior', 'mid', 'senior'] },
  
  // Localisation
  location: {
    city: String,
    country: String,
    remote: Boolean
  },
  
  // Fichiers
  profilePicture: { url: String, publicId: String },
  cv: { url: String, uploadedAt: Date },
  
  // Préférences d'emploi
  jobPreferences: {
    categories: [String],
    salaryRange: { min: Number, max: Number },
    workType: [String]
  }
});
```

### 🔐 Middlewares de sécurité

```javascript
// Sécurité multicouche
1. Helmet.js - Headers de sécurité HTTP
2. CORS - Politique d'origine croisée
3. Rate Limiting - Protection DDoS
4. JWT Authentication - Tokens sécurisés
5. Input Validation - Validation des données
6. Error Handling - Gestion d'erreurs centralisée
```

---

## 💾 Base de données

### 🔥 Firebase Firestore (Principal)

#### Structure des collections
```
Auth/
├── User/
│   └── register/
│       └── {userId}/
│           ├── Email
│           ├── fullName
│           ├── photoURL
│           └── createdAt

candidate_profiles/
├── {userId}/
│   ├── email
│   ├── fullName
│   ├── phone
│   ├── currentCVId
│   └── profileCompletionScore

applications/
├── {applicationId}/
│   ├── jobId
│   ├── candidateId
│   ├── status (pending/accepted/rejected)
│   ├── appliedAt
│   └── coverLetter
```

#### Avantages Firestore
- ✅ **Temps réel**: Synchronisation automatique
- ✅ **Offline**: Fonctionne sans connexion
- ✅ **Sécurité**: Rules de sécurité côté serveur
- ✅ **Scalabilité**: Auto-scaling Google Cloud

### 🗄️ MongoDB Atlas (Backend)

#### Collections principales
```javascript
// users - Profils utilisateurs complets
{
  _id: ObjectId,
  email: String,
  firstName: String,
  lastName: String,
  skills: [String],
  jobPreferences: Object,
  appliedJobs: [JobApplication],
  timestamps: { createdAt, updatedAt }
}

// jobs - Offres d'emploi
{
  _id: ObjectId,
  title: String,
  company: String,
  description: String,
  requirements: [String],
  salary: { min: Number, max: Number },
  location: Object,
  postedBy: ObjectId,
  applicants: [ObjectId]
}
```

---

## 🔐 Authentification & Sécurité

### 🚪 Flux d'authentification

#### 1. Authentification Google OAuth 2.0
```dart
// lib/service/google_auth_service.dart
class GoogleAuthService {
  static Future<User?> signInWithGoogle() async {
    // 1. Configuration Google Sign-In
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      serverClientId: 'GOOGLE_CLIENT_ID',
      scopes: ['email', 'profile']
    );
    
    // 2. Authentification utilisateur
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = 
        await googleUser.authentication;
    
    // 3. Création des credentials Firebase
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    // 4. Connexion à Firebase
    final UserCredential userCredential = 
        await FirebaseAuth.instance.signInWithCredential(credential);
    
    return userCredential.user;
  }
}
```

#### 2. Sauvegarde sécurisée Firestore
```dart
static Future<void> saveUserToFirestore(User user) async {
  await FirebaseFirestore.instance
    .collection("Auth")
    .doc("User")
    .collection("register")
    .doc(user.uid)
    .set({
      "Email": user.email,
      "fullName": user.displayName,
      "photoURL": user.photoURL,
      "createdAt": FieldValue.serverTimestamp(),
      "uid": user.uid,
    }, SetOptions(merge: true));
}
```

### 🛡️ Sécurité multicouche

#### Frontend (Flutter)
- ✅ **Validation côté client**: Vérification immédiate des données
- ✅ **Tokens sécurisés**: Stockage sécurisé des JWT
- ✅ **HTTPS obligatoire**: Toutes les communications chiffrées
- ✅ **Biométrie**: Authentication par empreinte/Face ID

#### Backend (Node.js)
```javascript
// Middleware d'authentification JWT
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.sendStatus(401);
  }
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};
```

#### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users peuvent seulement accéder à leurs propres données
    match /candidate_profiles/{userId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == userId;
    }
    
    // Applications visibles par le candidat et le recruteur
    match /applications/{applicationId} {
      allow read, write: if request.auth != null && (
        request.auth.uid == resource.data.candidateId ||
        request.auth.uid == resource.data.employerId
      );
    }
  }
}
```

---

## 🔗 Communication API

### 📡 Architecture API REST

#### Service candidats (Frontend → Backend)
```dart
// lib/service/candidate_api_service.dart
class CandidateApiService {
  static const String baseUrl = 'https://api.timeless.com';
  
  // Créer profil candidat
  static Future<CandidateProfileModel> createCandidateProfile({
    required String email,
    required String fullName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Non authentifié');
    
    // Transaction Firestore pour consistance
    return await FirebaseFirestore.instance.runTransaction((transaction) async {
      final profile = CandidateProfileModel(
        id: user.uid,
        email: email,
        fullName: fullName,
        createdAt: DateTime.now(),
      );
      
      // Créer dans candidate_profiles
      transaction.set(
        FirebaseFirestore.instance.collection('candidate_profiles').doc(user.uid),
        profile.toJson()
      );
      
      return profile;
    });
  }
}
```

#### Endpoints principaux
```javascript
// Backend routes
GET    /api/users/profile        # Récupérer profil utilisateur
PUT    /api/users/profile        # Mettre à jour profil
POST   /api/users/upload-cv      # Uploader CV
GET    /api/jobs                 # Lister les emplois
POST   /api/jobs/{id}/apply      # Postuler à un emploi
GET    /api/applications         # Mes candidatures
```

### 🔄 Synchronisation temps réel

#### Streams Firestore
```dart
// Écoute en temps réel des changements
static Stream<CandidateProfileModel?> candidateProfileStream() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(null);
  
  return FirebaseFirestore.instance
    .collection('candidate_profiles')
    .doc(user.uid)
    .snapshots()
    .map((doc) {
      if (!doc.exists) return null;
      return CandidateProfileModel.fromJson(doc.data());
    });
}
```

---

## 📊 Flux de données

### 🔄 Cycle de vie d'une candidature

```
1. 👤 CANDIDAT
   ↓ Recherche emplois
   
2. 🔍 RECHERCHE
   ├── Frontend: Affichage liste jobs
   ├── Firebase: Query jobs collection
   └── UI: Filtres et tri
   
3. 📝 CANDIDATURE
   ├── Upload CV → Firebase Storage
   ├── Données profil → Firestore candidate_profiles
   ├── Candidature → Firestore applications
   └── Notification → Recruteur
   
4. 👨‍💼 RECRUTEUR
   ├── Reçoit notification
   ├── Consulte candidatures
   ├── Filtre et tri
   └── Décision (Accepter/Rejeter)
   
5. 📩 NOTIFICATION CANDIDAT
   ├── Mise à jour status application
   ├── Push notification
   └── Email confirmation
```

### 📱 Gestion d'état GetX

```dart
// Contrôleur reactive pour les candidatures
class ApplicationController extends GetxController {
  var applications = <ApplicationModel>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;
  
  @override
  void onInit() {
    // Stream automatique des candidatures
    ever(applications, (_) => _updateUI());
    loadApplications();
  }
  
  void loadApplications() async {
    isLoading(true);
    try {
      // Stream Firestore temps réel
      FirebaseFirestore.instance
        .collection('applications')
        .where('candidateId', isEqualTo: currentUserId)
        .snapshots()
        .listen((snapshot) {
          applications.value = snapshot.docs
            .map((doc) => ApplicationModel.fromJson(doc.data()))
            .toList();
        });
    } catch (e) {
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }
}
```

---

## 🏗️ Architecture technique détaillée

### 📐 Patterns architecturaux

#### 1. **MVVM + Repository Pattern**
```dart
// Repository pour abstraction données
abstract class JobRepository {
  Future<List<JobModel>> getJobs();
  Future<JobModel> getJobById(String id);
  Stream<List<JobModel>> jobsStream();
}

// Implémentation Firebase
class FirebaseJobRepository implements JobRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Future<List<JobModel>> getJobs() async {
    final snapshot = await _firestore.collection('jobs').get();
    return snapshot.docs
      .map((doc) => JobModel.fromJson(doc.data()))
      .toList();
  }
}

// ViewModel avec injection de dépendance
class JobViewModel extends GetxController {
  final JobRepository _repository;
  JobViewModel(this._repository);
  
  var jobs = <JobModel>[].obs;
  
  void loadJobs() async {
    try {
      final result = await _repository.getJobs();
      jobs.assignAll(result);
    } catch (e) {
      // Gestion d'erreur
    }
  }
}
```

#### 2. **Dependency Injection avec GetX**
```dart
class DependencyInjection {
  static void init() {
    // Services
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<AuthService>(() => GoogleAuthService());
    
    // Repositories
    Get.lazyPut<JobRepository>(() => FirebaseJobRepository());
    Get.lazyPut<UserRepository>(() => FirebaseUserRepository());
    
    // Controllers
    Get.lazyPut(() => HomeController(Get.find()));
    Get.lazyPut(() => ProfileController(Get.find()));
  }
}
```

### 🚀 Performance et optimisation

#### 1. **Lazy Loading et Pagination**
```dart
class JobListController extends GetxController {
  final int _pageSize = 20;
  DocumentSnapshot? _lastDocument;
  var hasMore = true.obs;
  
  void loadMoreJobs() async {
    Query query = FirebaseFirestore.instance
      .collection('jobs')
      .orderBy('createdAt', descending: true)
      .limit(_pageSize);
    
    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }
    
    final snapshot = await query.get();
    if (snapshot.docs.length < _pageSize) {
      hasMore(false);
    }
    
    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
      final newJobs = snapshot.docs
        .map((doc) => JobModel.fromJson(doc.data()))
        .toList();
      jobs.addAll(newJobs);
    }
  }
}
```

#### 2. **Cache et persistance**
```dart
// Cache intelligent avec SharedPreferences
class CacheService {
  static const String _jobsCacheKey = 'cached_jobs';
  
  static Future<void> cacheJobs(List<JobModel> jobs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(jobs.map((e) => e.toJson()).toList());
    await prefs.setString(_jobsCacheKey, jsonString);
  }
  
  static Future<List<JobModel>> getCachedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_jobsCacheKey);
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => JobModel.fromJson(json)).toList();
  }
}
```

---

## 🛡️ Sécurité & Protection

### 🔒 Sécurisation des données

#### 1. **Chiffrement et stockage**
```dart
// Stockage sécurisé des tokens
class SecureStorage {
  static const _storage = FlutterSecureStorage();
  
  static Future<void> storeToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  static Future<void> clearStorage() async {
    await _storage.deleteAll();
  }
}
```

#### 2. **Validation et sanitisation**
```dart
class ValidationService {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static bool isValidPhone(String phone) {
    return RegExp(r'^[+]?[\d\s\-\(\)]{8,15}$').hasMatch(phone);
  }
  
  static String sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp(r'[<>]'), '');
  }
}
```

### 🔐 Authentification à deux facteurs (2FA)

```dart
// Service OTP pour 2FA
class OTPService {
  static Future<void> sendOTP(String phoneNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception('Erreur vérification: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        // Stocker verificationId pour vérification
      },
    );
  }
}
```

### 🚨 Monitoring et logging

```javascript
// Backend - Monitoring middleware
const morgan = require('morgan');

app.use(morgan('combined', {
  stream: {
    write: (message) => {
      console.log(message.trim());
      // Envoyer vers service de monitoring (DataDog, New Relic, etc.)
    }
  }
}));

// Détection d'intrusion
const suspiciousActivity = (req, res, next) => {
  const suspicious = [
    /sql injection patterns/i,
    /xss patterns/i,
    /script.*alert/i
  ];
  
  const userAgent = req.get('User-Agent') || '';
  const body = JSON.stringify(req.body);
  
  for (const pattern of suspicious) {
    if (pattern.test(userAgent + body)) {
      console.warn(`Suspicious activity detected: ${req.ip}`);
      return res.status(403).json({ error: 'Request blocked' });
    }
  }
  
  next();
};
```

---

## 🚀 Déploiement & Production

### ☁️ Infrastructure Cloud

#### Firebase Configuration
```yaml
# firebase.json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "storage": {
    "rules": "storage.rules"
  },
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/node_modules/**"],
    "rewrites": [{
      "source": "**",
      "destination": "/index.html"
    }]
  }
}
```

#### Déploiement Backend (Node.js)
```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 5000
CMD ["node", "server.js"]
```

### 📊 Monitoring et Analytics

```dart
// Firebase Analytics integration
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static Future<void> logJobView(String jobId) async {
    await _analytics.logEvent(
      name: 'job_view',
      parameters: {
        'job_id': jobId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  static Future<void> logApplicationSubmission(String jobId) async {
    await _analytics.logEvent(
      name: 'application_submit',
      parameters: {
        'job_id': jobId,
        'user_id': FirebaseAuth.instance.currentUser?.uid,
      },
    );
  }
}
```

### 🔧 Configuration environnement

```dart
// Configuration par environnement
class AppConfig {
  static const String _environment = String.fromEnvironment('ENV', defaultValue: 'dev');
  
  static String get apiBaseUrl {
    switch (_environment) {
      case 'prod':
        return 'https://api.timeless.app';
      case 'staging':
        return 'https://staging-api.timeless.app';
      default:
        return 'http://localhost:5000';
    }
  }
  
  static bool get enableAnalytics => _environment == 'prod';
  static bool get enableCrashReporting => _environment != 'dev';
}
```

---

## 📈 Statistiques et métriques

### KPIs de performance
- **Temps de chargement**: < 2s pour l'affichage initial
- **Synchronisation**: Temps réel Firestore < 500ms
- **Upload CV**: < 10s pour fichiers 5MB
- **Recherche**: < 1s pour 1000+ emplois
- **Disponibilité**: 99.9% uptime

### Métriques utilisateur
- **Rétention**: Taux de retour à 7 jours
- **Engagement**: Temps passé dans l'app
- **Conversion**: Candidatures → Entretiens → Embauches
- **Satisfaction**: Ratings et feedback utilisateurs

---

## 🔮 Évolutions futures

### Fonctionnalités prévues
- 🤖 **IA matching**: Recommandations personnalisées emplois/candidats
- 💬 **Chat temps réel**: Communication directe recruteur/candidat
- 📹 **Vidéo entretiens**: Intégration WebRTC pour entretiens à distance
- 📱 **PWA**: Progressive Web App pour desktop
- 🔔 **Notifications intelligentes**: Alertes contextuelles
- 📊 **Analytics avancés**: Dashboard insights recruteurs

### Améliorations techniques
- **Microservices**: Décomposition backend en services
- **GraphQL**: API plus flexible que REST
- **Service Workers**: Cache offline avancé
- **WebAssembly**: Performance calculs lourds
- **Tests automatisés**: Coverage > 90%

---

## 📞 Support et maintenance

### Contacts techniques
- **Architecture**: Équipe DevOps
- **Frontend**: Équipe Flutter
- **Backend**: Équipe Node.js
- **Sécurité**: Équipe Security
- **DevOps**: Équipe Infrastructure

### Documentation additionnelle
- 📚 [Guide développeur](./DEV_GUIDE.md)
- 🔐 [Guide sécurité](./SECURITY_GUIDE.md)
- 🚀 [Guide déploiement](./DEPLOYMENT_GUIDE.md)
- 🧪 [Guide tests](./TESTING_GUIDE.md)

---

*Dernière mise à jour: Novembre 2024*  
*Version: 1.0.0*  
*Équipe: Timeless Development Team*