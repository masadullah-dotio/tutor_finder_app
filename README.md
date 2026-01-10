# 🎓 Tutor Finder

<div align="center">

![Tutor Finder](assets/images/splash_light.png)

**Connect students with qualified tutors for personalized learning experiences**

[![Flutter](https://img.shields.io/badge/Flutter-3.10-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Live Demo](https://tutor-finder-dotio.web.app) • [API Documentation](https://github.com/masadullah-dotio/tutor_finder_api) • [Report Bug](https://github.com/masadullah-dotio/tutor_finder_app/issues)

</div>

---

## 📋 Table of Contents

- [About](#about)
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Backend & API](#backend--api)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [Team](#team)
- [License](#license)

---

## 🌟 About

**Tutor Finder** is a cross-platform mobile and web application built with Flutter that bridges the gap between students seeking academic help and qualified tutors. The platform offers seamless booking, secure payments, real-time communication, and comprehensive profile management for both students and tutors.

### 🎯 Mission

To democratize access to quality education by connecting learners with expert tutors in an easy, secure, and affordable way.

---

## ✨ Features

### 👨‍🎓 For Students

- **🔍 Smart Tutor Discovery**
  - Search by subject, location, ratings, and availability
  - Filter by hourly rate and experience level
  - View detailed tutor profiles with reviews and credentials

- **📅 Easy Booking System**
  - Real-time availability calendar
  - Multiple time slot selection
  - Home tutoring or online sessions (coming soon)
  - Automated address auto-fill using geolocation

- **💳 Secure Payment Processing**
  - Stripe integration for safe transactions
  - Support for multiple payment methods
  - Automatic receipt generation
  - Transparent pricing with no hidden fees

- **⭐ Review & Rating System**
  - Leave honest reviews after sessions
  - View aggregated tutor ratings
  - Help the community make informed decisions

- **💬 In-App Messaging**
  - Direct communication with tutors
  - Real-time chat powered by Firebase
  - Share session details and materials

- **📊 Comprehensive Dashboard**
  - Track upcoming and past bookings
  - Manage reviews and reports
  - View payment history
  - Schedule overview

### 👨‍🏫 For Tutors

- **📝 Rich Profile Management**
  - Showcase qualifications and expertise
  - Set hourly rates and availability
  - Upload profile pictures and documents
  - Highlight teaching subjects

- **📆 Calendar Management**
  - Set your available time slots
  - Sync with bookings automatically
  - Block off personal time
  - Recurring availability patterns

- **💰 Earnings Dashboard**
  - Track total earnings
  - View payment breakdowns
  - Monitor booking statistics
  - Student count metrics

- **⭐ Reputation Building**
  - Collect and display student reviews
  - Average rating calculation
  - Performance metrics
  - Build credibility over time

- **🔔 Real-time Notifications**
  - Instant booking alerts
  - Message notifications
  - Payment confirmations
  - Schedule reminders

### 🔐 Security & Verification

- **✅ Two-Factor Verification**
  - Email verification required
  - Mobile phone verification
  - Access control to sensitive features
  - Verification guard on critical actions

- **🛡️ Report System**
  - Flag inappropriate behavior
  - Admin moderation panel
  - User safety prioritization

- **🔒 Secure Authentication**
  - Firebase Authentication
  - Google Sign-in support
  - Secure session management
  - Data encryption

### 👑 Admin Panel

- **📊 User Management**
  - Approve/reject tutor applications
  - Monitor user activity
  - Handle reports and disputes
  - View platform analytics

- **🎛️ Platform Control**
  - Manage featured tutors
  - Set platform fees
  - Monitor payment transactions
  - Generate reports

---

## 📱 Screenshots

<div align="center">

| Home Screen | Tutor Search | Booking Flow |
|------------|--------------|--------------|
| ![Home](assets/screenshots/home.png) | ![Search](assets/screenshots/search.png) | ![Booking](assets/screenshots/booking.png) |

| Dashboard | Chat | Profile |
|-----------|------|---------|
| ![Dashboard](assets/screenshots/dashboard.png) | ![Chat](assets/screenshots/chat.png) | ![Profile](assets/screenshots/profile.png) |

</div>

---

## 🛠️ Tech Stack

### Frontend (Mobile & Web)

- **Framework**: [Flutter 3.10+](https://flutter.dev/)
- **Language**: [Dart](https://dart.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Architecture**: Clean Architecture with Repository Pattern

### Backend & Services

- **Authentication**: [Firebase Auth](https://firebase.google.com/products/auth)
- **Database**: [Cloud Firestore](https://firebase.google.com/products/firestore)
- **Storage**: [Firebase Storage](https://firebase.google.com/products/storage)
- **Notifications**: [Firebase Cloud Messaging](https://firebase.google.com/products/cloud-messaging)
- **Payment API**: [Django REST Framework](https://www.django-rest-framework.org/) + [Stripe](https://stripe.com/)

### Key Dependencies

```yaml
dependencies:
  # Firebase Suite
  firebase_core: ^4.3.0
  firebase_auth: ^6.1.3
  cloud_firestore: ^6.1.1
  firebase_messaging: ^16.1.0
  
  # Payment Processing
  flutter_stripe: ^12.1.1
  flutter_stripe_web: ^7.1.1
  
  # State Management & Architecture
  provider: ^6.1.5
  dartz: ^0.10.1
  
  # Maps & Location
  google_maps_flutter: ^2.14.0
  geolocator: ^14.0.2
  geocoding: ^4.0.0
  
  # UI & Utilities
  intl: ^0.20.2
  image_picker: ^1.2.1
  url_launcher: ^6.3.2
  flutter_dotenv: ^5.1.0
```

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.10.0 or higher
- **Dart SDK**: 3.10.0 or higher
- **Android Studio** / **VS Code** with Flutter extensions
- **Firebase Account** (for backend services)
- **Stripe Account** (for payment processing)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/masadullah-dotio/tutor_finder_app.git
   cd tutor_finder_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android and iOS apps to your Firebase project
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the respective directories:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`
   - Run Firebase CLI configuration:
     ```bash
     flutterfire configure
     ```

4. **Set up environment variables**

   Create a `.env` file in the root directory:

   ```env
   API_BASE_URL=https://your-api-url.vercel.app
   STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_key
   ```

5. **Run the app**

   ```bash
   # For development
   flutter run
   
   # For web
   flutter run -d chrome
   
   # For production build
   flutter build apk --split-per-abi --release
   ```

### Firebase Setup

Enable the following Firebase services:

- **Authentication**: Email/Password, Google Sign-In
- **Firestore Database**: Start in test mode, then configure security rules
- **Cloud Storage**: For profile pictures and documents
- **Cloud Messaging**: For push notifications

### Firestore Indexes

Create composite indexes for:

1. **Collection**: `reports`
   - Fields: `reporterId` (Ascending), `timestamp` (Descending)

2. **Collection**: `reviews`
   - Fields: `tutorId` (Ascending), `timestamp` (Descending)
   - Fields: `studentId` (Ascending), `timestamp` (Descending)

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── presentation/
│   │   └── widgets/          # Reusable UI components
│   ├── routes/               # Navigation configuration
│   ├── services/             # Core services (Auth, Notifications)
│   ├── theme/                # App theming
│   └── utils/                # Utility functions
├── features/
│   ├── admin/                # Admin dashboard
│   ├── auth/                 # Authentication
│   ├── booking/              # Booking system
│   ├── chat/                 # Messaging
│   ├── intro/                # Onboarding & Splash
│   ├── payment/              # Payment processing
│   ├── report/               # Reporting system
│   ├── review/               # Review & Rating
│   ├── student/              # Student features
│   └── tutor/                # Tutor features
├── firebase_options.dart     # Firebase configuration
├── app.dart                  # App initialization
└── main.dart                 # Entry point
```

Each feature follows **Clean Architecture**:

```
feature/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── domain/
│   ├── entities/
│   └── usecases/
└── presentation/
    ├── pages/
    ├── widgets/
    └── providers/
```

---

## 🔗 Backend & API

### Django Payment API

The payment processing backend is built with Django and deployed on Vercel.

- **Repository**: [tutor_finder_api](https://github.com/masadullah-dotio/tutor_finder_api)
- **Live API**: [https://tutor-finder-api.vercel.app](https://tutor-finder-api.vercel.app)
- **Documentation**: Available in the API repository

### Key Endpoints

- `POST /api/create-payment-intent/` - Initialize Stripe payment
- `POST /api/create-checkout-session/` - Create Stripe Checkout session (web)
- `GET /api/payment-status/<payment_id>/` - Check payment status

### Setting Up the Backend

```bash
git clone https://github.com/masadullah-dotio/tutor_finder_api.git
cd tutor_finder_api
pip install -r requirements.txt
python manage.py runserver
```

See the [API README](https://github.com/masadullah-dotio/tutor_finder_api/blob/main/README.md) for detailed setup instructions.

---

## 🌐 Deployment

### Web Deployment (Firebase Hosting)

```bash
# Build for web
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting
```

**Live URL**: [https://tutor-finder-dotio.web.app](https://tutor-finder-dotio.web.app)

### Android Release

```bash
# Build APKs
flutter build apk --split-per-abi --release

# Or build App Bundle
flutter build appbundle --release
```

APKs available in: `build/app/outputs/flutter-apk/`

### iOS Release

```bash
flutter build ios --release
```

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Standards

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Comment complex logic
- Write unit tests for new features

---

## 👥 Team

### Developed by **AURA**

<div align="center">

| Developer | Role | GitHub |
|-----------|------|--------|
| **Aun Abbas** | Lead Developer | [@aunabbas](https://github.com/aunabbas) |
| **Muhammad Asad Ullah** | Full Stack Developer | [@masadullah-dotio](https://github.com/masadullah-dotio) |

</div>

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- Stripe for payment processing
- All our beta testers and early adopters

---

## 📞 Contact & Support

- **Website**: [https://tutor-finder-dotio.web.app](https://tutor-finder-dotio.web.app)
- **Email**: support@aura.dev
- **Issues**: [GitHub Issues](https://github.com/masadullah-dotio/tutor_finder_app/issues)

---

<div align="center">

**Made with ❤️ by AURA**

⭐ Star us on GitHub if you find this project useful!

</div>
