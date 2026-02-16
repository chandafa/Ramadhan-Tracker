# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep important plugin classes
-keep class com.dexterous.** { *; }
-keep class com.ramadhantracker.** { *; }

# Prevent shrinking of notification-related classes
-keep class androidx.core.app.NotificationCompat { *; }

# Keep Kotlin metadata
-keepattributes *Annotation*
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# Optimize aggressively
-optimizationpasses 5
-allowaccessmodification
-repackageclasses

-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.**
