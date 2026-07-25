# Flutter-specific ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# GetX
-keep class com.getkeepsafe.** { *; }

# Keep model classes for serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keepattributes Signature
-keepattributes *Annotation*

# Optional codecs referenced by PDFBox. Resume text extraction does not use
# JPEG 2000 image decoding, so this class is intentionally absent.
-dontwarn com.gemalto.jp2.JP2Decoder

# Flutter embeds optional Play Store deferred-component hooks. Jobodia ships as
# one APK and does not use dynamic feature delivery.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
