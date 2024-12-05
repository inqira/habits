# Let's Habit

<div align="center">
  <img src="assets/app_icon.png" alt="Let's Habit Logo" width="120"/>
  <h3>A modern, cross-platform habit tracking application</h3>
</div>

## Features

- **Cross-Platform**: Works seamlessly on iOS, Android, Web, Windows, and macOS
- **Habit Management**: Create, track, and manage your daily habits
- **Progress Tracking**: Visual progress indicators and statistics
- **Customizable Categories**: Organize habits with custom categories and icons
- **Personalized Profile**: Customize your avatar and profile settings
- **Theme Customization**: Choose from various color schemes and dark/light modes
- **Reminders**: Set custom reminders for your habits
- **Data Persistence**: Local storage with Realm database
- **Backup & Sync**: Coming soon

## Screenshots

[Screenshots to be added]

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK (compatible with Flutter version)
- Android Studio / Xcode (for mobile development)
- Git

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/inqira/habits.git
   ```

2. Navigate to the project directory:
   ```bash
   cd habits
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Tech Stack

- **Framework**: Flutter
- **State Management**: Signals
- **Database**: Realm
- **Styling**: flex_color_scheme
- **Avatar**: fluttermoji
- **Icons**: ionicons
- **Dependencies**:
  - signals: ^6.0.1
  - flex_color_scheme: ^8.0.1
  - fluttermoji: ^1.0.2
  - realm: ^20.0.0
  - shared_preferences: ^2.3.3
  - get_it: ^8.0.2
  - ionicons: ^0.2.2
  - uuid: ^4.3.3
  - intl: ^0.20.1
  - package_info_plus: ^8.1.1
  - url_launcher: ^6.2.1
  - auto_size_text: ^3.0.0
  - synchronized: ^3.3.0+3

## Architecture

The project follows a clean architecture pattern with the following structure:

```
lib/
├── core/           # Core functionality and service locator
├── models/         # Data models
├── screens/        # UI screens
│   ├── home/       # Home screen and views
│   ├── settings/   # Settings screens
│   └── ...
├── services/       # Business logic and services
└── widgets/        # Reusable widgets
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License with Brand Exception - see the [LICENSE](LICENSE) file for details.

### What you can do:
- Use the code for any purpose (personal, commercial, etc.)
- Modify the code
- Distribute the code
- Create derivative works
- Sublicense the code
- Sell the code or products based on it

### What you cannot do:
- Use the Inqira name, brand, or logos without permission
- Claim the Brand Assets as your own
- Use the Brand Assets in any way that suggests endorsement by Inqira

### Attribution
- Attribution to the original source is encouraged but not required
- If you do attribute, please link to this repository

## Acknowledgments

- [Flutter](https://flutter.dev) - UI framework

## Contact

Inqira - [@inqira](https://github.com/inqira)

Project Link: [https://github.com/inqira/habits](https://github.com/inqira/habits)

