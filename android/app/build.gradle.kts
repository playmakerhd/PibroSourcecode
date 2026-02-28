plugins {
    id("com.android.application")
    id("kotlin-android")
    // Google services plugin (used to process google-services.json)
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.powersoft.pibro"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.powersoft.pibro"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// Firebase dependencies: use the BoM so versions are managed centrally.
dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.5.0"))

    // Firebase Analytics (no version when using the BoM)
    implementation("com.google.firebase:firebase-analytics")

    // TODO: Add other Firebase SDKs you need, for example:
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
}

flutter {
    source = "../.."
}
