#!/bin/bash
echo "🧹 Cleaning Flutter project..."

echo "📦 Running flutter clean..."
flutter clean

echo "🔄 Getting dependencies..."
flutter pub get

echo "📱 Running flutter analyze..."
flutter analyze

echo "✅ Project cleaned successfully!"
echo "Now you can run: flutter run"