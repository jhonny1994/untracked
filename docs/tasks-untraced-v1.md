# UNTRACED v1.0 - Task List

> **Tech Stack:** Flutter 3.x, Riverpod (code-gen), Freezed, Material You, Dynamic Theme, Flutter Intl, GitHub Actions  
> **Architecture:** Lite DDD (Feature-First) with barrel files  
> **URL Strategy:** Direct HTTP redirect with mobile browser headers  
> **Mode:** Online-only

---

## Project Structure

```
lib/
├── main.dart
├── application/
│   ├── app.dart
│   ├── router.dart
│   ├── theme.dart
│   └── application.dart          # barrel
├── core/
│   ├── constants.dart
│   ├── clipboard_service.dart
│   ├── haptic_service.dart
│   ├── http_client.dart
│   └── core.dart                 # barrel
├── features/
│   ├── features.dart             # barrel
│   └── url_cleaner/
│       ├── url_cleaner.dart      # feature barrel
│       ├── domain/
│       ├── infrastructure/
│       ├── application/
│       └── presentation/
│           └── widgets/
├── generated/                    # Flutter Intl generated (do not edit)
│   └── l10n.dart
└── l10n/
    ├── intl_en.arb
    └── intl_ar.arb
```

---

## Notes

- **Code gen:** `dart run build_runner build --delete-conflicting-outputs`
- **PRD:** `docs/prd-untraced.md`

---

## Tasks

### 0.0 Version Control Setup
- [x] 0.1 `git init`
- [x] 0.2 Initial commit
- [ ] 0.3 Create GitHub repository
- [ ] 0.4 `git remote add origin <url> && git push -u origin main`

### 1.0 Very Good CLI Setup
- [ ] 1.1 Install Very Good CLI:
  ```bash
  dart pub global activate very_good_cli
  ```
- [ ] 1.2 Create Flutter app (in existing project or new):
  ```bash
  very_good create flutter_app . --org com.untraced
  ```
  > Note: Use `.` to create in current directory

### 2.0 Dependencies Setup
- [ ] 2.1 Add runtime dependencies:
  ```bash
  flutter pub add flutter_riverpod riverpod_annotation freezed_annotation json_annotation
  flutter pub add http connectivity_plus receive_sharing_intent
  flutter pub add dynamic_color go_router share_plus
  flutter pub add flutter_localizations --sdk=flutter
  ```
- [ ] 2.2 Add dev dependencies:
  ```bash
  flutter pub add --dev build_runner riverpod_generator riverpod_lint
  flutter pub add --dev freezed json_serializable custom_lint
  ```

### 3.0 Flutter Intl Setup (VS Code Extension)
- [ ] 3.1 Install VS Code extension: `localizely.flutter-intl`
- [ ] 3.2 Open Command Palette → `Flutter Intl: Initialize`
  > Creates `lib/l10n/intl_en.arb` and `lib/generated/` folder
- [ ] 3.3 Add to `pubspec.yaml`:
  ```yaml
  flutter_intl:
    enabled: true
    class_name: S
    main_locale: en
    arb_dir: lib/l10n
    output_dir: lib/generated
  ```
- [ ] 3.4 Setup MaterialApp with localization:
  ```dart
  import 'package:flutter_localizations/flutter_localizations.dart';
  import 'generated/l10n.dart';
  
  MaterialApp(
    localizationsDelegates: [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
  )
  ```
- [ ] 3.5 Add Arabic locale: Command Palette → `Flutter Intl: Add locale` → `ar`

### 4.0 Project Configuration
- [ ] 4.1 Configure Android manifest (Share Intent, INTERNET, VIBRATE)
- [ ] 4.2 Create folder structure with barrel files
- [ ] 4.3 Configure `analysis_options.yaml`
- [ ] 4.4 Configure `build.yaml`

