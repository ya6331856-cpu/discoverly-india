from pathlib import Path
import re

build_file = Path("android/app/build.gradle.kts")
manifest_file = Path("android/app/src/main/AndroidManifest.xml")
if not build_file.exists() or not manifest_file.exists():
    raise SystemExit("Flutter Android project was not generated as expected")

build = build_file.read_text()
replacements = {
    'namespace = "com.discoverly.discoverly"': 'namespace = "com.discoverly.app"',
    'applicationId = "com.discoverly.discoverly"': 'applicationId = "com.discoverly.app"',
    'compileSdk = flutter.compileSdkVersion': 'compileSdk = 36',
    'targetSdk = flutter.targetSdkVersion': 'targetSdk = 36',
    'signingConfig = signingConfigs.getByName("debug")': 'signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") else signingConfigs.getByName("debug")',
}
for old, new in replacements.items():
    if old not in build:
        raise SystemExit(f"Expected Android Gradle setting not found: {old}")
    build = build.replace(old, new, 1)

if 'val keystoreProperties = Properties()' not in build:
    build = 'import java.io.FileInputStream\nimport java.util.Properties\n\n' + build
    setup = '''val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

'''
    if 'android {' not in build:
        raise SystemExit("Android block not found")
    build = build.replace('android {', setup + 'android {', 1)

signing = '''signingConfigs {
    create("release") {
        if (keystorePropertiesFile.exists()) {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
}

'''
if 'create("release")' not in build:
    build = build.replace('buildTypes {', signing + 'buildTypes {', 1)

build_file.write_text(build)
manifest = manifest_file.read_text()
manifest = re.sub(r'android:label="[^"]+"', 'android:label="DISCOVERLY"', manifest, count=1)
manifest = re.sub(r'android:allowBackup="[^"]+"', 'android:allowBackup="false"', manifest, count=1)
if 'android:allowBackup=' not in manifest:
    manifest = manifest.replace('<application', '<application android:allowBackup="false"', 1)
if 'android:usesCleartextTraffic=' not in manifest:
    manifest = manifest.replace('<application', '<application android:usesCleartextTraffic="false"', 1)
manifest_file.write_text(manifest)

kotlin_root = Path("android/app/src/main/kotlin")
activity_files = list(kotlin_root.rglob("MainActivity.kt"))
if not activity_files:
    raise SystemExit("Generated MainActivity.kt was not found")
target_activity = kotlin_root / "com/discoverly/app/MainActivity.kt"
target_activity.parent.mkdir(parents=True, exist_ok=True)
activity_content = activity_files[0].read_text()
activity_content = re.sub(r"^package [^\\n]+", "package com.discoverly.app", activity_content, count=1, flags=re.MULTILINE)
target_activity.write_text(activity_content)
if activity_files[0] != target_activity:
    activity_files[0].unlink()

print("Android package ID, API 36, app label, backup setting, Kotlin namespace and upload signing configuration prepared.")
