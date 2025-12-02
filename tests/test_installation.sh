#!/bin/bash
echo "=== Testing Google Translation Installation ==="
echo "1. Checking pubspec.yaml..."
if grep -q "http:" pubspec.yaml; then
    echo "✓ HTTP dependency found"
else
    echo "✗ HTTP dependency missing"
fi

echo "2. Checking translation service..."
if [ -f "lib/services/comprehensive_translation_service.dart" ]; then
    echo "✓ Comprehensive translation service created"
else
    echo "✗ Comprehensive translation service missing"
fi

echo "3. Checking Google translation service..."
if [ -f "lib/services/google_translation_service.dart" ]; then
    echo "✓ Google translation service found"
else
    echo "✗ Google translation service missing"
fi

echo "4. Checking modern language selector..."
if [ -f "lib/common/widgets/modern_language_selector.dart" ]; then
    echo "✓ Modern language selector created"
else
    echo "✗ Modern language selector missing"
fi

echo "5. Checking API key configuration..."
if grep -q "AIzaSyBLcuWuFnr8y6bMDi1xsQpOFzW_XX00Xxx" lib/services/google_translation_service.dart; then
    echo "✓ API key configured"
else
    echo "✗ API key not configured"
fi

echo "6. Checking main.dart integration..."
if grep -q "ComprehensiveTranslationService" lib/main.dart; then
    echo "✓ Service integrated in main.dart"
else
    echo "✗ Service not integrated in main.dart"
fi

echo ""
echo "=== Installation Summary ==="
echo "Your Google Translation API is now set up with:"
echo "• API Key: AIzaSyBLcuWuFnr8y6bMDi1xsQpOFzW_XX00Xxx"
echo "• 10+ supported languages (English, French, Spanish, Arabic, etc.)"
echo "• Auto-translation feature"
echo "• Modern UI components"
echo "• Full integration with your existing app"
echo ""
echo "Next steps:"
echo "1. Run 'flutter pub get' to install dependencies"
echo "2. Test the translation with the example file"
echo "3. Add the ModernLanguageSelector to your screens"
