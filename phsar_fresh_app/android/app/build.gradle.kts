import java.util.Base64

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Flutter passes config.json values as base64-encoded Dart defines.
// Use the same platform key in Dart and the native Maps SDK.
val dartDefines = (project.findProperty("dart-defines") as? String)
    .orEmpty()
    .split(",")
    .filter { it.isNotBlank() }
    .mapNotNull {
        val decoded = String(Base64.getDecoder().decode(it), Charsets.UTF_8)
        val pair = decoded.split("=", limit = 2)
        if (pair.size == 2) pair[0] to pair[1] else null
    }
    .toMap()

android {
    namespace = "com.example.phsar_fresh_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.phsar_fresh_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["GOOGLE_MAPS_ANDROID_API_KEY"] =
            dartDefines["GOOGLE_MAPS_ANDROID_API_KEY"]?.trim().orEmpty()
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
