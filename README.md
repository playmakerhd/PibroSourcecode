# pibro

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Build Release AAB

1. Create an upload keystore (one-time):
	- `keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Copy `android/key.properties.example` to `android/key.properties` and fill in real values.
3. Build the app bundle:
	- `flutter build appbundle --release`
4. Output bundle location:
	- `build/app/outputs/bundle/release/app-release.aab`
