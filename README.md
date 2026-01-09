<h1 align="center">Timeless</h1>
<p align="center"><em>Because opportunities don’t wait...</em></p>


Timeless is a mobile app developed with Flutter that allows candidates to view and apply for job offers directly from their phone, anytime, anywhere. Its name reflects the idea of a timeless flow of job offers: ads that are accessible at any time, without constraints. 
Timeless emphasizes speed, clarity, and a smooth user experience. It offers an optimized job search feed, intuitive navigation, and simple registration via Google or email/password. Powered by Firebase, the app manages user profiles, saved jobs, and applications. 
Timeless makes job hunting easier, faster, and always available, because opportunities shouldn't be limited by time. 


<p align="center">
  <img src="https://i.postimg.cc/tgfXWsFY/logo.png" alt="Timeless logo" width="270">
  &nbsp;&nbsp;&nbsp;
 </p>

<p align="center"><small><em>See landing page by clicking below</em></small></p>
<p align="center">
  <a href="https://holbiwan.github.io/timeless-landing/">
    <a href="https://holbiwan.github.io/timeless-landing/">
  <img alt="Landing Page" src="https://img.shields.io/badge/Click%20to%20visit%20the%20landing%20page%20now-02569B?style=for-the-badge&logo=web&logoColor=white">
</a>

  </a>
</p>

<p align="center">
  <a href="https://flutter.dev"><img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white"></a>
  <a href="https://firebase.google.com"><img alt="Firebase" src="https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase&logoColor=black"></a>
  <img alt="Platform" src="https://img.shields.io/badge/Platform-Android-02569B?logo=android&logoColor=white">
  <img alt="Status" src="https://img.shields.io/badge/Status-Demo%20Day-FFCA28?logoColor=black">
</p>


## 📸 Application Screens & User Journey

Below is an overview of the main user flows in the **Timeless** mobile application, illustrating both **candidate** and **employer** experiences.


### 🧭 Onboarding & Authentication

| Welcome Screen | Candidate Login |
|----------------|-----------------|
| <img src="assets/screenshots/01_welcome.png" width="300"/> | <img src="assets/screenshots/02_candidate_login.png" width="300"/> |

| Employer Login | Social Authentication |
|----------------|----------------------|
| <img src="assets/screenshots/03_employer_login.png" width="300"/> | <img src="assets/screenshots/04_auth_social.png" width="300"/> |

---

### 👤 Candidate Experience

| Dashboard | Browse Jobs |
|----------|-------------|
| <img src="assets/screenshots/05_candidate_dashboard.png" width="300"/> | <img src="assets/screenshots/06_browse_jobs.png" width="300"/> |

| Job Fairs & Events | Settings & Accessibility |
|------------------|--------------------------|
| <img src="assets/screenshots/07_job_fairs.png" width="300"/> | <img src="assets/screenshots/08_settings.png" width="300"/> |

---

### 🏢 Employer Experience

| Employer Dashboard | Post & Manage Jobs |
|-------------------|--------------------|
| <img src="assets/screenshots/09_employer_dashboard.png" width="300"/> | <img src="assets/screenshots/10_post_job.png" width="300"/> |

> Timeless provides distinct user journeys for candidates and employers, with secure authentication, intuitive dashboards, and job management features.

---
## 🎬 Demo

<p align="center">
  <em>A video demonstration of the application will be available here shortly.</em>
</p>

##  Project Structure

```bash
timeless/
├── android/              # Android specific configuration
├── ios/                  # iOS specific configuration
├── assets/               # Images, icons, translations, and demo data
├── lib/                  # Main Flutter application source code
│   ├── api/              # API clients and data services
│   ├── common/           # Reusable UI widgets
│   ├── config/           # App configuration (themes, constants, etc.)
│   ├── controllers/      # GetX controllers for state management
│   ├── models/           # Data models (Job, User, etc.)
│   ├── screen/           # Application screens (Authentication, Job List, etc.)
│   ├── services/         # Core services (Notifications, API, Storage)
│   ├── utils/            # Helper functions, formatters, and utilities
│   └── main.dart         # Application entry point
├── backend/              # Node.js / Express backend API
├── firebase/             # Firestore rules and indexes
└── tests/                # Flutter unit and widget tests
```

##  Tech Stack

### Mobile App

| Feature                  | Technology/Service                |
|--------------------------|-----------------------------------|
| Framework                | Flutter (Dart)                    |
| State Management         | GetX                              |
| Platform Support         | Android & iOS                     |
| Authentication           | Firebase Auth                     |
| Database                 | Firestore                         |
| Storage                  | Firebase Storage                  |
| Local Storage            | SharedPreferences                 |
| Notifications            | Firebase Cloud Messaging (FCM)    |

### Backend (`/backend`)

| Feature                  | Technology/Service                |
|--------------------------|-----------------------------------|
| Framework                | Node.js / Express                 |
| Database                 | MongoDB (with Mongoose)           |
| Authentication           | JWT (JSON Web Tokens)             |
| File Uploads             | Multer + Cloudinary               |
| Social Login             | Google OAuth (Passport)           |
| API Documentation        | Swagger                           |
| Testing                  | Jest + Supertest                  |

## Features Overview

| Feature / Service        | Purpose                                       |
|--------------------------|-----------------------------------------------|
| 🔐 **Firebase Auth**     | Handles user login via email and social providers (WIP). |
| 📊 **Firestore**         | Stores job offers, user profiles, and applications. |
| 📁 **Firebase Storage**  | Manages CV uploads and profile pictures.     |
| 🔔 **Notifications**     | Sends real-time alerts for jobs and updates.  |
| 💾 **SharedPreferences** | Saves local settings and authentication tokens. |
| 🌍 **Translations**      | Supports multiple languages using JSON files in `/assets/translations`. |

## 🚧 Installation & Run

1. **Clone the repository:**

    ```bash
    git clone https://github.com/your-account/timeless.git
    ```

2. **Navigate to the project directory:**

    ```bash
    cd timeless
    ```

3. **Install Flutter dependencies:**

    ```bash
    flutter pub get
    ```

4. **Run the application:**

    ```bash
    flutter run
    ```

⚠️ **Note:** Firebase configuration files (`google-services.json`, `GoogleService-Info.plist`, and `firebase_options.dart`) are not included in the repository for security reasons. You will need to set up your own Firebase project and add the configuration files to the appropriate locations (`android/app`, `ios/Runner`, and `lib/` respectively).

## 📜 License

This project is licensed under the MIT License.
