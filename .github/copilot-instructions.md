# Personal Wellness Tracker - AI Coding Guidelines

## Architecture Overview

This is a **Flutter wellness tracking app** with Firebase backend, using **Riverpod for state management** and **ARB localization** (English/Thai). The app follows a clear authenticated/unauthenticated flow with modular feature organization.

### Key Architectural Patterns

**Authentication Flow**: `main.dart` → `authStateChangesProvider` → `LoginScreen` | `AuthedLayout`
- Use `ref.watch(authStateChangesProvider)` for auth state
- Authenticated users see `AuthedLayout` with 6-tab bottom navigation
- Unauthenticated users see `LoginScreen`

**State Management**: Pure Riverpod pattern
- Providers in `lib/providers/` (auth, language, habits, user)
- Services in `lib/services/` for Firebase operations
- Use `ConsumerWidget`/`ConsumerStatefulWidget` consistently
- Example: `ref.read(authServiceProvider).signInWithEmail()`

**Modular Feature Structure**: `lib/authed/{feature}/`
```
authed/
├── authed_layout.dart          # Main authenticated container
├── dashboard/dashboard_page.dart
├── habits/habits_page.dart
├── meals/meals_page.dart
├── progress/progress_page.dart
├── goals/goals_page.dart
└── profile/profile_page.dart
```

## Critical Development Workflows

**Environment Setup**:
```bash
flutter pub get
# Requires .env file with Firebase keys (see config/env_config.dart)
flutter run  # or use VS Code task "Run Flutter App"
```

**Splash Screen Regeneration**:
```bash
flutter pub run flutter_native_splash:create
# After modifying flutter_native_splash config in pubspec.yaml
```

**Localization Workflow**:
```bash
flutter gen-l10n
# Regenerates l10n files after editing lib/l10n/app_*.arb
```

## Project-Specific Conventions

**Widget Construction**:
- Use `withValues(alpha: 0.05)` instead of deprecated `withOpacity()`
- Consistent spacing: `SizedBox(height: 120)` for bottom nav clearance
- Use Google Fonts: `GoogleFonts.notoSansThaiTextTheme()` for Thai support

**Navigation Pattern**:
- Custom island-style bottom navigation in `BottomNavigationIsland`
- Page changes via `currentPageProvider` state, not route changes
- Use `PageController` in `AuthedLayout` for smooth transitions
- Custom `NoAnimationPageTransitionsBuilder` disables page animations

**Firebase Integration**:
- Environment-based config through `EnvConfig` class
- Use `firebase_options.dart` generated file (not manually edited)
- Models like `Habit` include Firestore serialization methods
- Service pattern: `FirestoreService`, `HabitService` with Riverpod providers

**Localization**:
- ARB files in `lib/l10n/app_{locale}.arb`
- Access via `AppLocalizations.of(context)!.keyName`
- Language switching through `languageProvider` and `SharedPreferences`
- Support Thai with `GoogleFonts.notoSansThaiTextTheme`

## Common Patterns & Examples

**Riverpod Service Pattern**:
```dart
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
// Use: ref.read(authServiceProvider).someMethod()
```

**Localized Widget Pattern**:
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.navigationHome)  // Uses ARB translations
```

**Firebase Model Pattern**:
```dart
// Models include toMap()/fromMap() for Firestore
factory Habit.fromMap(Map<String, dynamic> map) { ... }
Map<String, dynamic> toMap() { ... }
```

**Bottom Navigation Integration**:
```dart
bottomNavigationBar: BottomNavigationIsland(),
extendBody: true,  // For floating nav effect
```

## Testing & Debugging

**Run Tests**: `flutter test` (currently basic widget test in `test/widget_test.dart`)
**Debug Mode**: Use VS Code Flutter extension or `flutter run --debug`
**Firebase Debug**: Check console logs with `developer.log()` pattern used in `AuthService`

## Integration Points

**Firebase Services**: Auth, Firestore via `firebase_core` initialization in `main.dart`
**Environment Variables**: Managed through `.env` file and `EnvConfig` class
**Platform Support**: Android, iOS, Web (configured splash screens for all)
**Asset Management**: Uses `flutter_native_splash` package for consistent splash screens

Focus on maintaining the established patterns rather than introducing new architectural approaches.
