import java.util.Properties

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
    // ✅ key.properties oku
    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(keystorePropertiesFile.inputStream())
    }

    // ✅ Hangi için doğru namespace
    namespace = "com.hangi.app"

    // Şimdilik Flutter'dan gelen değerler kalsın
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
        // ✅ Hangi için doğru applicationId
        applicationId = "com.hangi.app"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ✅ Release signing config (upload-keystore.jks)
    signingConfigs {
        create("release") {
            keyAlias = (keystoreProperties["keyAlias"] as String)
            keyPassword = (keystoreProperties["keyPassword"] as String)
            storeFile = file("upload-keystore.jks") // android/app/upload-keystore.jks
            storePassword = (keystoreProperties["storePassword"] as String)
        }
    }

    buildTypes {
        release {
            // ✅ Play Store için doğru: release imzası
            signingConfig = signingConfigs.getByName("release")

            // (İstersen sonra açarız) küçültme/obfuscation şimdilik kapalı kalsın:
            // isMinifyEnabled = false
            // isShrinkResources = false
        }
        debug {
            // debug default zaten debug ile imzalanır, dokunmaya gerek yok
        }
    }
}

flutter {
    source = "../.."
}
