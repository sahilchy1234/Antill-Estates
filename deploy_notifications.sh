#!/bin/bash

echo "🚀 Setting up Complete Notification System"
echo "=========================================="

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in to Firebase
if ! firebase projects:list &> /dev/null; then
    echo "❌ Please login to Firebase first:"
    echo "firebase login"
    exit 1
fi

echo "✅ Firebase CLI is ready"

# Navigate to functions directory
cd admin_panel/functions

echo "📦 Installing dependencies..."
npm install

echo "🔧 Deploying Firebase Functions..."
firebase deploy --only functions

if [ $? -eq 0 ]; then
    echo "✅ Firebase Functions deployed successfully!"
    echo ""
    echo "🎯 Next Steps:"
    echo "1. Open admin panel: cd admin_panel && python -m http.server 8000"
    echo "2. Open http://localhost:8000 in your browser"
    echo "3. Test sending notifications from admin panel"
    echo "4. Check Flutter app receives notifications"
    echo ""
    echo "📱 Flutter App Setup:"
    echo "1. Run: flutter clean && flutter pub get"
    echo "2. Run: flutter run"
    echo "3. Check console for FCM token"
    echo "4. Test notification flow"
else
    echo "❌ Firebase Functions deployment failed"
    exit 1
fi
