# ProGuard Rules for Untracked Flutter App
# Keep this file updated with all dependencies

#region Flutter Framework
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Flutter wrapper
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
#endregion

#region Kotlin & Coroutines
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}
-assumenosideeffects class kotlin.jvm.internal.Intrinsics {
    static void checkParameterIsNotNull(java.lang.Object, java.lang.String);
}
#endregion

#region JSON Serialization (json_serializable, freezed)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep all data classes and their generated code
-keep class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Freezed generated classes
-keep class **$*.class { *; }
-keepclassmembers class * {
    *** fromJson(...);
    *** toJson(...);
}

# Keep annotations for code generation
-keep @interface *
-keepclasseswithmembers class * {
    @org.junit.* <methods>;
}
#endregion

#region Riverpod
-keep class * extends com.google.common.base.** { *; }
-keep class * extends riverpod.** { *; }
-keepclassmembers class * extends riverpod.** { *; }

# Keep Riverpod providers and notifiers
-keep class **Provider { *; }
-keep class **Notifier { *; }
-keep class **StateNotifier { *; }
-keepclassmembers class * {
    *** build(...);
}
#endregion

#region GoRouter
-keep class ** extends go_router.** { *; }
-keep class go_router.** { *; }
#endregion

#region HTTP & Network (http package)
-keep class org.apache.http.** { *; }
-dontwarn org.apache.http.**
-keep class android.net.http.** { *; }
-dontwarn android.net.http.**

# OkHttp (used by Flutter http internally)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
#endregion

#region Hive (Local Storage)
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class * extends io.flutter.plugins.** { *; }

# Keep Hive adapters
-keep class hive.** { *; }
-keep class * extends hive.** { *; }
-keepclassmembers class * {
    @hive.* <fields>;
}
#endregion

#region Share, Clipboard, Connectivity Plugins
-keep class io.flutter.plugins.share.** { *; }
-keep class io.flutter.plugins.urllauncher.** { *; }
-keep class io.flutter.plugins.connectivity.** { *; }
#endregion

#region Dynamic Colors Plugin
-keep class io.flutter.plugins.dynamiccolor.** { *; }
#endregion

#region Remove Logging in Release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
#endregion

#region General Android
-keep class androidx.lifecycle.** { *; }
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-dontwarn androidx.**

# Keep custom views
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public void set*(...);
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelables
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}
#endregion

#region R8 Optimization Settings
# Don't warn about missing classes
-dontwarn javax.annotation.**
-dontwarn javax.inject.**
-dontwarn sun.misc.Unsafe

# Preserve line numbers for debugging
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable

# Crash reporting (if added later)
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
#endregion
