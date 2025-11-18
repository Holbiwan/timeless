# 🗄️ DATABASE DESIGN - Code pour dbdiagram.io

## 📝 Instructions
1. Va sur **https://dbdiagram.io/**
2. Crée un compte gratuit
3. Copy/paste le code ci-dessous
4. Exporte en PNG/PDF haute qualité

---

## 💾 Code DBML pour Timeless Database

```dbml
Project Timeless {
  database_type: 'Firestore NoSQL'
  Note: 'Job Search App - Firebase Database Schema'
}

// ===== USERS COLLECTION =====
Table users {
  uid string [primary key, note: 'Firebase User ID']
  email string [not null]
  fullName string
  photoURL string
  provider string [note: 'google|email|github']
  createdAt timestamp
  
  // Profile Details
  phone string
  city string
  state string
  country string
  occupation string
  bio text
  dateOfBirth string
  address text
  
  // Smart Match Data
  skillsList json [note: 'Array of skills']
  experienceLevel string [note: 'Junior|Intermediate|Senior']
  salaryRangeMin integer
  salaryRangeMax integer
  
  // Settings
  isActive boolean [default: true]
  lastLoginAt timestamp
  
  Note: 'Collection: Auth/User/register/{uid}'
}

// ===== JOBS COLLECTION =====
Table jobs {
  jobId string [primary key, note: 'Auto-generated Document ID']
  position string [not null]
  companyName string [not null]
  location string
  type string [note: 'CDI|CDD|Stage|Freelance']
  salary string
  
  // Job Details
  jobDescription text
  jobCategory string [note: 'Design|UX|Software|Data']
  requirementsList json [note: 'Array of requirements']
  
  // Metadata
  managerId string [ref: > users.uid]
  deviceToken string
  postedAt timestamp [not null]
  isActive boolean [default: true]
  
  // Engagement
  bookMarkUserList json [note: 'Array of user IDs']
  viewCount integer [default: 0]
  applicationCount integer [default: 0]
  
  Note: 'Collection: allPost/{jobId}'
}

// ===== APPLICATIONS COLLECTION =====
Table applications {
  applicationId string [primary key]
  userId string [ref: > users.uid, not null]
  jobId string [ref: > jobs.jobId, not null]
  
  // Application Data
  cvUrl string
  coverLetter text
  
  // Status Tracking
  status string [note: 'pending|accepted|rejected|reviewed']
  appliedAt timestamp [not null]
  reviewedAt timestamp
  
  // Manager Feedback
  managerFeedback text
  managerId string [ref: > users.uid]
  
  // Matching Score
  matchScore float [note: 'AI calculated compatibility 0-100']
  
  Note: 'Collection: applications/{applicationId}'
}

// ===== NOTIFICATIONS COLLECTION =====
Table notifications {
  notificationId string [primary key]
  userId string [ref: > users.uid, not null]
  
  // Notification Content
  title string [not null]
  message text [not null]
  type string [note: 'job_match|application_update|system|promotion']
  
  // Metadata
  createdAt timestamp [not null]
  isRead boolean [default: false]
  actionUrl string
  
  // Related Data
  relatedJobId string [ref: > jobs.jobId]
  relatedApplicationId string [ref: > applications.applicationId]
  
  Note: 'Collection: notifications/{notificationId}'
}

// ===== BOOKMARKS COLLECTION =====
Table bookmarks {
  bookmarkId string [primary key]
  userId string [ref: > users.uid, not null]
  jobId string [ref: > jobs.jobId, not null]
  bookmarkedAt timestamp [not null]
  
  Note: 'Collection: bookmarks/{bookmarkId}'
}

// ===== DEMO DATA COLLECTION =====
Table demo_data {
  demoId string [primary key]
  type string [note: 'jobs|users|applications']
  isActive boolean [default: true]
  createdAt timestamp
  
  Note: 'Demo data for junior certification'
}

// ===== RELATIONSHIPS =====
Ref: jobs.managerId > users.uid [note: "Manager posts jobs"]
Ref: applications.userId > users.uid [note: "User applies to jobs"]
Ref: applications.jobId > jobs.jobId [note: "Application for specific job"]
Ref: applications.managerId > users.uid [note: "Manager reviews application"]
Ref: notifications.userId > users.uid [note: "User receives notifications"]
Ref: notifications.relatedJobId > jobs.jobId [note: "Notification about job"]
Ref: notifications.relatedApplicationId > applications.applicationId [note: "Notification about application"]
Ref: bookmarks.userId > users.uid [note: "User bookmarks jobs"]
Ref: bookmarks.jobId > jobs.jobId [note: "Job can be bookmarked"]
```

---

## 🎨 Style personnalisé (Optionnel)

Ajoute ce code CSS à la fin pour un style pro :

```css
// Styling
Table users {
  color: "#2196F3"
  header_color: "#1976D2"
}

Table jobs {
  color: "#4CAF50" 
  header_color: "#388E3C"
}

Table applications {
  color: "#FF9800"
  header_color: "#F57C00"
}

Table notifications {
  color: "#9C27B0"
  header_color: "#7B1FA2"
}

Table bookmarks {
  color: "#607D8B"
  header_color: "#455A64"
}
```

---

## 📊 Résultat attendu

Tu auras un diagramme professionnel avec :
- ✅ **5 tables principales** avec toutes les relations
- ✅ **Types de données** clairement définis
- ✅ **Relations visuelles** entre collections
- ✅ **Notes explicatives** pour chaque champ
- ✅ **Couleurs différentiées** par table
- ✅ **Export haute qualité** pour présentation

## 🔧 Instructions d'export

1. Clique sur **"Export"** en haut à droite
2. Choisis **"PNG"** ou **"PDF"** 
3. Résolution : **"High Quality"**
4. Intègre dans tes slides de présentation

Le résultat sera parfait pour impressionner les professionnels ! 🚀