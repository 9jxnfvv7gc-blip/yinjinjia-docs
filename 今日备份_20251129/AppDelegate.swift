import Flutter
import UIKit
import audio_session
import file_picker
import just_audio
import share_plus
import url_launcher_ios
import video_player_avfoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 明确禁用广告跟踪，防止系统弹出跟踪权限提示
    // 应用不使用任何跟踪功能，不需要请求跟踪权限
    if #available(iOS 14.5, *) {
      // 不请求跟踪权限，应用不使用跟踪功能
      // 注意：不调用 ATTrackingManager.requestTrackingAuthorization
    }

    // 不再调用 GeneratedPluginRegistrant，改为手动只注册“安全插件”
    if let registry = self as? FlutterPluginRegistry {
      if let r = registry.registrar(forPlugin: "AudioSessionPlugin") {
        AudioSessionPlugin.register(with: r)
      }

      if let r = registry.registrar(forPlugin: "FilePickerPlugin") {
        FilePickerPlugin.register(with: r)
      }

      if let r = registry.registrar(forPlugin: "JustAudioPlugin") {
        JustAudioPlugin.register(with: r)
      }

      if let r = registry.registrar(forPlugin: "FPPSharePlusPlugin") {
        FPPSharePlusPlugin.register(with: r)
      }

      if let r = registry.registrar(forPlugin: "URLLauncherPlugin") {
        URLLauncherPlugin.register(with: r)
      }

      if let r = registry.registrar(forPlugin: "FVPVideoPlayerPlugin") {
        FVPVideoPlayerPlugin.register(with: r)
      }

      // 关键：**完全不注册 PathProviderPlugin / SharedPreferencesPlugin**
      // 不管它们有没有被编译进来，都不会在冷启动时执行 register(with:)
    }

    // 设置 iOS 协议记忆的 MethodChannel，使用 UserDefaults 持久化
    if let controller = window?.rootViewController as? FlutterViewController {
      // 法律协议记忆
      let legalChannel = FlutterMethodChannel(
        name: "legal_prefs",
        binaryMessenger: controller.binaryMessenger
      )

      legalChannel.setMethodCallHandler { call, result in
        let defaults = UserDefaults.standard

        switch call.method {
        case "getLegalAgreed":
          let value = defaults.bool(forKey: "legal_agreed")
          result(value)

        case "setLegalAgreed":
          if let args = call.arguments as? [String: Any],
             let value = args["value"] as? Bool {
            defaults.set(value, forKey: "legal_agreed")
            result(nil)
          } else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing 'value' bool", details: nil))
          }

        default:
          result(FlutterMethodNotImplemented)
        }
      }
      
      // 授权状态存储（替代 SharedPreferences）
      let authChannel = FlutterMethodChannel(
        name: "auth_prefs",
        binaryMessenger: controller.binaryMessenger
      )

      authChannel.setMethodCallHandler { call, result in
        let defaults = UserDefaults.standard

        switch call.method {
        case "getBool":
          if let args = call.arguments as? [String: Any],
             let key = args["key"] as? String {
            let value = defaults.bool(forKey: key)
            result(value)
          } else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing 'key' string", details: nil))
          }

        case "setBool":
          if let args = call.arguments as? [String: Any],
             let key = args["key"] as? String,
             let value = args["value"] as? Bool {
            defaults.set(value, forKey: key)
            result(nil)
          } else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing 'key' or 'value'", details: nil))
          }

        case "getString":
          if let args = call.arguments as? [String: Any],
             let key = args["key"] as? String {
            let value = defaults.string(forKey: key)
            result(value)
          } else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing 'key' string", details: nil))
          }

        case "setString":
          if let args = call.arguments as? [String: Any],
             let key = args["key"] as? String,
             let value = args["value"] as? String {
            defaults.set(value, forKey: key)
            result(nil)
          } else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing 'key' or 'value'", details: nil))
          }

        case "remove":
          if let args = call.arguments as? [String: Any],
             let key = args["key"] as? String {
            defaults.removeObject(forKey: key)
            result(nil)
          } else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing 'key' string", details: nil))
          }

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
