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
- [x] 0.3 Create GitHub repository
- [x] 0.4 `git remote add origin <url> && git push -u origin main`

### 1.0 Very Good Setup
- [x] 1.1 Install Very Good CLI: `dart pub global activate very_good_cli`
- [x] 1.2 ~~Create Flutter app~~ (skipped - using existing project)
- [x] 1.3 Add very_good_analysis: `flutter pub add --dev very_good_analysis`

### 2.0 Dependencies Setup
- [x] 2.1 Add runtime dependencies:
  ```bash
  flutter pub add flutter_riverpod riverpod_annotation freezed_annotation json_annotation
  flutter pub add http connectivity_plus receive_sharing_intent
  flutter pub add dynamic_color go_router share_plus
  flutter pub add flutter_localizations --sdk=flutter
  ```
- [x] 2.2 Add dev dependencies:
  ```bash
  flutter pub add --dev build_runner riverpod_generator riverpod_lint
  flutter pub add --dev freezed json_serializable custom_lint very_good_analysis
  ```

### 3.0 Flutter Intl Setup (VS Code Extension)
- [x] 3.1 Install VS Code extension: `localizely.flutter-intl`
- [x] 3.2 Open Command Palette → `Flutter Intl: Initialize`
  > Creates `lib/core/l10n/l10n/intl_en.arb` and `lib/core/l10n/generated/` folder
- [x] 3.3 Add to `pubspec.yaml`:
  ```yaml
  flutter_intl:
    enabled: true
    class_name: S
    main_locale: en
    arb_dir: lib/core/l10n/l10n
    output_dir: lib/core/l10n/generated
  ```
- [x] 3.4 Setup MaterialApp with localization
- [x] 3.5 Add Arabic locale: Command Palette → `Flutter Intl: Add locale` → `ar`

### 4.0 Project Configuration
- [x] 4.1 Configure Android manifest (Share Intent, INTERNET, VIBRATE)
- [x] 4.2 Create folder structure with barrel files
- [x] 4.3 Configure `analysis_options.yaml` (very_good_analysis + custom_lint)
- [x] 4.4 Configure `build.yaml`

### 5.0 Application Layer
- [x] 5.1 `app.dart` - MaterialApp with theme, router, localization
- [x] 5.2 `router.dart` - GoRouter configuration (using Ref)
- [x] 5.3 `theme.dart` - Material You dynamic theming (#208299)
- [x] 5.4 `application.dart` - Barrel file

### 6.0 Core Layer
- [x] 6.1 `constants.dart` - Regex patterns, timeouts, User-Agent
- [x] 6.2 `clipboard_service.dart` - Clipboard operations
- [x] 6.3 `haptic_service.dart` - Haptic feedback
- [x] 6.4 `http_client.dart` - HTTP client with Chrome Mobile headers
- [x] 6.5 `core.dart` - Barrel file

### 7.0 URL Cleaner - Domain
- [x] 7.1 `tiktok_url.dart` - @freezed entity
- [x] 7.2 `clean_result.dart` - @freezed entity
- [x] 7.3 `processing_state.dart` - @freezed union
- [x] 7.4 `domain.dart` - Barrel file
- [x] 7.5 Run code generation

### 8.0 URL Cleaner - Infrastructure
- [x] 8.1 `redirect_service.dart` - HTTP redirects (5 hops, 10s timeout, mobile headers)
- [x] 8.2 `url_parser.dart` - Regex extraction (video ID, username)
- [x] 8.3 `url_cleaner_service.dart` - Orchestration
- [x] 8.4 `infrastructure.dart` - Barrel file

### 9.0 URL Cleaner - Application
- [x] 9.1 `url_cleaner_notifier.dart` - @riverpod AsyncNotifier
- [x] 9.2 Implement `processUrl()`
- [x] 9.3 Implement `copyToClipboard()` with haptics
- [x] 9.4 Implement `shareCleanUrl()`
- [x] 9.5 Implement `reset()`
- [x] 9.6 `application.dart` - Barrel file
- [x] 9.7 Run code generation

### 10.0 URL Cleaner - Presentation
- [x] 10.1 `input_screen.dart` - Text field, paste, process
- [x] 10.2 `processing_screen.dart` - Loading spinner
- [x] 10.3 `result_screen.dart` - Success/error with before/after
- [x] 10.4 `widgets/tracking_badge.dart`
- [x] 10.5 `widgets/url_comparison_card.dart`
- [x] 10.6 `widgets/action_button.dart`
- [x] 10.7 `widgets/widgets.dart` - Barrel file
- [x] 10.8 `presentation.dart` - Barrel file

### 11.0 Feature Integration
- [x] 11.1 `url_cleaner.dart` - Feature barrel
- [x] 11.2 `features.dart` - Features barrel
- [x] 11.3 Wire up routes
- [x] 11.4 Update `main.dart` with ProviderScope

### 12.0 Share Intent
- [x] 12.1 Configure `AndroidManifest.xml` intent-filter
- [x] 12.2 Integrate receive_sharing_intent
- [x] 12.3 Detect shared URL on launch/resume
- [x] 12.4 Auto-navigate to processing
- [x] 12.5 Handle edge cases

### 13.0 Error Handling
- [x] 13.1 Network errors
- [x] 13.2 Rate limiting (HTTP 429)
- [x] 13.3 Cloudflare blocks
- [x] 13.4 Regex extraction failures
- [x] 13.5 Clipboard failures
- [x] 13.6 All errors have "Try Again" button

### 14.0 Internationalization Strings
- [x] 14.1 Add all English strings to `intl_en.arb`
- [x] 14.2 Add Arabic translations to `intl_ar.arb`
- [x] 14.3 Integrate `S.of(context)` throughout app

### 15.0 App Polish
- [x] 15.1 Dynamic theme switching (light/dark/system)
- [ ] 15.2 App icon and splash screen
- [ ] 15.3 App name and package ID
- [x] 15.4 Performance optimization

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
