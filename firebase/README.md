# Firebase Configuration - Timeless

This folder contains all Firebase configuration files for the Timeless project.

## 📁 Structure

- `firebase.json` - Main Firebase configuration
- `firestore.rules` - Firestore Security Rules
- `firestore.backend.rules` - Firestore Backend Rules (backup)
- `firestore.indexes.json` - Firestore Indexes

## 🔧 Usage

### Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### Deploy Indexes
```bash
firebase deploy --only firestore:indexes
```

### Full Deployment
```bash
firebase deploy
```

## 📝 Notes
- The main rules are in `firestore.rules`
- The `firebase.json` file is configured to point to this folder
- Development configurations are in `lib/firebase_options.dart`