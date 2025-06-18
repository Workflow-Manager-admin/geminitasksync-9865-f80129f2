# GeminiTaskSync

A Flutter application that converts user instructions into actionable tasks using Google's Gemini AI, with cross-device synchronization, reminders, and a clean minimalistic interface.

## Features

- **AI-Powered Task Creation**: Convert natural language instructions into structured tasks using Google Gemini API
- **Smart Task Management**: Automatic priority detection, due dates, and reminder extraction
- **Cross-Device Sync**: Synchronize tasks across multiple devices with user authentication
- **Intelligent Reminders**: Local notifications with scheduled reminders
- **User Authentication**: Secure login system with Firebase Auth
- **Minimalistic UI**: Clean, intuitive interface with light/dark theme support
- **Offline Support**: Local storage with sync when online

## Screenshots

*Coming soon*

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Firebase project with Authentication enabled
- Google Gemini API key

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd geminitasksync
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate model files**
   ```bash
   flutter pub run build_runner build
   ```

4. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication with Email/Password provider
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place the files in their respective platform directories

5. **Get Gemini API Key**
   - Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Create a new API key
   - Configure it in the app settings after first run

### Configuration

#### Android
- Place `google-services.json` in `android/app/`
- Ensure minimum SDK version is 21 in `android/app/build.gradle`

#### iOS
- Place `GoogleService-Info.plist` in `ios/Runner/`
- Ensure minimum iOS version is 12.0 in `ios/Runner/Info.plist`

### Running the App

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device-id>

# Build release version
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## Usage

### First Time Setup

1. **Launch the app** - You'll be greeted with the login screen
2. **Create an account** or sign in with existing credentials
3. **Configure API Key** - Navigate to Settings → Gemini API Configuration
4. **Add your first task** - Use the input field to describe what you need to do

### Creating Tasks

**With AI (Recommended):**
```
"Prepare presentation for Monday meeting with priorities and deadlines"
"Buy groceries: milk, bread, eggs - need by tomorrow evening"
"Schedule dentist appointment - urgent, within next week"
```

**Manual Creation:**
- Tap the "+" button to create tasks manually
- Set title, description, priority, due date, and reminders

### Task Management

- **Complete tasks** by tapping the circle checkbox
- **Edit tasks** by tapping on them
- **Delete tasks** using the delete icon
- **Search tasks** using the search icon in the app bar
- **Filter tasks** using the tabs: All, Today, Pending, Done

### Settings

- **API Configuration**: Add/update your Gemini API key
- **Theme**: Choose between Light, Dark, or System theme
- **Notifications**: Enable/disable task reminders
- **Profile**: View and edit your profile information

## Architecture

### Project Structure

```
lib/
├── models/          # Data models with JSON serialization
├── services/        # API, storage, and notification services
├── providers/       # State management with Provider pattern
├── screens/         # UI screens (Login, Home, Settings, etc.)
├── widgets/         # Reusable UI components
└── main.dart        # App entry point
```

### Key Components

- **Models**: Task, User, ApiConfig with JSON serialization
- **Services**: GeminiService, StorageService, NotificationService, AuthService
- **Providers**: TaskProvider, AuthProvider, SettingsProvider
- **Storage**: SQLite for local storage, SharedPreferences for settings
- **Authentication**: Firebase Auth with email/password

## API Integration

### Gemini API

The app integrates with Google's Gemini API to convert natural language instructions into structured tasks:

- **Model**: Uses `gemini-pro` by default
- **Features**: Extracts title, description, priority, due dates, and reminder times
- **Fallback**: Manual parsing when API is unavailable
- **Configuration**: User-configurable API keys and parameters

### Firebase

- **Authentication**: Email/password sign-in and sign-up
- **Future**: Firestore for cloud sync (configurable)

## Testing

### Run Tests

```bash
# Unit tests
flutter test test/unit_tests.dart

# Widget tests
flutter test test/widget_test.dart

# All tests
flutter test
```

### Test Coverage

- **Unit Tests**: Models, services, and business logic
- **Widget Tests**: UI components and interactions
- **Integration Tests**: Complete user flows

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions:

1. Check the [Issues](../../issues) page
2. Create a new issue with detailed information
3. Include device information, Flutter version, and error logs

## Roadmap

- [ ] Cloud sync with Firestore
- [ ] Task sharing and collaboration
- [ ] Voice input for task creation
- [ ] Advanced task templates
- [ ] Calendar integration
- [ ] Task analytics and insights
- [ ] Widget support for home screen
- [ ] Apple Watch and WearOS support

---

**Note**: This app requires active internet connection for AI-powered task creation. Offline functionality is available for task management and local storage.
