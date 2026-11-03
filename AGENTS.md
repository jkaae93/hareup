# Repository Guidelines

## Project Structure & Module Organization

Hareup (하릅) is a Flutter application for Android and iOS. The current app is a starter counter implementation.

- `lib/main.dart`: application entry point, theme, and initial screen. Extract new screens and reusable widgets into focused Dart files under `lib/` as features grow.
- `test/widget_test.dart`: Flutter widget smoke test.
- `android/` and `ios/`: native platform projects, launcher assets, and build configuration. Native iOS tests live in `ios/RunnerTests/`.
- `design/hareup-all-design.pdf`: design reference.
- `pubspec.yaml`: dependencies, SDK constraint (`^3.11.4`), and Flutter asset declarations. No custom Flutter assets are currently registered.
- `build/` and `.dart_tool/`: generated output; do not edit or commit.

## Build, Test, and Development Commands

Run commands from the repository root:

- `flutter pub get`: install dependencies.
- `flutter devices`: list available devices and simulators.
- `flutter run`: launch locally; use `-d <device-id>` to select a target.
- `dart format lib test`: format Dart source and tests.
- `flutter analyze`: run static analysis and configured lints.
- `flutter test`: run the Flutter test suite.
- `flutter build apk --debug`: build a debug Android APK.
- `flutter build ios --simulator --debug`: build for the iOS simulator on macOS with Xcode.

## Coding Style & Naming Conventions

Use two-space indentation and let `dart format` determine layout. Follow `flutter_lints`, enabled in `analysis_options.yaml`. Name files with `lower_snake_case.dart`, types with `UpperCamelCase`, and members with `lowerCamelCase`. Use `_` prefixes for private declarations and `const` constructors where appropriate. Keep widget build methods focused by extracting reusable components.

## Testing Guidelines

Use `flutter_test` and name test files `*_test.dart`. Add widget tests for user interactions and unit tests for extracted logic. The existing test verifies counter increments using `testWidgets`, taps, and assertions. Run a focused test with `flutter test test/widget_test.dart`. No coverage threshold is configured; cover changed behavior and run analysis and tests before submitting.

## Commit & Pull Request Guidelines

This checkout has no Git metadata, so commit conventions cannot be verified. Use concise, imperative commit subjects. Keep changes focused. PRs should describe the behavior change, link relevant issues, list validation commands and results, and include screenshots for UI changes. Mention platform-specific effects and any configuration steps.

## Configuration Tips

Keep credentials, signing keys, and local SDK paths out of commits. For Android setup, use `flutter doctor --android-licenses` when needed. Configure the development team and provisioning in Xcode for physical iOS devices.
