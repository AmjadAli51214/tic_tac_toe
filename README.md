# 🎮 Tic-Tac-Toe — Multiplayer Flutter App

A dynamic multiplayer Tic-Tac-Toe game built with **Flutter**, featuring real-time gameplay powered by **Firebase Firestore**. Challenge friends from anywhere in the world!

---

## 📋 Table of Contents

- [About the Project](#about-the-project)
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
  - [1. Clone the Repository](#1-clone-the-repository)
  - [2. Install Dependencies](#2-install-dependencies)
  - [3. Firebase Setup](#3-firebase-setup)
  - [4. Run the App](#4-run-the-app)
- [Project Structure](#project-structure)
- [How to Play](#how-to-play)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## 📖 About the Project

This is a real-time multiplayer Tic-Tac-Toe game where two players can join the same game room and play against each other live. The game state is synchronized between devices using **Firebase Firestore**, ensuring both players see every move instantly.

---

## ✨ Features

- 🔴 **Real-Time Multiplayer** — Play with a friend in real time using Firestore sync
- 🏠 **Create & Join Rooms** — Generate a unique room code to invite a friend
- 🎯 **Turn-Based Logic** — Enforces proper turn order (X always goes first)
- 🏆 **Win Detection** — Automatically detects all winning combinations and draws
- 🔄 **Rematch Option** — Start a new game without leaving the room
- 📱 **Cross-Platform** — Runs on Android, iOS, and Web
- 🎨 **Clean UI** — Simple and intuitive game board interface

---

## 📸 Screenshots

> _Screenshots will be added here once the app UI is finalized._

---

## 🛠 Tech Stack

| Technology | Purpose |
|---|---|
| [Flutter](https://flutter.dev/) | Cross-platform UI framework |
| [Dart](https://dart.dev/) | Programming language |
| [Firebase Firestore](https://firebase.google.com/docs/firestore) | Real-time database for game state |
| [Firebase Core](https://pub.dev/packages/firebase_core) | Firebase initialization |
| [Cloud Firestore](https://pub.dev/packages/cloud_firestore) | Firestore Flutter plugin |

---

## ✅ Prerequisites

Make sure you have the following installed before getting started:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.0.0)
- [Dart SDK](https://dart.dev/get-dart) (comes bundled with Flutter)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter/Dart extensions
- A [Firebase](https://firebase.google.com/) account
- A connected device or emulator

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/AmjadAli51214/tic_tac_toe.git
cd tic_tac_toe
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

1. Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
2. Register your app (Android and/or iOS) with the Firebase project.
3. Download the configuration files:
   - **Android**: Download `google-services.json` and place it in `android/app/`
   - **iOS**: Download `GoogleService-Info.plist` and place it in `ios/Runner/`
4. Enable **Cloud Firestore** in the Firebase console (start in test mode for development).
5. If using `flutterfire_cli`, run:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### 4. Run the App

```bash
flutter run
```

To run on a specific platform:

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

---

## 📁 Project Structure

```
tic_tac_toe/
├── android/                  # Android native files
├── ios/                      # iOS native files
├── lib/
│   ├── main.dart             # App entry point & Firebase initialization
│   ├── screens/
│   │   ├── home_screen.dart  # Home screen (create/join room)
│   │   └── game_screen.dart  # Main game board screen
│   ├── widgets/
│   │   └── board_tile.dart   # Individual tile widget
│   ├── services/
│   │   └── game_service.dart # Firestore game logic & data layer
│   └── models/
│       └── game_model.dart   # Game state data model
├── web/                      # Web platform files
├── pubspec.yaml              # Project dependencies
└── README.md
```

> _Note: Actual structure may vary. The above reflects the typical layout for this type of project._

---

## 🎯 How to Play

1. **Player 1** opens the app and taps **"Create Room"** to generate a unique room code.
2. **Player 2** opens the app, enters the room code, and taps **"Join Room"**.
3. Once both players are connected, the game begins.
4. Players take turns tapping an empty tile to place their mark (**X** or **O**).
5. The first player to get **3 in a row** (horizontally, vertically, or diagonally) wins!
6. If all 9 tiles are filled with no winner, the game is a **draw**.
7. After the game ends, both players can tap **"Rematch"** to play again.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 📬 Contact

**Amjad Ali**
- GitHub: [@AmjadAli51214](https://github.com/AmjadAli51214)
- Email: numl-s23-34990@numls.edu.pk

---

> Built with ❤️ using Flutter & Firebase
