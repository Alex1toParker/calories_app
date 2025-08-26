plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
<<<<<<< HEAD
    id("com.google.gms.google-services")
=======
    id("com.google.gms.google-services") // ← LÍNEA AÑADIDA
>>>>>>> 2bd84b42030973378e2bcbb9925d85b2a46b0add
}

android {
    namespace = "com.betterme.app"
<<<<<<< HEAD
    compileSdk = 34
    ndkVersion = "27.0.12077973"
=======
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
>>>>>>> 2bd84b42030973378e2bcbb9925d85b2a46b0add

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.betterme.app"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0.0"
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

// ELIMINAR ESTA LÍNEA: apply plugin: 'com.google.gms.google-services'
<<<<<<< HEAD
// NO añadir apply() si ya usaste el bloque plugins
=======
// NO añadir apply() si ya usaste el bloque plugins
>>>>>>> 2bd84b42030973378e2bcbb9925d85b2a46b0add
