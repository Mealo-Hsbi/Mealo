plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.frontend"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    // ---- SigningConfigs für euren gemeinsamen Keystore ----
    signingConfigs {
        // Release-Config anlegen
        create("release") {
            storeFile = file("keystore/apprelease.jks")
            storePassword = "Speedy2024"
            keyAlias = "appreleasekey"
            keyPassword = "Speedy2024"
        }
        // Default-Debug überschreiben, damit auch Debug mit demselben Keystore baut
        getByName("debug").apply {
            storeFile = file("keystore/apprelease.jks")
            storePassword = "Speedy2024"
            keyAlias = "appreleasekey"
            keyPassword = "Speedy2024"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.frontend"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
