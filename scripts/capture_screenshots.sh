#!/bin/bash

# Create screenshots directory
mkdir -p screenshots

echo "🚀 Starting screenshot capture process..."
echo "📱 Make sure your device/emulator is connected and the app is running"
echo ""

# Function to take screenshot with ADB
take_screenshot() {
    local name=$1
    local description=$2
    
    echo "📸 Capturing: $description"
    echo "   - Please navigate to the $description screen"
    echo "   - Press ENTER when ready..."
    read
    
    # Take screenshot using ADB
    adb shell screencap -p /sdcard/screenshot_temp.png
    adb pull /sdcard/screenshot_temp.png screenshots/${name}.png
    adb shell rm /sdcard/screenshot_temp.png
    
    if [ -f "screenshots/${name}.png" ]; then
        echo "   ✅ Screenshot saved: ${name}.png"
    else
        echo "   ❌ Failed to capture screenshot"
    fi
    echo ""
}

# List of screens to capture
echo "We'll capture screenshots for the following screens:"
echo "1. Splash Screen"
echo "2. Introduction/Onboarding"
echo "3. Sign In Screen" 
echo "4. Sign Up Screen"
echo "5. Dashboard Home"
echo "6. Job Search/Browse"
echo "7. Job Detail"
echo "8. User Profile"
echo "9. My Applications"
echo "10. Chat Screen"
echo "11. Smart Apply"
echo "12. Manager Dashboard"
echo ""

# Capture each screen
take_screenshot "01_splash_screen" "Splash Screen"
take_screenshot "02_introduction_screen" "Introduction/Onboarding Screen"
take_screenshot "03_signin_screen" "Sign In Screen"
take_screenshot "04_signup_screen" "Sign Up Screen"
take_screenshot "05_dashboard_home" "Dashboard Home Screen"
take_screenshot "06_job_search" "Job Search/Browse Screen"
take_screenshot "07_job_detail" "Job Detail Screen"
take_screenshot "08_user_profile" "User Profile Screen"
take_screenshot "09_applications" "My Applications Screen"
take_screenshot "10_chat_screen" "Chat Screen"
take_screenshot "11_smart_apply" "Smart Apply Screen"
take_screenshot "12_manager_dashboard" "Manager Dashboard Screen"

echo "🎉 Screenshot capture complete!"
echo "📁 All screenshots saved in: ./screenshots/"
echo ""
echo "📋 Files captured:"
ls -la screenshots/