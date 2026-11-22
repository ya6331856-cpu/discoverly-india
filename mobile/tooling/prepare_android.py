from pathlib import Path
import os
import re

build_file = Path("android/app/build.gradle.kts")
root_build_file = Path("android/build.gradle.kts")
manifest_file = Path("android/app/src/main/AndroidManifest.xml")
if not build_file.exists() or not root_build_file.exists() or not manifest_file.exists():
    raise SystemExit("Flutter Android project was not generated as expected")

flutter_root = os.environ.get("FLUTTER_ROOT")
if not flutter_root:
    raise SystemExit("FLUTTER_ROOT is missing from the Android build environment")
engine_artifacts = Path(flutter_root) / "bin/cache/artifacts/engine"
embedding_candidates = sorted(engine_artifacts.glob("android-*-release/flutter.jar"))
if not embedding_candidates:
    raise SystemExit(
        "Flutter Android embedding flutter.jar was not found. "
        "Run flutter precache --android before preparing the Gradle project."
    )
flutter_embedding_jar = str(embedding_candidates[0]).replace("\\", "\\\\").replace('"', '\\"')

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

# Flutter's declarative Gradle plugin may omit flutter.jar from the compile
# classpath in some generated plugin project graphs. Add it as compileOnly to
# Android library subprojects and once as an app runtime dependency.
root_build = root_build_file.read_text()
marker = "// DISCOVERLY Flutter embedding compatibility"
if marker not in root_build:
    workaround = f'''
{marker}
val discoverlyFlutterEmbeddingJar = file("{flutter_embedding_jar}")
if (!discoverlyFlutterEmbeddingJar.isFile) {{
    throw GradleException("Missing Flutter embedding jar: $discoverlyFlutterEmbeddingJar")
}}
subprojects {{
    val discoverlyAndroidProject = this
    discoverlyAndroidProject.plugins.withId("com.android.library") {{
        discoverlyAndroidProject.dependencies.add(
            "compileOnly",
            discoverlyAndroidProject.files(discoverlyFlutterEmbeddingJar)
        )
        discoverlyAndroidProject.dependencies.add("compileOnly", "androidx.appcompat:appcompat:1.7.0")
        discoverlyAndroidProject.dependencies.add("compileOnly", "androidx.core:core:1.13.1")
        discoverlyAndroidProject.dependencies.add("compileOnly", "androidx.annotation:annotation:1.8.2")
    }}
    discoverlyAndroidProject.plugins.withId("com.android.application") {{
        discoverlyAndroidProject.dependencies.add(
            "implementation",
            discoverlyAndroidProject.files(discoverlyFlutterEmbeddingJar)
        )
        discoverlyAndroidProject.dependencies.add("implementation", "androidx.appcompat:appcompat:1.7.0")
        discoverlyAndroidProject.dependencies.add("implementation", "androidx.core:core:1.13.1")
        discoverlyAndroidProject.dependencies.add("implementation", "androidx.annotation:annotation:1.8.2")
    }}
}}
'''
    root_build_file.write_text(root_build.rstrip() + "\n\n" + workaround)

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
activity_content = re.sub(r"^package [^\n]+", "package com.discoverly.app", activity_content, count=1, flags=re.MULTILINE)
target_activity.write_text(activity_content)
if activity_files[0] != target_activity:
    activity_files[0].unlink()

print("Android package ID, API 36, app label, backup settings, Kotlin namespace, upload signing and Flutter embedding classpath prepared.")
