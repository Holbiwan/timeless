# Configuration Firebase - Timeless

Ce dossier contient tous les fichiers de configuration Firebase pour le projet Timeless.

## 📁 Structure

- `firebase.json` - Configuration principale Firebase
- `firestore.rules` - Règles de sécurité Firestore (production)
- `firestore.backend.rules` - Règles Firestore du backend (backup)
- `firestore.indexes.json` - Index Firestore

## 🔧 Utilisation

### Déploiement des règles Firestore
```bash
firebase deploy --only firestore:rules
```

### Déploiement des index
```bash
firebase deploy --only firestore:indexes
```

### Déploiement complet
```bash
firebase deploy
```

## 📝 Notes
- Les règles principales sont dans `firestore.rules`
- Le fichier `firebase.json` est configuré pour pointer vers ce dossier
- Les configurations de développement sont dans `lib/firebase_options.dart`