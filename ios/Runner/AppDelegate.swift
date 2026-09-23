import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // 003-escanear-documento / FR-014: offers a route to the system
    // settings screen that would unblock a permanently denied camera
    // permission — see MainActivity.kt's counterpart and
    // lib/data/services/system_settings_launcher.dart. Not verified to
    // compile in this headless environment (no Xcode toolchain); confirm
    // on a real device alongside the T051/T052 manual scenarios.
    let channel = FlutterMethodChannel(
      name: "aeropass/system_settings",
      binaryMessenger: engineBridge.pluginRegistry.messenger()
    )
    channel.setMethodCallHandler { call, result in
      if call.method == "openAppSettings" {
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
 
    // 014-qr-pase / FR-006, FR-023 (contracts/pass-display-and-posture.md):
    // brightness and the idle timer while a pass code is shown, and
    // jailbreak signals. iOS cannot block screenshots; that limitation is
    // recorded in research.md §6. Not verified to compile here (no Xcode).
    let passChannel = FlutterMethodChannel(
      name: "aeropass/pass_display",
      binaryMessenger: engineBridge.pluginRegistry.messenger()
    )
    passChannel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "enterPassMode":
        if self?.savedBrightness == nil {
          self?.savedBrightness = UIScreen.main.brightness
        }
        UIScreen.main.brightness = 1.0
        UIApplication.shared.isIdleTimerDisabled = true
        result(nil)
      case "exitPassMode":
        if let saved = self?.savedBrightness {
          UIScreen.main.brightness = saved
        }
        self?.savedBrightness = nil
        UIApplication.shared.isIdleTimerDisabled = false
        result(nil)
      case "devicePosture":
        let paths = [
          "/Applications/Cydia.app", "/Library/MobileSubstrate/MobileSubstrate.dylib",
          "/bin/bash", "/usr/sbin/sshd", "/etc/apt", "/private/var/lib/apt/",
        ]
        let jailbroken = paths.contains { FileManager.default.fileExists(atPath: $0) }
        result(jailbroken ? ["jailbreak_paths"] : [])
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private var savedBrightness: CGFloat?
}
