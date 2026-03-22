# Expense-Tracker

A beautiful and intuitive Flutter application for tracking your personal expenses. Keep tabs on your spending habits, categorize transactions, and gain insights into your financial patterns with ease.

## ✨ Features

- **📊 Dashboard Overview**: Get a quick glance at your total spending, monthly expenses, and category breakdowns
- **💳 Transaction Management**: Add, edit, and delete transactions with detailed information
- **📂 Category Organization**: Organize expenses by categories for better tracking
- **📅 Date-based Filtering**: View transactions by date ranges and monthly summaries
- **💾 Local Storage**: All data is stored locally using Hive database
- **🎨 Modern UI**: Clean and responsive design built with Flutter
- **🌙 Cross-platform**: Works on Android, iOS, Web, Windows, Mac, and Linux

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (version 3.0 or higher)
- Dart SDK
- Android Studio / Xcode for mobile development

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Saravana0910/Expense-Tracker.git
   cd Expense-Tracker
   ```

2. **Navigate to the Flutter project**
   ```bash
   cd expense_tracker
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS (on macOS):**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## 📱 Screenshots

*Add screenshots of your app here to showcase the UI*

## 🏗️ Architecture

This app follows a clean architecture pattern with:

- **Presentation Layer**: Flutter widgets with Riverpod for state management
- **Domain Layer**: Business logic and models
- **Data Layer**: Local storage with Hive database

### Key Technologies

- **Flutter**: UI framework
- **Riverpod**: State management
- **Hive**: Local database
- **Flutter Riverpod**: Dependency injection
- **Material Design**: UI components

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Setup

1. Ensure you have Flutter installed
2. Run `flutter doctor` to check your setup
3. Use `flutter analyze` for code analysis
4. Run tests with `flutter test`

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for excellent state management
- Material Design for beautiful UI components

## 📞 Support

If you have any questions or issues, please open an issue on GitHub or contact the maintainers.

---

**Made with ❤️ using Flutter**