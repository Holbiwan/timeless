# 🗄️ TIMELESS DATABASE - Basé sur ton modèle

## 📝 Instructions pour dbdiagram.io
1. Va sur **https://dbdiagram.io/**
2. Crée un compte gratuit
3. Copy/paste le code ci-dessous
4. Exporte en PNG/PDF haute qualité

---

## 💾 Code DBML adapté à ton modèle

```dbml
Project Timeless_Database {
  database_type: 'Firestore NoSQL'
  Note: 'Job Search App - Professional Database Design'
}

// ===== USERS TABLE =====
Table USERS {
  uid string [primary key, note: 'Firebase User ID']
  email string [not null, unique]
  fullName string [not null]
  skills json [note: 'Array of user skills']
  experience string [note: 'Junior|Intermediate|Senior']
  salaryRange string [note: 'Min-Max salary expectation']
  location string [note: 'User preferred location']
  
  // Metadata
  createdAt timestamp [default: `now()`]
  updatedAt timestamp
  isActive boolean [default: true]
  
  Note: 'Collection: Auth/User/register/{uid}'
}

// ===== JOBS TABLE =====
Table JOBS {
  jobId string [primary key, note: 'Auto-generated Document ID']
  position string [not null]
  company string [not null]
  location string [not null]
  salary string
  requirements json [note: 'Array of job requirements']
  
  // Additional job details
  jobType string [note: 'CDI|CDD|Stage|Freelance']
  postedAt timestamp [default: `now()`]
  isActive boolean [default: true]
  managerId string [note: 'Reference to posting manager']
  
  Note: 'Collection: allPost/{jobId}'
}

// ===== APPLICATIONS TABLE =====
Table APPLICATIONS {
  applicationId string [primary key, note: 'Auto-generated ID']
  userId string [ref: > USERS.uid, not null]
  jobId string [ref: > JOBS.jobId, not null]
  status string [note: 'pending|accepted|rejected|reviewed']
  appliedAt timestamp [default: `now()`, not null]
  
  // Application details
  cvUrl string
  coverLetter text
  reviewedAt timestamp
  managerFeedback text
  
  Note: 'Collection: applications/{applicationId}'
}

// ===== NOTIFICATIONS TABLE =====
Table NOTIFICATIONS {
  notificationId string [primary key, note: 'Auto-generated ID']
  userId string [ref: > USERS.uid, not null]
  message text [not null]
  timestamp timestamp [default: `now()`, not null]
  
  // Notification details
  title string [not null]
  type string [note: 'job_match|application_update|system']
  isRead boolean [default: false]
  actionUrl string
  
  // Related references
  relatedJobId string [ref: > JOBS.jobId]
  relatedApplicationId string [ref: > APPLICATIONS.applicationId]
  
  Note: 'Collection: notifications/{notificationId}'
}

// ===== RELATIONSHIPS (Comme dans ton modèle) =====

// User applies to jobs
Ref: APPLICATIONS.userId > USERS.uid [note: "User applies to jobs"]

// Applications reference jobs  
Ref: APPLICATIONS.jobId > JOBS.jobId [note: "Application for specific job"]

// User receives notifications
Ref: NOTIFICATIONS.userId > USERS.uid [note: "User receives notifications"]

// Notifications can reference jobs
Ref: NOTIFICATIONS.relatedJobId > JOBS.jobId [note: "Notification about job"]

// Notifications can reference applications
Ref: NOTIFICATIONS.relatedApplicationId > APPLICATIONS.applicationId [note: "Notification about application"]
```

---

## 🎨 Style professionnel (Ajoute à la fin)

```css
// Professional Color Scheme
Table USERS {
  color: "#2196F3"
  header_color: "#1976D2"
}

Table JOBS {
  color: "#4CAF50" 
  header_color: "#388E3C"
}

Table APPLICATIONS {
  color: "#FF9800"
  header_color: "#F57C00"
}

Table NOTIFICATIONS {
  color: "#9C27B0"
  header_color: "#7B1FA2"
}

// Relationship styling
Ref {
  color: "#607D8B"
}
```

---

## 📊 Résultat final

Ton diagramme aura :

✅ **4 tables principales** exactement comme ton modèle
✅ **Relations visuelles** : applies, receives, referenced in
✅ **Champs principaux** : uid, email, skills[], jobId, status, etc.
✅ **Style professionnel** avec couleurs coordonnées
✅ **Notes explicatives** pour chaque table
✅ **Export haute qualité** pour ta présentation

## 🔧 Personnalisation supplémentaire

Si tu veux modifier :
- **Couleurs** : Change les codes hex dans la section CSS
- **Champs** : Ajoute/supprime des lignes dans les tables
- **Relations** : Modifie les `Ref:` selon tes besoins
- **Notes** : Personnalise les descriptions

## 🚀 Next Steps

1. Copy/paste ce code dans dbdiagram.io
2. Ajuste si nécessaire selon tes préférences
3. Exporte en PNG haute résolution
4. Intègre dans tes slides de présentation

Le design sera parfaitement professionnel et fidèle à ton modèle original ! 