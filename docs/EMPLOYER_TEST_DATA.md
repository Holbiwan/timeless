# 🏢 Données de Test - Comptes Employeurs

## 📋 Informations importantes

- Toutes ces données sont **fictives** et **cohérentes** entre elles
- Les codes SIRET et APE sont validés automatiquement
- Les entreprises correspondent aux offres d'emplois déjà créées

---

## 🎯 Comptes employeurs à tester

### 1. **TechCorp Solutions** (Informatique)
```
📧 Email: contact@techcorp-solutions.fr
🔐 Mot de passe: TechCorp2024!
👤 Prénom: Jean
👤 Nom: Dubois
📞 Téléphone: +33 1 23 45 67 89
🏙️ Ville: Paris
🏴󠁦󠁲󠁩󠁤󠁦󠁿 Région: Île-de-France
🌍 Pays: France
🏢 Nom entreprise: TechCorp Solutions
🔍 SIRET: 12345678901234
📋 Code APE: 6201Z (Programmation informatique)
```

### 2. **DataFlow Analytics** (Data & Analytics)
```
📧 Email: rh@dataflow-analytics.fr
🔐 Mot de passe: DataFlow2024!
👤 Prénom: Marie
👤 Nom: Martin
📞 Téléphone: +33 4 56 78 90 12
🏙️ Ville: Lyon
🏴󠁦󠁲󠁡󠁵󠁲󠁡󠁿 Région: Auvergne-Rhône-Alpes
🌍 Pays: France
🏢 Nom entreprise: DataFlow Analytics
🔍 SIRET: 98765432109876
📋 Code APE: 6202A (Conseil en systèmes et logiciels informatiques)
```

### 3. **SecurNet Technologies** (Cybersécurité)
```
📧 Email: recrutement@securnet-tech.fr
🔐 Mot de passe: SecurNet2024!
👤 Prénom: Pierre
👤 Nom: Leroy
📞 Téléphone: +33 1 34 56 78 90
🏙️ Ville: Paris
🏴󠁦󠁲󠁩󠁤󠁦󠁿 Région: Île-de-France
🌍 Pays: France
🏢 Nom entreprise: SecurNet Technologies
🔍 SIRET: 11223344556677
📋 Code APE: 6209Z (Autres activités informatiques)
```

### 4. **UX Design Studio** (Design UX/UI)
```
📧 Email: hello@uxdesign-studio.fr
🔐 Mot de passe: UXStudio2024!
👤 Prénom: Sophie
👤 Nom: Durand
📞 Téléphone: +33 1 45 67 89 01
🏙️ Ville: Paris
🏴󠁦󠁲󠁩󠁤󠁦󠁿 Région: Île-de-France
🌍 Pays: France
🏢 Nom entreprise: UX Design Studio
🔍 SIRET: 99887766554433
📋 Code APE: 7410Z (Activités spécialisées de design)
```

### 5. **CloudDataWorks** (Data Engineering)
```
📧 Email: careers@clouddataworks.fr
🔐 Mot de passe: CloudData2024!
👤 Prénom: Thomas
👤 Nom: Bernard
📞 Téléphone: +33 4 93 12 34 56
🏙️ Ville: Cannes
🏴󠁦󠁲󠁰󠁡󠁣󠁡󠁿 Région: Provence-Alpes-Côte d'Azur
🌍 Pays: France
🏢 Nom entreprise: CloudDataWorks
🔍 SIRET: 55667788990011
📋 Code APE: 6201Z (Programmation informatique)
```

---

## 🧪 Instructions de test

### Étape 1 : Créer un compte employeur
1. Aller à l'écran d'inscription employeur (`SignUpScreenM`)
2. Utiliser **l'une des données ci-dessus**
3. Remplir tous les champs obligatoires
4. Le SIRET sera automatiquement validé et les infos entreprise pré-remplies

### Étape 2 : Vérifications attendues
✅ **Validation SIRET** : Le système doit reconnaître le SIRET et afficher les infos entreprise  
✅ **Popup de confirmation** : Un popup détaillé doit s'afficher avec toutes les infos  
✅ **Sauvegarde Firestore** : Les données doivent être sauvegardées dans la collection `employers`  
✅ **Redirection** : L'utilisateur doit être redirigé vers le dashboard employeur  

### Étape 3 : Test de connexion
1. Se déconnecter
2. Se reconnecter avec l'email et mot de passe
3. Ou utiliser la connexion par SIRET (`EmployerSiretSignInScreen`)
4. Ou utiliser la connexion par APE (`EmployerApeSignInScreen`)

---

## 📄 Structure Firestore

Les données sont sauvegardées dans la collection `employers` avec cette structure :

```json
{
  "uid": "firebase-auth-uid",
  "email": "contact@example.fr",
  "firstName": "Jean",
  "lastName": "Dubois",
  "displayName": "Jean Dubois",
  "phone": "+33 1 23 45 67 89",
  "city": "Paris",
  "state": "Île-de-France", 
  "country": "France",
  "companyName": "TechCorp Solutions",
  "siretCode": "12345678901234",
  "apeCode": "6201Z",
  "companyInfo": {
    "siret": "12345678901234",
    "denomination": "TechCorp Solutions",
    "activitePrincipaleUniteLegale": "6201Z",
    "activitePrincipaleLibelle": "Programmation informatique",
    "adresse": "123 Avenue des Champs-Élysées 75008 Paris",
    "secteur": "Informatique",
    "effectif": "50-99",
    "created": "2020-03-15"
  },
  "accountType": "employer",
  "isVerified": true,
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp",
  "status": "active",
  "rememberMe": false
}
```

---

## 🔗 Cohérence avec les offres d'emploi

Ces entreprises correspondent aux offres d'emploi déjà créées :
- **CloudDataWorks** → Offre "Data Engineer" à Cannes
- **TechCorp Solutions** → Peut créer des offres en informatique
- **UX Design Studio** → Peut créer des offres en UX/UI
- **SecurNet Technologies** → Peut créer des offres en sécurité

---

## ⚠️ Notes importantes

1. **Mots de passe** : Respectent les exigences de sécurité (6+ caractères, majuscules, chiffres)
2. **SIRET fictifs** : Fonctionnent uniquement dans l'environnement de développement
3. **Emails fictifs** : N'existent pas réellement, uniquement pour les tests
4. **Données personnelles** : Toutes fictives, aucune donnée réelle utilisée

---

## 🚀 Prêt pour les tests !

Utilisez ces données pour tester complètement le système d'inscription employeur avec validation SIRET/APE et synchronisation Firestore.