# Timeless - User Stories & Pitch

## 🎯 Pitch de l'Application Timeless

**Timeless** est une plateforme d'emploi nouvelle génération qui révolutionne la manière dont candidats et employeurs se connectent. En combinant intelligence artificielle, design accessible et fonctionnalités multilingues, Timeless comble le fossé entre talent et opportunités professionnelles.

### Vision

*"Bridging the gap with timeless talent"* - Connecter les talents intemporels aux opportunités d'aujourd'hui.

### Proposition de Valeur

- **Pour les Candidats** : Trouvez l'emploi parfait grâce à notre matching intelligent et postulez en un clic
- **Pour les Employeurs** : Découvrez les meilleurs talents grâce à notre algorithme de recommandation et gérez vos recrutements efficacement
- **Accessibilité Universelle** : Une plateforme inclusive avec support visuel et auditif
- **Multilingue** : Support français et anglais pour une audience internationale

## 👤 User Stories - Compte Candidat/Employé

### Inscription et Authentification

- **US001** - En tant que candidat, je veux créer un compte avec mon email pour accéder à la plateforme
- **US002** - En tant que candidat, je veux vérifier mon email pour sécuriser mon compte
- **US003** - En tant que candidat, je veux me connecter facilement pour retrouver mes candidatures

### Profil et Préférences

- **US004** - En tant que candidat, je veux compléter mon profil professionnel pour améliorer mes recommandations
- **US005** - En tant que candidat, je veux uploader mon CV pour postuler rapidement
- **US006** - En tant que candidat, je veux définir mes préférences de poste (salaire, localisation, type de contrat)

### Recherche et Découverte d'Emplois

- **US007** - En tant que candidat, je veux rechercher des offres d'emploi par mots-clés
- **US008** - En tant que candidat, je veux filtrer les offres par catégorie (Design, UX, Software, etc.)
- **US009** - En tant que candidat, je veux voir des recommandations personnalisées basées sur mon profil
- **US010** - En tant que candidat, je veux consulter les détails d'une offre d'emploi
- **US011** - En tant que candidat, je veux sauvegarder des offres pour les consulter plus tard

### Candidature et Suivi

- **US012** - En tant que candidat, je veux postuler à une offre en un clic avec mon CV
- **US013** - En tant que candidat, je veux ajouter une lettre de motivation personnalisée
- **US014** - En tant que candidat, je veux suivre le statut de mes candidatures
- **US015** - En tant que candidat, je veux recevoir des notifications sur l'évolution de mes candidatures

### Accessibilité et Préférences

- **US016** - En tant que candidat malvoyant, je veux activer le mode haut contraste pour mieux voir
- **US017** - En tant que candidat sourd, je veux désactiver les sons et activer les vibrations
- **US018** - En tant que candidat, je veux ajuster la taille du texte pour ma lisibilité
- **US019** - En tant que candidat international, je veux changer la langue entre français et anglais

## 🏢 User Stories - Compte Employeur/Recruteur

### Inscription et Authentification Employeur
- **US020** - En tant que recruteur, je veux créer un compte employeur pour publier des offres
- **US021** - En tant que recruteur, je veux renseigner les informations de mon entreprise
- **US022** - En tant que recruteur, je veux vérifier mon compte pour crédibiliser mon entreprise

### Gestion des Offres d'Emploi
- **US023** - En tant que recruteur, je veux créer une nouvelle offre d'emploi avec tous les détails
- **US024** - En tant que recruteur, je veux modifier une offre d'emploi existante
- **US025** - En tant que recruteur, je veux définir les critères de matching pour mes offres
- **US026** - En tant que recruteur, je veux publier une offre immédiatement ou programmer sa publication
- **US027** - En tant que recruteur, je veux suspendre ou supprimer une offre d'emploi

### Gestion des Candidatures
- **US028** - En tant que recruteur, je veux voir toutes les candidatures reçues pour mes offres
- **US029** - En tant que recruteur, je veux filtrer les candidatures par statut (nouvelle, en cours, acceptée, refusée)
- **US030** - En tant que recruteur, je veux consulter le profil détaillé d'un candidat
- **US031** - En tant que recruteur, je veux télécharger le CV d'un candidat
- **US032** - En tant que recruteur, je veux accepter ou refuser une candidature avec un message
- **US033** - En tant que recruteur, je veux marquer des candidats comme favoris

