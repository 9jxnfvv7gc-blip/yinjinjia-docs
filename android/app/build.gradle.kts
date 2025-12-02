plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.xiaohui.video_music_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 构建变体：区分Google Play版本和中国商店版本
    flavorDimensions += "store"
    productFlavors {
        create("googleplay") {
            dimension = "store"
            applicationId = "com.xiaohui.videomusicapp.googleplay"
            // Google Play版本：完整功能（上传视频）
            resValue("string", "app_name", "小船")
        }
        create("domestic") {
            dimension = "store"
            applicationId = "com.xiaohui.videomusicapp.domestic"
            // 中国商店版本：链接版本（只转发链接）
            resValue("string", "app_name", "小船")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
