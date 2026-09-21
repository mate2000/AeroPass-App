package com.aeropass.aeropass_app

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * 003-escanear-documento / FR-014: offers a route to the system settings
 * screen that would unblock a permanently denied camera permission.
 * Neither the `camera` plugin nor the Flutter SDK exposes this, and this
 * feature adds no new pub dependency for it (plan.md's single-new
 * -dependency scope) — this is the minimal platform-channel handler
 * `lib/data/services/system_settings_launcher.dart` calls into.
 */
class MainActivity : FlutterActivity() {
    private val systemSettingsChannel = "aeropass/system_settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, systemSettingsChannel)
            .setMethodCallHandler { call, result ->
                if (call.method == "openAppSettings") {
                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                    intent.data = Uri.fromParts("package", packageName, null)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
