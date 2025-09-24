@echo off
echo 🚀 Test de l'application...

echo 📱 Verification des appareils connectes...
flutter devices

echo 🔧 Lancement de l'app...
flutter run --device-id emulator-5554

pause