### Communication et Suivi
- **US034** - En tant que recruteur, je veux envoyer des messages aux candidats
- **US035** - En tant que recruteur, je veux programmer des entretiens avec les candidats
- **US036** - En tant que recruteur, je veux suivre le pipeline de recrutement par offre

### Analytics et Reporting
- **US037** - En tant que recruteur, je veux voir les statistiques de performance de mes offres
- **US038** - En tant que recruteur, je veux analyser l'origine du trafic de mes candidatures
- **US039** - En tant que recruteur, je veux exporter les données de candidatures

## 🔄 Distinction entre Types de Comptes

### Mécanisme de Différenciation

#### 1. **Inscription Différenciée**
- **Candidat** : Inscription via écran principal avec option "Create Your Account"
- **Employeur** : Inscription via option "Pro Access" avec processus de vérification entreprise

#### 2. **Workflows Spécifiques**
```
CANDIDAT                          EMPLOYEUR
├── Profil Personnel              ├── Profil Entreprise
├── Upload CV                     ├── Informations légales
├── Préférences Emploi            ├── Logo & Description
├── Recherche Offres              ├── Création Offres
├── Candidatures                  ├── Gestion Candidatures
└── Suivi Statuts                 └── Analytics
```

#### 3. **Interfaces Distinctes**
- **Navigation Candidat** : Home, Jobs, Applications, Profile
- **Navigation Employeur** : Dashboard, My Jobs, Candidates, Company Profile

#### 4. **Permissions et Accès**
```dart
// Exemple de logique de rôle
enum UserRole { candidate, employer, admin }

class UserPermissions {
  static bool canCreateJobs(UserRole role) => role == UserRole.employer;
  static bool canApplyToJobs(UserRole role) => role == UserRole.candidate;
  static bool canViewCandidateCV(UserRole role) => role == UserRole.employer;
}
```

#### 5. **Données Utilisateur Différentes**
```dart
// Candidat
class CandidateProfile {
  String firstName, lastName;
  String cv, portfolio;
  List<String> skills;
  ExperienceLevel experience;
  SalaryRange salaryExpectation;
}

// Employeur  
class EmployerProfile {
  String companyName, industry;
  String logo, description;
  int employeeCount;
  String website;
  List<JobListing> activeJobs;
}
```

## 🎨 Fonctionnalités Clés Implémentées

### ✅ Système de Design Global
- Couleurs, typographie et espacements centralisés
- Support du mode sombre et haut contraste
- Design responsive et accessible

### ✅ Authentification Sécurisée
- Inscription avec vérification email
- Validation en temps réel
- Support Firebase Auth

### ✅ Accessibilité Universelle
- Mode haut contraste
- Ajustement taille police
- Feedback vibration et visuel
- Support lecteurs d'écran

### ✅ Multilingue
- Support français/anglais
- Commutateur de langue intuitif
- Traductions contextuelle

### ✅ Recherche d'Emploi Avancée
- Filtres par catégorie
- Barre de recherche
- Recommandations personnalisées

## 🚀 Roadmap Technique

### Phase 1 - MVP ✅
- [x] Authentification utilisateur
- [x] Interface candidat basique
- [x] Recherche d'emploi
- [x] Accessibilité de base

### Phase 2 - Employeur (En cours)
- [ ] Interface employeur complète
- [ ] Gestion des offres d'emploi
- [ ] Analytics de base

### Phase 3 - Advanced Features
- [ ] Matching AI avancé
- [ ] Chat temps réel
- [ ] Notifications push
- [ ] API mobile

## 🎯 Métriques de Succès

### Candidats
- Taux de conversion inscription → première candidature : >40%
- Temps moyen de recherche d'emploi : <30 minutes
- Taux de satisfaction accessibilité : >85%

### Employeurs
- Temps moyen de création d'offre : <10 minutes  
- Qualité des candidatures reçues : >75%
- Taux d'utilisation analytics : >60%

### Techniques
- Performance app : <3s temps de chargement
- Accessibilité : Conformité WCAG 2.1 AA
- Disponibilité : >99.5% uptime

---

*Cette documentation évolue avec le développement de Timeless. Pour les dernières mises à jour, consultez le repository GitHub.*