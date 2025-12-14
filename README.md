# Untracked

<p align="center">
  <img src="android/app/src/main/res/mipmap-xxxhdpi/launcher_icon.png" alt="Untracked Logo" width="120"/>
</p>

<p align="center">
  <strong>Privacy-first TikTok URL cleaner</strong><br>
  Remove tracking parameters. Share links privately.
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#testing">Testing</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## Features

### 🔗 URL Cleaning
- **Deep Parameter Removal** — Strips `?share_source`, `?sec_uid`, `?_r`, and all tracking parameters
- **Link Expansion** — Resolves shortened links (`vt.tiktok.com`, `vm.tiktok.com`) to canonical URLs
- **Smart Offline Mode** — Cleans canonical URLs locally without network requests
- **Dirty Input Handling** — Extracts valid URLs from mixed text

### 🛡️ Privacy First
- **Zero Data Collection** — No analytics, no tracking, no external services
- **On-Device Processing** — Everything happens on your device
- **No Account Required** — Just paste and share

### 🎨 Modern Design
- **Material 3** — Dynamic theming with Material You support
- **Dark/Light Modes** — Follows system preference
- **Responsive Layout** — Works on phones, tablets, and desktop
- **Accessibility** — WCAG AA compliant with full screen reader support

### 🌍 Internationalization
- English (en)
- العربية (ar) with RTL support
- Français (fr)

---

## Installation

### Prerequisites
- Flutter SDK `^3.9.2`
- Dart SDK `^3.0.0`

### Quick Start

```bash
# Clone repository
git clone https://github.com/jhonny1994/untracked.git
cd untracked

# Install dependencies
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Run app
flutter run
```

### Release Build

```bash
# Android
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## Architecture

Domain-Driven Design (DDD) with clean separation of concerns.

```
lib/
├── application/          # App configuration, routing, theming
├── core/                 # Shared utilities, constants, l10n
│   ├── http/            # HTTP client with retry logic
│   ├── l10n/            # Localization (EN, AR, FR)
│   └── services/        # Clipboard, haptics, logging
└── features/
    ├── url_cleaner/     # Main feature
    │   ├── domain/      # Business entities
    │   ├── application/ # State management (Riverpod)
    │   ├── infrastructure/ # Services
    │   └── presentation/   # UI screens
    ├── link_history/    # History feature
    └── settings/        # App settings
```

### Tech Stack

| Layer | Technology |
|-------|------------|
| State Management | Riverpod + riverpod_annotation |
| Navigation | GoRouter |
| Data Classes | Freezed + json_serializable |
| HTTP | http package with custom client |
| Storage | Hive CE |
| Linting | very_good_analysis |

---

## Testing

68 unit tests covering all critical business logic.

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/url_parser_test.dart
```

### Test Coverage

| Component | Tests | Coverage |
|-----------|-------|----------|
| UrlParser | 27 | URL validation, parsing, building |
| UrlCleanerService | 11 | Cleaning logic, offline mode |
| HTTP Utilities | 30 | Redirects, errors, patterns |
| **Total** | **68** | **100% pass rate** |

---

## Accessibility

WCAG 2.1 Level AA compliant.

- ✅ Semantic labels on all interactive elements
- ✅ Screen reader hints for buttons
- ✅ Live regions for state announcements
- ✅ RTL support for Arabic
- ✅ Material 3 contrast compliance
- ✅ Touch targets ≥ 48x48dp

---

## CI/CD

GitHub Actions workflows for quality and releases.

### Continuous Integration
- Code analysis (`flutter analyze`)
- Test execution (`flutter test --coverage`)
- Coverage reporting (Codecov)

### Release Pipeline
- Automated APK/AAB builds
- Signed releases
- GitHub release artifacts

---

## Contributing

Contributions welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'feat: Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Code Style
- Run `flutter analyze` before committing
- Follow existing naming conventions
- Add tests for new features

---

## Privacy Policy

**Untracked collects zero data.**

- No analytics
- No crash reports sent externally
- No user tracking
- No network requests except URL processing
- All data stays on your device

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with ❤️ for privacy
</p>