### 5.0 Application Layer
- [ ] 5.1 `app.dart` - MaterialApp with theme, router, localization
- [ ] 5.2 `router.dart` - GoRouter configuration
- [ ] 5.3 `theme.dart` - Material You dynamic theming (#208299)
- [ ] 5.4 `application.dart` - Barrel file

### 6.0 Core Layer
- [ ] 6.1 `constants.dart` - Regex patterns, timeouts, User-Agent
- [ ] 6.2 `clipboard_service.dart` - Clipboard operations
- [ ] 6.3 `haptic_service.dart` - Haptic feedback
- [ ] 6.4 `http_client.dart` - HTTP client with Chrome Mobile headers
- [ ] 6.5 `core.dart` - Barrel file

### 7.0 URL Cleaner - Domain
- [ ] 7.1 `tiktok_url.dart` - @freezed entity
- [ ] 7.2 `clean_result.dart` - @freezed entity
- [ ] 7.3 `processing_state.dart` - @freezed union
- [ ] 7.4 `domain.dart` - Barrel file
- [ ] 7.5 Run code generation

### 8.0 URL Cleaner - Infrastructure
- [ ] 8.1 `redirect_service.dart` - HTTP redirects (5 hops, 10s timeout, mobile headers)
- [ ] 8.2 `url_parser.dart` - Regex extraction (video ID, username)
- [ ] 8.3 `url_cleaner_service.dart` - Orchestration
- [ ] 8.4 `infrastructure.dart` - Barrel file

### 9.0 URL Cleaner - Application
- [ ] 9.1 `url_cleaner_notifier.dart` - @riverpod AsyncNotifier
- [ ] 9.2 Implement `processUrl()`
- [ ] 9.3 Implement `copyToClipboard()` with haptics
- [ ] 9.4 Implement `shareCleanUrl()`
- [ ] 9.5 Implement `reset()`
- [ ] 9.6 `application.dart` - Barrel file
- [ ] 9.7 Run code generation

### 10.0 URL Cleaner - Presentation
- [ ] 10.1 `input_screen.dart` - Text field, paste, process
- [ ] 10.2 `processing_screen.dart` - Loading spinner
- [ ] 10.3 `result_screen.dart` - Success/error with before/after
- [ ] 10.4 `widgets/tracking_badge.dart`
- [ ] 10.5 `widgets/url_comparison_card.dart`
- [ ] 10.6 `widgets/action_button.dart`
- [ ] 10.7 `widgets/widgets.dart` - Barrel file
- [ ] 10.8 `presentation.dart` - Barrel file

### 11.0 Feature Integration
- [ ] 11.1 `url_cleaner.dart` - Feature barrel
- [ ] 11.2 `features.dart` - Features barrel
- [ ] 11.3 Wire up routes
- [ ] 11.4 Update `main.dart` with ProviderScope

### 12.0 Share Intent
- [ ] 12.1 Configure `AndroidManifest.xml` intent-filter
- [ ] 12.2 Integrate receive_sharing_intent
- [ ] 12.3 Detect shared URL on launch/resume
- [ ] 12.4 Auto-navigate to processing
- [ ] 12.5 Handle edge cases

### 13.0 Error Handling
- [ ] 13.1 Network errors
- [ ] 13.2 Rate limiting (HTTP 429)
- [ ] 13.3 Cloudflare blocks
- [ ] 13.4 Regex extraction failures
- [ ] 13.5 Clipboard failures
- [ ] 13.6 All errors have "Try Again" button

### 14.0 Internationalization Strings
- [ ] 14.1 Add all English strings to `intl_en.arb`
- [ ] 14.2 Add Arabic translations to `intl_ar.arb`
- [ ] 14.3 Integrate `S.of(context)` throughout app

### 15.0 App Polish
- [ ] 15.1 Dynamic theme switching (light/dark/system)
- [ ] 15.2 App icon and splash screen
- [ ] 15.3 App name and package ID
- [ ] 15.4 Performance optimization

### 16.0 GitHub Actions CI/CD
- [ ] 16.1 `debug.yml` - Lint, analyze, build
- [ ] 16.2 `release.yml` - Signed production build
- [ ] 16.3 Configure signing secrets
- [ ] 16.4 APK/AAB artifact upload

### 17.0 Store Preparation
- [ ] 17.1 Privacy policy (zero data collection)
- [ ] 17.2 Host privacy policy
- [ ] 17.3 Play Store assets
- [ ] 17.4 App icon (all sizes)
- [ ] 17.5 Verify APK size (<30MB)
- [ ] 17.6 Final PRD verification
