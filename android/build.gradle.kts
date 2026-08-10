import com.android.build.api.dsl.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    if (name == "whisper_ggml") {
        plugins.withId("com.android.library") {
            extensions.configure<LibraryExtension> {
                // ffmpeg_kit_flutter_new_min 3.6.2 requires compileSdk 35+.
                // This changes compile-time API availability only; Mindly's
                // minSdk and targetSdk remain controlled by the app module.
                compileSdk = 35
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
