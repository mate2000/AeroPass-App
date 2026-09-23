package com.aeropass.aeropass_app

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * 003-escanear-documento / FR-014: offers a route to the system settings
 * screen that would unblock a permanently denied camera permission.
 * Neither the `camera` plugin nor the Flutter SDK exposes this, and this
 * feature adds no new pub dependency for it (plan.md's single-new
 * -dependency scope) — this is the minimal platform-channel handler
 * `lib/data/services/system_settings_launcher.dart` calls into.
 *
 * 008-identidad-activa / FR-012: toggles FLAG_SECURE on this activity's
 * window while a credential is displayed, so the system blocks screenshots
 * and screen recording. Called by `PlatformScreenCaptureGuard` in
 * `lib/data/services/screen_capture_guard.dart`; no new pub dependency.
 *
 * 014-qr-pase / FR-006, FR-007, FR-023 (contracts/pass-display-and-posture.md):
 * `aeropass/pass_display` raises brightness, keeps the screen awake and
 * blocks capture while a pass code is shown, and reports device-posture
 * signals. The posture checks are heuristics; backend attestation is the
 * robust answer (research.md §8). No device data leaves this channel, only
 * fixed signal names.
 */
class MainActivity : FlutterActivity() {
    private val systemSettingsChannel = "aeropass/system_settings"
    private val screenCaptureChannel = "aeropass/screen_capture"
    private val passDisplayChannel = "aeropass/pass_display"
    private var savedBrightness: Float? = null

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
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, screenCaptureChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setSecure" -> {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    "clearSecure" -> {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, passDisplayChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enterPassMode" -> {
                        val attributes = window.attributes
                        if (savedBrightness == null) savedBrightness = attributes.screenBrightness
                        attributes.screenBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_FULL
                        window.attributes = attributes
                        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    "exitPassMode" -> {
                        val attributes = window.attributes
                        attributes.screenBrightness =
                            savedBrightness ?: WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
                        savedBrightness = null
                        window.attributes = attributes
                        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    "devicePosture" -> result.success(devicePostureSignals())
                    else -> result.notImplemented()
                }
            }
    }

    /** Fixed signal names only; never paths, build strings or identifiers. */
    private fun devicePostureSignals(): List<String> {
        val signals = mutableListOf<String>()
        val suPaths = listOf(
            "/system/bin/su", "/system/xbin/su", "/sbin/su", "/su/bin/su",
            "/data/local/xbin/su", "/data/local/bin/su", "/system/sd/xbin/su",
        )
        if (suPaths.any { File(it).exists() }) signals.add("su_binary")
        if (Build.TAGS?.contains("test-keys") == true) signals.add("test_keys")
        val fingerprint = Build.FINGERPRINT ?: ""
        val emulator = fingerprint.startsWith("generic") ||
            fingerprint.contains("emulator") ||
            fingerprint.contains("sdk_gphone") ||
            Build.MODEL.contains("Emulator") ||
            Build.MODEL.contains("Android SDK built for") ||
            Build.HARDWARE == "goldfish" ||
            Build.HARDWARE == "ranchu"
        if (emulator) signals.add("emulator")
        val hookingFiles = listOf(
            "/data/local/tmp/frida-server",
            "/data/local/tmp/re.frida.server",
            "/system/framework/XposedBridge.jar",
        )
        val xposedLoaded = try {
            Class.forName("de.robv.android.xposed.XposedBridge")
            true
        } catch (e: ClassNotFoundException) {
            false
        }
        if (hookingFiles.any { File(it).exists() } || xposedLoaded) {
            signals.add("hooking_framework")
        }
        return signals
    }
}
