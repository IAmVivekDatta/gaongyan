<div align="center">
  <img src="assets/icons/icon.png" alt="GaonGyan Logo" width="150"/>
  <h1>GaonGyan</h1>
  <p><strong>Your Personal Learning Companion 🚀</strong></p>
  <p>
    <i>A Flutter-based mobile application I created to make learning accessible, interactive, and fun for everyone.</i>
  </p>
  <p>
    <a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Made%20with-Flutter-02569B.svg" alt="Made with Flutter"></a>
    <a href="#"><img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-brightgreen.svg" alt="Platform"></a>
    <a href="https://github.com/IAmVivekDatta/gaongyan"><img src="https://img.shields.io/github/stars/IAmVivekDatta/gaongyan?style=social" alt="GitHub Stars"></a>
  </p>
</div>

---

## 🌟 About The Project

Welcome to **GaonGyan**! This project is my journey into creating a comprehensive learning platform using Flutter. My goal was to build an application that not only delivers educational content but also engages users through interactive modules, quizzes, and a sense of progression.

I've designed GaonGyan to be a versatile tool for self-paced learning, with features that cater to a diverse audience, including multi-language support and text-to-speech for enhanced accessibility.

> This app is a demonstration of modern mobile development techniques, clean architecture, and a user-centric approach to design.

---

## ✨ Key Features

I've packed GaonGyan with a variety of features to create a rich learning experience:

-   **👤 User Authentication:** Secure login and registration to manage personal progress.
-   **📚 Interactive Learning Modules:** Step-by-step lessons with mixed media, including embedded YouTube videos.
-   **🗣️ Multi-language Support:** Full internationalization (i18n) with support for English, Telugu, and Hindi.
-   **🏆 Achievements & Levels:** Gamified progression system to motivate users by tracking their accomplishments.
-   **✍️ Quizzes & Practice:** Test knowledge with quizzes and reinforce learning through practice sessions.
-   **🔊 Text-to-Speech (TTS):** Integrated voice guidance for an accessible and hands-free experience.
-   **⚙️ Customizable Settings:** Users can personalize their experience by changing the language, text size, and more.
-   **📊 Progress Tracking:** Visual indicators and statistics to monitor learning progress.
-   **📱 Responsive Design:** A consistent and beautiful UI across different screen sizes and platforms (Android, iOS, and Web).

---

## 🛠️ Tech Stack & Dependencies

This project is built with Dart and Flutter, leveraging a number of powerful packages from the ecosystem:

-   **State Management:** `provider`
-   **Local Storage:** `sqflite` & `shared_preferences`
-   **Text-to-Speech:** `flutter_tts`
-   **Video Playback:** `youtube_player_flutter`
-   **Internationalization:** `flutter_localizations` & `intl`
-   **Icons:** `cupertino_icons` & `flutter_launcher_icons`
-   **Networking/APIs:** `url_launcher`

---

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

Make sure you have Flutter installed on your machine.
- [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)

### Installation

1.  **Clone the repo**
    ```sh
    git clone https://github.com/IAmVivekDatta/gaongyan.git
    ```
2.  **Navigate to the project directory**
    ```sh
    cd gaongyan
    ```
3.  **Install dependencies**
    ```sh
    flutter pub get
    ```
4.  **Run the app**
    ```sh
    flutter run
    ```

---

## 📂 Project Structure

I've organized the codebase using a feature-first approach to keep it clean and scalable:

```
lib/
├── main.dart           # App entry point
├── assets/             # App icons and images
├── l10n/               # Localization files
├── models/             # Data models
├── providers/          # State management (Provider)
├── screens/            # UI for each feature
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── module_screen.dart
│   └── ...
├── services/           # Business logic (database, TTS)
└── widgets/            # Reusable UI components
```

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 👨‍💻 About Me

**Vivek Datta**

-   GitHub: [@IAmVivekDatta](https://github.com/IAmVivekDatta)
-   Feel free to connect with me!

<div align="center">
  <p>Made with ❤️ and a lot of support from copilot.</p>
</div>
