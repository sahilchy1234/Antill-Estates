# Antill Estates - Premium Property Solution

A comprehensive luxury real estate mobile application built with Flutter, offering a seamless property browsing and management experience.

## 📱 Overview

Antill Estates is a full-featured real estate application that provides users with an elegant interface to browse, search, and manage premium properties. The app includes features for both property seekers and real estate agents, with integrated Firebase backend services for authentication, data storage, and real-time updates.

## ✨ Key Features

### Property Management
- **Property Listings**: Browse through extensive property catalogs with detailed information
- **Advanced Search & Filters**: Find properties based on location, price, type, amenities, and more
- **Property Details**: View comprehensive property information including photos, pricing, specifications, and location
- **Interactive Maps**: Explore properties with integrated Google Maps
- **Save & Favorites**: Bookmark properties for later viewing
- **Property Posting**: List your own properties with photo uploads and detailed descriptions

### User Experience
- **Authentication**: Secure phone number-based authentication with OTP verification
- **User Profiles**: Manage personal profiles with customizable settings
- **Multi-language Support**: Interface available in multiple languages
- **Activity Tracking**: View recently viewed properties and browsing history
- **Notifications**: Real-time push notifications for property updates and messages

### Agent & Community Features
- **Agent Profiles**: Detailed agent information and listings
- **Contact Owners**: Direct communication with property owners and agents
- **Reviews & Ratings**: Rate and review properties and brokers
- **Responses Management**: Track inquiries and responses

### Additional Features
- **Arts & Antiques**: Browse luxury items and collectibles
- **Interesting Reads**: Access property market news and articles
- **Upcoming Projects**: Preview properties under development
- **Popular Builders**: Explore properties from renowned developers
- **Explore Cities**: Discover properties in different locations
- **Gallery Views**: Immersive photo galleries for properties
- **Share Properties**: Share listings with friends and family

## 🛠️ Technology Stack

### Framework & Language
- **Flutter**: 3.32.2
- **Dart**: 3.8.1

### Core Dependencies
- **State Management**: GetX (get: ^4.7.2)
- **Firebase Services**:
  - Firebase Core
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
  - Firebase Messaging
  - Firebase App Check
- **Maps**: Google Maps Flutter
- **Local Storage**: GetStorage, SharedPreferences
- **Image Handling**: 
  - Image Picker
  - Cached Network Image
  - Flutter Image Compress
- **UI Components**:
  - Pinput (OTP input)
  - Dotted Border
  - Flutter Rating Bar
  - Visibility Detector

### Additional Features
- **Permissions**: Permission Handler
- **URL Launcher**: Open external links
- **Share Plus**: Share content functionality
- **Local Notifications**: Push notification handling
- **HTTP**: API communication
- **Crypto**: Secure data handling

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK (3.32.2 or higher)
- Dart SDK (3.8.1 or higher)
- Android Studio / Xcode (for mobile development)
- Firebase account with project setup
- Google Maps API key

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd luxury_real_estate_flutter_ui_kit
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Configuration

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android/iOS apps to your Firebase project
3. Download and place configuration files:
   - `google-services.json` in `android/app/`
   - `GoogleService-Info.plist` in `ios/Runner/`
4. Update `lib/firebase_options.dart` with your Firebase configuration
5. Configure Firebase services:
   - Enable Authentication (Phone)
   - Create Firestore database
   - Set up Firebase Storage
   - Enable Firebase Messaging

### 4. Google Maps Setup

1. Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Add the API key to:
   - **Android**: `android/app/src/main/AndroidManifest.xml`
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY_HERE"/>
   ```
   - **iOS**: `ios/Runner/AppDelegate.swift`
   ```swift
   GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
   ```

### 5. Run the Application

```bash
# For Android
flutter run

# For iOS
flutter run --release

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## 📂 Project Structure

```
lib/
├── app.dart                    # Main app configuration
├── main.dart                   # Application entry point
├── common/                     # Reusable widgets
├── configs/                    # App configurations (colors, fonts, strings)
├── controller/                 # GetX controllers for state management
├── model/                      # Data models
├── routes/                     # App navigation and routes
├── services/                   # Backend services and API calls
├── utils/                      # Utility functions and helpers
├── views/                      # UI screens
└── widgets/                    # Custom widgets

assets/
├── images/                     # Application images and icons
├── flags/                      # Country flags for multi-language support
└── fonts/                      # Custom Inter font family
```

## 🎨 Design Features

- **Modern UI/UX**: Clean, elegant interface with smooth animations
- **Responsive Design**: Adapts to different screen sizes
- **Custom Fonts**: Inter font family for consistent typography
- **Optimized Images**: Lazy loading and caching for better performance
- **Shimmer Loading**: Smooth skeleton loading states
- **Dark Mode Ready**: Configurable color schemes

## 🔐 Security

- Firebase App Check integration for backend security
- Secure authentication with phone verification
- Encrypted data storage
- Permission-based access control

## 📊 Performance Optimizations

- Image compression and optimization
- Cached network images
- Lazy loading for lists and galleries
- Efficient state management with GetX
- Optimized build configurations

## 🌍 Internationalization

The app supports multiple languages with:
- Language selection screen
- Country picker with flags
- Localized content

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test
```

## 📱 Build & Deployment

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release
```

### iOS

```bash
# Build for iOS
flutter build ios --release
```

## 🔧 Configuration Files

- `pubspec.yaml` - Dependencies and assets configuration
- `firebase.json` - Firebase project configuration
- `storage.rules` - Firebase Storage security rules
- `devtools_options.yaml` - Flutter DevTools configuration

## 📝 Version History

- **v1.0.1** - Current stable release
  - Initial release with core features
  - Firebase integration
  - Property management system
  - Agent profiles and reviews
  - Multi-language support

## 🤝 Contributing

This is a client project. For contributions or modifications, please contact the project maintainer.

## 📄 License

This project is proprietary software developed for client use. All rights reserved.

## 📧 Support

For technical support or inquiries, please contact the development team.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Google Maps for location services
- All open-source contributors whose packages made this project possible

---

**Note**: This application requires proper Firebase and Google Maps configuration to function correctly. Ensure all API keys and configuration files are properly set up before deployment.

