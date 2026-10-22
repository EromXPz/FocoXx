package dev.productos.productos_app

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "app.focox/control"
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            val prefs = getSharedPreferences("focox", MODE_PRIVATE)
            when (call.method) {
                "loadSettings" -> result.success(mapOf(
                    "packages" to prefs.getStringSet("packages", emptySet<String>())!!.toList(),
                    "minutes" to prefs.getInt("minutes", 25),
                    "enabled" to prefs.getBoolean("enabled", false)
                ))
                "saveSettings" -> {
                    val packages = (call.argument<List<String>>("packages") ?: emptyList()).toSet()
                    val minutes = call.argument<Int>("minutes") ?: 25
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    val wasEnabled = prefs.getBoolean("enabled", false)
                    val previousMinutes = prefs.getInt("minutes", 25)
                    val editor = prefs.edit()
                        .putStringSet("packages", packages)
                        .putInt("minutes", minutes.coerceIn(1, 240))
                        .putBoolean("enabled", enabled)
                    if (enabled && (!wasEnabled || previousMinutes != minutes || prefs.getLong("enabledUntil", 0L) <= System.currentTimeMillis())) {
                        editor.putLong("enabledUntil", System.currentTimeMillis() + minutes.coerceIn(1, 240) * 60_000L)
                    }
                    if (!enabled) editor.remove("enabledUntil")
                    editor.apply()
                    result.success(true)
                }
                "openAccessibilitySettings" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}