<h1 align="center">Timeless</h1>
<p align="center"><em>Because opportunities don’t wait...</em></p>


Timeless is a Flutter-based mobile job-search app powered by Firebase, designed for fast and accessible job applications. 
It provides an optimized job feed, intuitive navigation, and secure authentication, enabling candidates to apply anytime, anywhere. 


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


## 📸 Screenshots

A quick overview of the main user journey in **Timeless**.

### 🧭 Onboarding & Authentication
<p align="center">
  <img src="assets/screenshots/1-Splash.jpeg" width="170"/>
  <img src="assets/screenshots/2-ConnexionScreen.jpeg" width="170"/>
</p>


  ### 👤 Candidate Experience
<p align="center">
  <img src="assets/screenshots/6-Connexion%20CANDIDAT.jpeg" width="170"/>
   <img src="assets/screenshots/7-DashboardCANDIDAT.jpeg" width="170"/>
</p>


### 🏢 Employer Experience (PRO)
<p align="center">
  <img src="assets/screenshots/4-ConnexionPRO.jpeg" width="170"/>
  <img src="assets/screenshots/5-DashboardPRO.png" width="170"/>
</p>


## 🎬 Demo Video

▶️ **Watch the demo of the Timeless mobile application**

👉 [Click here to download and watch the demo video](https://github.com/Holbiwan/timeless/releases/download/v1.0-demo/Timeless.demo.mp4)

> This demo presents the main user journeys for candidates and employers.  
> This is a school and portfolio project using fictitious data.



##  Project Structure

```bash
timeless/
├── android/              # Android specific configuration
├── ios/                  # iOS specific configuration
├── macos/                # macOS specific configuration
├── web/                  # Web platform configuration
├── assets/               # Application assets
│   ├── cv/               # Demo CV files
│   ├── icons/            # Application icons
│   ├── images/           # Images and logos
│   ├── screenshots/      # App screenshots for documentation
│   ├── translations/     # i18n JSON files (en, fr, es)
│   └── jobs.json         # Demo job data
├── lib/                  # Main Flutter application source code
│   ├── api/              # API clients and data services
│   ├── common/           # Reusable UI widgets
│   ├── config/           # App configuration (API config, themes, constants)
│   ├── controllers/      # GetX controllers for state management
│   ├── models/           # Data models (Job, User, Application, etc.)
│   ├── screen/           # Application screens
│   │   ├── auth/         # Authentication screens
│   │   ├── candidate/    # Candidate-specific screens
│   │   ├── employer/     # Employer-specific screens
│   │   ├── dashboard/    # Dashboard screens
│   │   ├── profile/      # User profile screens
│   │   └── ...           # Other feature screens
│   ├── services/         # Core services (Auth, Notifications, Jobs, etc.)
│   ├── utils/            # Helper functions, formatters, and utilities
│   ├── widgets/          # Shared widgets
│   └── main.dart         # Application entry point
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

## 🧪 Testing

The project includes **7 unit tests** covering the main data models.

**Run all tests:**
```bash
flutter test
```

**Test coverage:**
- ✅ JobOfferModel (4 tests): creation, display formatting, salary, copyWith
- ✅ UserModel (3 tests): creation, display name, saved jobs management

See [test/README.md](test/README.md) for detailed test documentation.

## 📜 License

This project is licensed under the MIT License.
