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
        afterEvaluate {
            extensions.configure<LibraryExtension> {
                // whisper_ggml 2.6.0 hardcodes compileSdk 34, while the
                // simulator-safe FFmpeg runtime requires compileSdk 35+.
                // Apply this after the plugin evaluates so its own android
                // block cannot overwrite the consumer-side compatibility fix.
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
