# Dossier Tests

## Structure
- `scripts/` - Scripts d'installation et de validation
- `test_*.sh` - Scripts de test des services

## Scripts disponibles

### Scripts de test des services
- `test_comprehensive_fixes.sh` - Test du service de traduction
- `test_fixes.sh` - Test des corrections
- `test_installation.sh` - Test de l'installation
- `test_theme_service_fix.sh` - Test du service de thème

### Scripts utilitaires
- `check_errors.sh` - Vérification des erreurs
- `deploy_firebase.sh` - Déploiement Firebase  
- `final_validation.sh` - Validation finale

## Utilisation
```bash
cd tests
chmod +x *.sh scripts/*.sh
./test_installation.sh
```
