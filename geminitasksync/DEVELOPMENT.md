# GeminiTaskSync Development Guide

## Project Overview

GeminiTaskSync is a Flutter application that leverages Google's Gemini AI to convert natural language instructions into structured, actionable tasks. The app features cross-device synchronization, intelligent reminders, and a clean minimalistic interface.

## Architecture

### Application Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Presentation Layer                   │
├─────────────────────────────────────────────────────────────┤
│  Screens     │  Widgets     │  State Management (Provider)  │
│  - Login     │  - TaskItem  │  - AuthProvider               │
│  - Home      │  - TaskInput │  - TaskProvider               │
│  - Settings  │  - Custom    │  - SettingsProvider           │
│  - Detail    │    Button    │                               │
├─────────────────────────────────────────────────────────────┤
│                        Business Layer                       │
├─────────────────────────────────────────────────────────────┤
│  Services                                                   │
│  - GeminiService (AI Integration)                          │
│  - AuthService (Authentication)                            │
│  - StorageService (Local Storage)                          │
│  - NotificationService (Reminders)                         │
├─────────────────────────────────────────────────────────────┤
│                        Data Layer                          │
├─────────────────────────────────────────────────────────────┤
│  Models      │  Local Storage    │  External APIs           │
│  - Task      │  - SQLite         │  - Gemini API            │
│  - User      │  - SharedPrefs    │  - Firebase Auth         │
│  - ApiConfig │                   │                          │
└─────────────────────────────────────────────────────────────┘
```

### State Management

The application uses the Provider pattern for state management:

- **AuthProvider**: Manages user authentication state
- **TaskProvider**: Handles task CRUD operations and AI integration
- **SettingsProvider**: Manages app configuration and preferences

### Data Flow

1. **User Input** → UI Components
2. **UI Events** → Provider Actions
3. **Provider Actions** → Service Layer
4. **Service Layer** → External APIs/Local Storage
5. **Response** → Provider State Update
6. **State Update** → UI Rebuild

## Technical Stack

### Core Technologies

- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Provider Pattern
- **Local Database**: SQLite (sqflite)
- **Local Storage**: SharedPreferences
- **Authentication**: Firebase Auth
- **Notifications**: flutter_local_notifications
- **HTTP Client**: http package
- **JSON Serialization**: json_annotation + build_runner

### External APIs

- **Google Gemini API**: AI-powered task creation
- **Firebase Authentication**: User management

## Features Implementation

### 1. AI-Powered Task Creation

**Flow:**
```
User Input → GeminiService → API Request → Response Parsing → Task Creation
```

**Key Components:**
- `GeminiService`: Handles API communication
- `TaskProvider`: Manages task state
- Fallback parsing for offline/API failure scenarios

### 2. Cross-Device Synchronization

**Current Implementation:**
- Local storage with SQLite
- User-specific task isolation
- Sync status tracking

**Future Enhancement:**
- Firestore integration for real-time sync
- Conflict resolution algorithms

### 3. Intelligent Reminders

**Components:**
- `NotificationService`: Handles scheduling and display
- Timezone-aware scheduling
- Permission management
- Background execution support

### 4. Authentication System

**Flow:**
```
User Credentials → AuthService → Firebase Auth → AuthProvider → UI Update
```

**Features:**
- Email/password authentication
- User profile management
- Session persistence
- Password reset functionality

## Database Schema

### Tasks Table

```sql
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  dueDate TEXT,
  reminderTime TEXT,
  priority TEXT NOT NULL,
  isCompleted INTEGER NOT NULL DEFAULT 0,
  userId TEXT,
  syncStatus INTEGER NOT NULL DEFAULT 0
);
```

### Users Table

```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL,
  displayName TEXT,
  photoUrl TEXT,
  createdAt TEXT NOT NULL,
  lastLoginAt TEXT NOT NULL
);
```

## API Integration

### Gemini API Integration

**Endpoint:** `https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent`

**Request Structure:**
```json
{
  "contents": [{
    "parts": [{"text": "user_instruction"}]
  }],
  "generationConfig": {
    "temperature": 0.7,
    "maxOutputTokens": 1000
  }
}
```

**Response Parsing:**
- Extract structured task data from AI response
- Fallback to manual parsing if AI parsing fails
- Priority detection based on keywords
- Date/time extraction using regex patterns

## Development Setup

### Prerequisites

1. Flutter SDK (latest stable)
2. Firebase project with Authentication enabled
3. Google Gemini API key
4. IDE with Flutter support (VS Code/Android Studio)

### Environment Setup

1. **Clone and Setup:**
   ```bash
   git clone <repository>
   cd geminitasksync
   flutter pub get
   flutter pub run build_runner build
   ```

2. **Firebase Configuration:**
   - Create Firebase project
   - Enable Authentication with Email/Password
   - Download configuration files
   - Place in appropriate directories

3. **API Keys:**
   - Obtain Gemini API key from Google AI Studio
   - Configure in app settings after first run

### Code Generation

The project uses code generation for JSON serialization:

```bash
# Generate model files
flutter pub run build_runner build

