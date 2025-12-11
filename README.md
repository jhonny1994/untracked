# Untracked

**Untracked** is a privacy-focused Flutter application designed to strip tracking parameters from TikTok URLs. It ensures that the links you share are clean, private, and go directly to the content without exposing your profile or tracking data.

## Features

-   **Deep URL Cleaning**: Removes `?share_source`, `?sec_uid`, and other tracking parameters from TikTok links.
-   **Link Expansion**: Automatically resolves shortened links (e.g., `vt.tiktok.com`, `vm.tiktok.com`) to their canonical forms.
-   **Smart Offline Mode**: intelligently detects if a URL is already canonical and cleans it locally without making network requests, preserving privacy and speed.
-   **Dirty Input Handling**: Extracts valid TikTok URLs even from mixed text (e.g., "Check this out! https://tiktok.com/...").
-   **Resilient Fallback**: If network resolution fails (e.g., 403 Forbidden), it attempts to clean the URL using regex pattern matching.
-   **Cross-Platform**: Fully responsive design that works seamlessly on iOS, Android, and Desktop (Windows/macOS/Linux).
-   **Material 3 Design**: A modern, adaptive UI with support for dynamic theming and dark/light modes.
-   **Internationalization**: localized support for English (default) with infrastructure for easy expansion.

## Getting Started

### Prerequisites

-   Flutter SDK: `^3.9.2`
-   Dart SDK: `^3.0.0`

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/jhonny1994/untracked.git
    cd untracked
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the code generator:**
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the app:**
    ```bash
    flutter run
    ```

## Architecture

The project follows a **Domain-Driven Design (DDD)** inspired architecture with **Riverpod** for state management.

-   **Application Layer**: Contains logic that coordinates user interactions (e.g., `UrlCleanerNotifier`).
-   **Domain Layer**: Defines core business objects and failure definitions (e.g., `CleanResult`, `ProcessingError`).
-   **Infrastructure Layer**: Implements external services and data handling (e.g., `UrlCleanerService`, `RedirectService`, `UrlParser`).
-   **Presentation Layer**: FLutter widgets and screens responsible for the UI (e.g., `InputScreen`, `ResultScreen`).

### Key Libraries

-   `flutter_riverpod`: State management and dependency injection.
-   `go_router`: declarative routing.
-   `share_plus` & `receive_sharing_intent`: Mobile sharing capabilities.
-   `http`: Network requests.
-   `freezed` & `json_serializable`: Immutable data classes.

## Contributing

Contributions are welcome! Please follow the standard pull request workflow.

1.  Fork the repository.
2.  Create a feature branch (`git checkout -b feature/amazing-feature`).
3.  Commit your changes (`git commit -m 'feat: Add amazing feature'`).
4.  Push to the branch (`git push origin feature/amazing-feature`).
5.  Open a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
