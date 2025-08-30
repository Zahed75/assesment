// Needed for output file renaming
import com.android.build.gradle.internal.api.BaseVariantOutputImpl
import java.util.Properties // ← ADD THIS IMPORT

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Must be applied after the Android & Kotlin plugins
    id("dev.flutter.flutter-gradle-plugin")
}

// ✅ Load environment variables or use fallback values
// Temporary hardcoded path for testing
val keystoreProperties = Properties().apply {
    setProperty("storePassword", "ZahedACI2025")
    setProperty("keyPassword", "ZahedACI2025")
    setProperty("keyAlias", "upload")
    setProperty("storeFile", "upload-keystore.jks") 
}

android {
    namespace = "com.example.assesment"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.1.13356709"

    defaultConfig {
        applicationId = "com.example.assesment"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    // ✅ Updated signingConfigs to use your custom keystore
    signingConfigs {
        getByName("debug") {
            // Keep debug config as is, or update to use your keystore for consistency
            storeFile = file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
        }
        
        create("release") {
            storeFile = file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
            // Sign debug with the same key → allows seamless updating during dev
            signingConfig = signingConfigs.getByName("release")
        }
    }

    buildFeatures {
        buildConfig = true
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // ✅ rename APK to include version for your backend
    applicationVariants.all {
        outputs.all {
            val output = this as BaseVariantOutputImpl
            val apkName = "app-${defaultConfig.versionName}+${defaultConfig.versionCode}.apk"
            output.outputFileName = apkName
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

// This block must be at top level (not inside android {})
flutter {
    source = "../.."
}

// Optional: quiet a Kotlin compiler warning in some setups
tasks.withType<JavaCompile>().configureEach {
    options.compilerArgs.add("-Xlint:-options")
}