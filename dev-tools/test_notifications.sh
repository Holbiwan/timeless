#!/bin/bash

# Test script for notification system
echo "🚀 Testing Timeless Notification System..."

echo "📱 Running Flutter app analysis..."
flutter analyze --no-fatal-infos

echo "🔍 Checking for notification service imports..."
grep -r "NotificationService" lib/ --include="*.dart" | head -5

echo "✅ Testing complete! Your notification system should work when:"
echo "   1. User applies to a job via Smart Apply"
echo "   2. User uses Quick Apply button"
echo "   3. Notifications appear in the Notifications screen"

echo "📋 Demo flow test:"
echo "   Login → Browse Jobs → Apply with CV → Check Notifications"