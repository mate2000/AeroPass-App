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
  }
}
