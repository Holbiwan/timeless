# 🚀 Timeless  
Career Companion

---
<p align="center">
  <img src="https://zupimages.net/up/25/37/x2vb.png" alt="Timeless logo" width="300">
</p>

---


<h1 align="center"></h1>
<p align="center"><em>Digital job search for Europe — find, apply, and grow.</em></p>

<p align="center">
  <a href="https://flutter.dev"><img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white"></a>
  <a href="https://firebase.google.com"><img alt="Firebase" src="https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase&logoColor=black"></a>
  <img alt="Platform" src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white">
  <img alt="Status" src="https://img.shields.io/badge/Status-Demo%20Ready-4CAF50">
</p>

---

## Overview

**Timeless** is a mobile app built with **Flutter** that helps candidates discover **digital/tech jobs across Europe**.  
It focuses on fast search, clean UX, and simple onboarding (Google, GitHub, Email/Password, or **Guest Mode**).  
For presentations or low-connectivity scenarios, the app includes an **Offline Demo** that loads jobs from a local JSON file.

---

## Key Features

- 🔎 **Job Search & Browse**
  - Search by title, company, location; filter and sort results.
  - Save favorites for quick access.

- 👤 **Authentication**
  - Google, GitHub, Email/Password (via Firebase Auth).
  - **Guest Mode** (Anonymous sign-in) for instant demo access.
  - Optional **Offline Demo**: load jobs from `assets/jobs.json` (no network required).

- ☁️ **Data & Storage**
  - Firestore for user profiles, job data, and preferences.
  - (Optional) Firebase Storage for CV / attachments.

- 🛡️ **Privacy & Security**
  - Demo-friendly Firestore rules with guidance to harden for production.
  - Secrets kept out of Git via a strict `.gitignore`.

---

## Quick Start (Android)

### 1) Prerequisites
- Flutter **3.x** (stable), Android Studio (SDK & platform tools)
- A Firebase project

### 2) Clone & dependencies
```bash
git clone <your-repo-url> timeless
cd timeless

flutter pub get
