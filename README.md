# 📚 Flutter Education App

A modern, personalized education app built with Flutter and Firebase, designed to enhance the learning experience through smart recommendations, seamless navigation, and an intuitive UI.

---

## ✨ Features

- 🔐 Firebase Authentication (Email/Password)
- 🧑 User Profile Management (Name, Bio, Phone)
- 🎓 Course Browsing and Enrollment
- 🧠 Personalized Course Recommendations
- 🌙 Light/Dark Theme Support (via Riverpod)
- 🔄 State Management using `flutter_riverpod`
- 📦 Firebase Firestore Integration for Realtime Data
- 🔍 Search Courses by Title
- 🧭 Bottom Navigation with PageView Architecture

---

## 🖼️ Screens

- **HomeScreen**: Recommended courses personalized to the user.
- **CoursesScreen**: Browse all available courses.
- **ProfileScreen**: View/edit profile info and enrolled courses.
- **SettingsScreen**: Theme switching, logout, and other settings.
- **MainNavigationScreen**: Custom animated navigation with bottom tabs.

---

## 🏗️ Architecture

- **Frontend**: Flutter + Dart
- **Backend**: Firebase Firestore, Firebase Authentication
- **State Management**: `flutter_riverpod`
- **Folder Structure**:
  ```
  lib/
  ├── models/
  ├── screens/
  ├── service/
  ├── providers/
  └── main.dart
  ```

---

## 🚀 Getting Started

### 1. Clone the Repo
```bash
git clone https://github.com/your-username/education_app.git
cd education_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Set Up Firebase
- Create a Firebase project
- Enable **Authentication (Email/Password)**
- Create **Firestore Database**
- Add your `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) to the project

### 4. Run the App
```bash
flutter run
```

---

## 🛠️ Firebase Setup Checklist

- ✅ Enable Email/Password Authentication
- ✅ Create Firestore collections:
  - `users`: Stores user info and enrolled courses
  - `courses`: Stores all available course data
- ✅ Add dummy course data in `courses` collection for testing

---

## 🧠 Recommendation Logic (Basic)

- Recommends courses not already enrolled
- Future enhancement: Use tags and difficulty levels to match interests

---

## 📱 Screenshots (Optional)
_Add screenshots here showing the app in action._

---

## 🤝 Contributors

- **Shashwat Rai** – [@shashwatrai05](https://github.com/shashwatrai05)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```
