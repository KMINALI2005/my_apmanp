plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {    
    namespace = "com.example.my_apmanp"
    // Use a stable SDK version. 34 is the current stable version.
    compileSdk = 34
    // ndkVersion is managed by Flutter, so it's safer to remove it unless you need a specific version.
    // ndkVersion = "25.1.8937393"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.my_apmanp"
        // minSdk is defined by Flutter, but 21 is a safe default.
        minSdk = 21
        // Target SDK should match compile SDK.
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
