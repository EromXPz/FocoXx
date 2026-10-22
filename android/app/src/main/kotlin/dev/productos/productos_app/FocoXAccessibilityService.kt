package dev.productos.productos_app

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

class FocoXAccessibilityService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val packageName = event.packageName?.toString() ?: return
        if (packageName == applicationContext.packageName) return
        val prefs = getSharedPreferences("focox", MODE_PRIVATE)
        if (!prefs.getBoolean("enabled", false)) return
        val enabledUntil = prefs.getLong("enabledUntil", 0L)
        if (enabledUntil == 0L || System.currentTimeMillis() >= enabledUntil) {
            prefs.edit().putBoolean("enabled", false).remove("enabledUntil").apply()
            return
        }
        val blocked = prefs.getStringSet("packages", emptySet<String>()) ?: emptySet()
        if (packageName !in blocked) return
        val intent = Intent(this, BlockActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra("blocked_package", packageName)
        }
        startActivity(intent)
    }

    override fun onInterrupt() = Unit
}