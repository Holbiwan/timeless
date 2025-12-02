plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")    // plugin application

}

android {
    namespace = "com.example.timeless"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.timeless"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_17.toString() }

    buildTypes {
        debug { isMinifyEnabled = false; isShrinkResources = false }
        release { isMinifyEnabled = false; isShrinkResources = false }
    }

    packaging {
        resources {
            excludes += setOf("META-INF/AL2.0", "META-INF/LGPL2.1")
        }
    }
}

flutter { source = "../.." }

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    //  Firebase BoM: handle versions of the Firebase modules
    implementation(platform("com.google.firebase:firebase-bom:32.8.1"))

    //  Firebase modules used in the app
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
    implementation("com.google.firebase:firebase-messaging")

    //  Google Sign-In (used by plugin google_sign_in)
    implementation("com.google.android.gms:play-services-auth:20.7.0")

    // Custom Tabs for OAuth Google via navigator
    implementation("androidx.browser:browser:1.8.0")
}
