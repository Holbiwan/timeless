# Tests Unitaires - Timeless

Ce dossier contient les tests unitaires pour les modèles de données de l'application Timeless.

## Structure des Tests

```
test/
├── README.md
└── models/
    ├── job_offer_model_test.dart   # Tests du modèle JobOfferModel (4 tests)
    └── user_model_test.dart        # Tests du modèle UserModel (3 tests)
```

## Tests Implémentés

### JobOfferModel (4 tests)

1. **Création d'une offre d'emploi**
   - Vérifie qu'on peut créer une offre d'emploi avec toutes les informations de base

2. **Affichage du type de contrat**
   - Vérifie que le type de contrat s'affiche correctement (Full-time, Part-time, etc.)

3. **Affichage du salaire**
   - Vérifie que le salaire est formaté correctement (ex: "40000€ - 50000€")

4. **Modification d'une offre avec copyWith**
   - Vérifie qu'on peut modifier une offre existante sans affecter les autres champs

### UserModel (3 tests)

1. **Création d'un utilisateur**
   - Vérifie qu'on peut créer un profil utilisateur complet

2. **Affichage du nom complet**
   - Vérifie que le nom complet s'affiche correctement

3. **Gestion des jobs sauvegardés**
   - Vérifie qu'on peut sauvegarder des offres d'emploi dans le profil utilisateur

## Exécution des Tests

### Tous les tests
```bash
flutter test
```

### Un fichier spécifique
```bash
flutter test test/models/job_offer_model_test.dart
flutter test test/models/user_model_test.dart
```

## Résultat Attendu

Lorsque vous exécutez `flutter test`, vous devriez voir :

```
00:02 +7: All tests passed!
```

Cela signifie que les 7 tests (4 + 3) ont réussi.

## Notes

- Les tests sont volontairement simples et faciles à comprendre
- Chaque test a des commentaires en français pour expliquer ce qu'il fait
- Les tests couvrent les fonctionnalités de base des modèles de données
- Pas de mocking Firebase nécessaire pour ces tests unitaires
