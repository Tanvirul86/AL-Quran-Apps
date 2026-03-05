# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Core
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep Quran data classes
-keep class com.quranapp.app.models.** { *; }
-keep class com.quranapp.app.services.** { *; }

# Keep audio player classes
-keep class com.ryanheise.just_audio.** { *; }

# Keep database classes
-keep class com.tekartik.sqflite.** { *; }