# Watch for changes and regenerate
flutter pub run build_runner watch

# Clean and regenerate
flutter pub run build_runner build --delete-conflicting-outputs
```

## Testing Strategy

### Test Structure

```
test/
├── unit_tests.dart           # Model and service tests
├── widget_test.dart          # UI component tests
└── integration_tests.dart    # End-to-end flow tests
```

### Test Categories

1. **Unit Tests:**
   - Model serialization/deserialization
   - Service method functionality
   - Business logic validation

2. **Widget Tests:**
   - UI component rendering
   - User interaction handling
   - State management integration

3. **Integration Tests:**
   - Complete user workflows
   - Cross-component communication
   - Authentication flows

### Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/unit_tests.dart

# With coverage
flutter test --coverage
```

## Performance Considerations

### Optimization Strategies

1. **Lazy Loading:** Tasks loaded on-demand
2. **Pagination:** Large task lists handled efficiently
3. **Caching:** API responses cached locally
4. **Background Processing:** Non-blocking operations
5. **Memory Management:** Proper disposal of resources

### Monitoring

- Performance metrics tracking
- Error reporting and analytics
- User behavior insights
- API usage monitoring

## Security Considerations

### Data Protection

1. **API Keys:** Stored securely, never in source code
2. **User Data:** Encrypted local storage
3. **Network:** HTTPS for all communications
4. **Authentication:** Firebase security rules
5. **Permissions:** Minimal required permissions

### Best Practices

- Input validation and sanitization
- Secure storage for sensitive data
- Regular security updates
- Privacy by design principles

## Deployment

### Build Configuration

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# iOS build
flutter build ios --release
```

### Platform-Specific Considerations

**Android:**
- Minimum SDK: 21 (Android 5.0)
- Target SDK: Latest
- Proguard configuration for release builds

**iOS:**
- Minimum version: 12.0
- App Store compliance
- Background app refresh permissions

## Future Enhancements

### Planned Features

1. **Cloud Sync:** Real-time synchronization with Firestore
2. **Collaboration:** Task sharing and team features
3. **Voice Input:** Speech-to-text for task creation
4. **Templates:** Predefined task templates
5. **Analytics:** Task completion insights
6. **Widgets:** Home screen widgets for quick access

### Technical Improvements

1. **Offline Support:** Enhanced offline capabilities
2. **Performance:** Advanced caching strategies
3. **Accessibility:** Screen reader and accessibility support
4. **Internationalization:** Multi-language support
5. **Testing:** Increased test coverage and automation

## Contributing Guidelines

### Code Standards

1. **Formatting:** Use `dart format`
2. **Linting:** Follow `flutter_lints` rules
3. **Documentation:** Document all public interfaces
4. **Testing:** Write tests for new features
5. **Git:** Conventional commit messages

### Pull Request Process

1. Fork the repository
2. Create feature branch
3. Implement changes with tests
4. Update documentation
5. Submit pull request with detailed description

## Troubleshooting

### Common Issues

1. **Build Errors:** Run `flutter clean` and `flutter pub get`
2. **Code Generation:** Run `flutter pub run build_runner build`
3. **Firebase Setup:** Verify configuration files placement
4. **API Issues:** Check API key configuration
5. **Permissions:** Verify platform-specific permissions

### Debug Tools

- Flutter Inspector for UI debugging
- Dart DevTools for performance analysis
- Firebase Console for authentication debugging
- API testing tools for external service integration

---

**Note:** This is a living document that should be updated as the project evolves.
