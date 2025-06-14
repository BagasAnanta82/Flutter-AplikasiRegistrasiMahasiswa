plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter plugin harus terakhir
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.tubesapb"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.tubesapb"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Gunakan debug signing config agar bisa build APK release tanpa crash
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Opsional: untuk memastikan nama APK lebih informatif
    applicationVariants.all {
        outputs.all {
            val outputImpl = this as com.android.build.gradle.internal.api.BaseVariantOutputImpl
            outputImpl.outputFileName = "app-${versionName}.apk"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.10.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
