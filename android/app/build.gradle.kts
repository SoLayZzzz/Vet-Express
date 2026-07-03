import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val keystorePropertiesFileAlt = file("key.properties")
val activeKeystorePropertiesFile = when {
    keystorePropertiesFile.exists() -> keystorePropertiesFile
    keystorePropertiesFileAlt.exists() -> keystorePropertiesFileAlt
    else -> keystorePropertiesFile
}
if (activeKeystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(activeKeystorePropertiesFile))
}

val hasReleaseSigningConfig = activeKeystorePropertiesFile.exists() &&
    listOf(
        "keyAlias",
        "keyPassword",
        "storeFile",
        "storePassword",
    ).all { key ->
        !keystoreProperties.getProperty(key).isNullOrBlank()
    }

android {
    namespace = "vireak_bunthan.udaya.com.vet_logistic"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "vireak_bunthan.udaya.com.vet_logistic"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 124
        versionName = "2.1.3"
    }

    signingConfigs {
        if (hasReleaseSigningConfig) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        getByName("release") {
            if (hasReleaseSigningConfig) {
                signingConfig = signingConfigs.getByName("release")
            }
            isShrinkResources = true
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            isMinifyEnabled = false
        }
    }

    // Define flavors so QA and Prod can be installed side-by-side
    flavorDimensions += "env"
    productFlavors {
        create("qa") {
            dimension = "env"
            applicationIdSuffix = ".qa"
            versionNameSuffix = "-qa"
            manifestPlaceholders["appName"] = "VET Express QA"
            manifestPlaceholders["deeplinkScheme"] = "vetappqa"
        }
        create("prod") {
            dimension = "env"
            manifestPlaceholders["appName"] = "VET Express"
            manifestPlaceholders["deeplinkScheme"] = "vetapp"
        }
    }
}
tasks.matching { task ->
    task.name.endsWith("Release", ignoreCase = true)
}.configureEach {
    doFirst {
        if (!hasReleaseSigningConfig) {
            throw GradleException(
                "Missing release signing config. Create android/key.properties (or android/app/key.properties) with " +
                    "keyAlias, keyPassword, storeFile, storePassword, and ensure the keystore file exists."
            )
        }
    }
}

dependencies {
    implementation("androidx.core:core-splashscreen:1.0.1")
}

flutter {
    source = "../.."
}
