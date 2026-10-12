// Fix AGP conflict when both ANDROID_PREFS_ROOT and ANDROID_USER_HOME environment variables exist
runCatching {
    val pe = Class.forName("java.lang.ProcessEnvironment")
    val fields = listOf("theCaseInsensitiveEnvironment", "theEnvironment", "theUnmodifiableEnvironment")
    for (fieldName in fields) {
        runCatching {
            val field = pe.getDeclaredField(fieldName)
            field.isAccessible = true
            @Suppress("UNCHECKED_CAST")
            val map = field.get(null) as? MutableMap<String, String>
            map?.remove("ANDROID_PREFS_ROOT")
            map?.remove("android_prefs_root")
        }
    }
}

pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.4.4") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")
