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

    // Some older plugins (e.g. isar_flutter_libs 3.1.0) declare their package
    // only via the manifest and don't set an AGP `namespace`, which AGP 8+
    // requires. Inject it from the plugin's group so the build doesn't fail.
    // Registered here (before the evaluationDependsOn block below forces early
    // evaluation) and via reflection to avoid a compile-time AGP dependency.
    afterEvaluate {
        val androidExt = extensions.findByName("android") ?: return@afterEvaluate
        val cls = androidExt.javaClass
        runCatching {
            // 1) Inject a namespace for plugins that only set it in the manifest
            //    (isar_flutter_libs 3.1.0), required by AGP 8+.
            val getNamespace = cls.getMethod("getNamespace")
            if (getNamespace.invoke(androidExt) == null) {
                cls.methods.first { it.name == "setNamespace" }
                    .invoke(androidExt, project.group.toString())
            }
        }
        runCatching {
            // 2) Pin build-tools to a complete on-disk version (AGP 8.7's default
            //    34.0.0 is incomplete here and the SDK repo is unreachable).
            cls.methods.first { it.name == "setBuildToolsVersion" }
                .invoke(androidExt, "35.0.0")
        }
        runCatching {
            // 3) Old plugins pin a compileSdk we don't have installed
            //    (isar pins 30). Force every module to the installed API 36.
            val intSetter = cls.methods.firstOrNull {
                it.name in listOf("compileSdkVersion", "setCompileSdkVersion", "setCompileSdk") &&
                    it.parameterTypes.size == 1 &&
                    (it.parameterTypes[0] == Integer.TYPE || it.parameterTypes[0] == Integer::class.java)
            }
            if (intSetter != null) {
                intSetter.invoke(androidExt, 36)
            } else {
                cls.methods.firstOrNull {
                    it.name in listOf("compileSdkVersion", "setCompileSdkVersion") &&
                        it.parameterTypes.size == 1 && it.parameterTypes[0] == String::class.java
                }?.invoke(androidExt, "android-36")
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
