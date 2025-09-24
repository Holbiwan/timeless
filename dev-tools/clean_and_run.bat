@echo off
echo 🧹 Nettoyage complet Facebook...

echo Suppression des caches...
if exist .dart_tool rmdir /s /q .dart_tool
if exist build rmdir /s /q build
if exist pubspec.lock del pubspec.lock

echo 📦 Installation des dependances...
flutter pub get

echo 🚀 Lancement de l'app...
flutter run

pause