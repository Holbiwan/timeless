## Timeless – Application Architecture  

## Project Structure (main folders)

```text
timeless/
├── android/         # Android settings
├── ios/             # iOS settings
├── assets/          # Images, icons, demo data
├── lib/             # Main app code
│   ├── api/         # Data services
│   ├── common/      # Reusable widgets
│   ├── screen/      # App screens
│   ├── service/     # Features (auth, storage…)
│   ├── utils/       # Helpers, constants
│   └── main.dart    # Entry point
├── test/            # Tests
└── web/             # Web settings


```
## 📱 Main Features
```

| Section            | Description                                        |
|--------------------|----------------------------------------------------|
| **Authentication** | Sign in, sign up, forgot password                  |
| **Dashboard**      | Home, job offers, applications                     |
| **Job Details**    | View jobs, upload CV, application result screens   |
| **Manager Section**| Post jobs, view applicants, notifications          |
| **Profile**        | View and edit user profile                         |


```
## 🔐 Authentication Flow
```


Onboarding
↓
Choose login method
• Google
• Email & Password
• Guest mode
↓
Role detection
• Job seeker → Dashboard
• Employer → Manager Dashboard



```
## 🗄️ Data & Services
```

| Service                  | Purpose                          |
|---------------------------|----------------------------------|
| **Firebase Auth**         | Login / Signup                   |
| **Firestore**             | Job data, profiles, applications |
| **Firebase Storage**      | CVs and profile pictures          |
| **Push Notifications**    | Alerts and updates               |
| **SharedPreferences**     | Local settings and tokens        |

---

```
## 🎨 UI / UX
```

- Material Design (Flutter)
- Centralized colors and styles (`/lib/utils/`)
- Reusable widgets (`/lib/common/widgets/`)
- Accessibility: larger fonts, high contrast, voice support



```
## 🚀 Navigation
```

App
├── Splash
├── Onboarding
├── Authentication
│ ├── Sign In
│ ├── Sign Up
│ └── Password Reset
└── Main
├── Dashboard (Job Seeker)
└── Manager Dashboard (Employer)


```
## 🧪 Testing
```

| Test type          | Purpose                   |
|--------------------|---------------------------|
| **Unit Tests**     | Check business logic      |
| **Widget Tests**   | Check UI components       |
| **Integration**    | End-to-end workflows      |



```
## 📦 Key Dependencies
```

| Package              | Role                        |
|----------------------|-----------------------------|
| **flutter**          | UI framework                |
| **get**              | State management, navigation|
| **firebase_core**    | Firebase init               |
| **firebase_auth**    | Authentication              |
| **cloud_firestore**  | Database                    |
| **shared_preferences** | Local storage             |
| **google_fonts**     | Typography                  |

---
