@echo off
echo 🧹 Cleaning Flutter project...

echo 📦 Running flutter clean...
flutter clean

echo 🔄 Getting dependencies...
flutter pub get

echo ✅ Project cleaned successfully!
echo Now you can run: flutter run

pause