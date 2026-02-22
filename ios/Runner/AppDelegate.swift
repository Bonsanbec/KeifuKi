import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let notificationsChannelName = "keifuki/notifications"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: notificationsChannelName,
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { [weak self] call, result in
        switch call.method {
        case "schedule":
          guard
            let args = call.arguments as? [String: Any],
            let id = args["id"] as? Int,
            let title = args["title"] as? String,
            let body = args["body"] as? String,
            let scheduledAtMillis = args["scheduled_at_millis"] as? Int64
          else {
            result(FlutterError(code: "invalid_args", message: "Missing notification arguments", details: nil))
            return
          }

          self?.scheduleNotification(
            id: id,
            title: title,
            body: body,
            scheduledAtMillis: scheduledAtMillis,
            result: result
          )

        case "cancel":
          guard
            let args = call.arguments as? [String: Any],
            let id = args["id"] as? Int
          else {
            result(FlutterError(code: "invalid_args", message: "Missing notification id", details: nil))
            return
          }

          UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(id)"])
          UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["\(id)"])
          result(nil)

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func scheduleNotification(
    id: Int,
    title: String,
    body: String,
    scheduledAtMillis: Int64,
    result: @escaping FlutterResult
  ) {
    let center = UNUserNotificationCenter.current()

    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if let error = error {
        result(FlutterError(code: "auth_error", message: error.localizedDescription, details: nil))
        return
      }

      if !granted {
        result(nil)
        return
      }

      center.removePendingNotificationRequests(withIdentifiers: ["\(id)"])

      let content = UNMutableNotificationContent()
      content.title = title
      content.body = body
      content.sound = .default

      let nowMillis = Int64(Date().timeIntervalSince1970 * 1000)
      let delaySeconds = max(1.0, Double(scheduledAtMillis - nowMillis) / 1000.0)

      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delaySeconds, repeats: false)
      let request = UNNotificationRequest(identifier: "\(id)", content: content, trigger: trigger)

      center.add(request) { addError in
        if let addError = addError {
          result(FlutterError(code: "schedule_error", message: addError.localizedDescription, details: nil))
          return
        }
        result(nil)
      }
    }
  }
}
