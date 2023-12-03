//
//  AppDelegate.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 18.10.2023.
//

import UIKit
import OneSignalFramework
import UserNotifications

enum PushNotificationIdentifiers {
    enum Category: String {
        case timeLinePhotoNotificationTimeUpdate
        case timelinePhoto
        case dailyPhotoNotification
        case love
    }
    enum Action: String {
        case viewAction
        case loveAction
        case dismissAction
        case dailyPhotoSendAction = "com.apple.UNNotificationDefaultActionIdentifier"
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configureTabbarAndNavbarAppearance()
        // Remove this method to stop OneSignal Debugging
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        // OneSignal initialization
        OneSignal.initialize(SensitiveData.oneSignalAppID, withLaunchOptions: launchOptions)
        // requestPermission will show the native iOS notification permission prompt.
        // We recommend removing the following code and instead using an In-App Message to prompt for notification permission
        registerForPushNotifications()
        OneSignal.Notifications.requestPermission({ accepted in
            print("User accepted notifications: \(accepted)")
        }, fallbackToSettings: true)
        OneSignal.Notifications.addClickListener(self)

        return true
    }

    // MARK: - Configure Navbar and Tabbar Appearance
    func configureTabbarAndNavbarAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance   = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance    = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance

        let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = UIColor.LilacClouds.lilac1
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    // MARK: - Apple Push Notifications Service
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }

            UNUserNotificationCenter.current().delegate = self

            // MARK: - Notification Actions
            let viewAction = UNNotificationAction(
                identifier: PushNotificationIdentifiers.Action.viewAction.rawValue,
                title: "Aww, Lemme See!",
                options: [.foreground])
            let dismissAction = UNNotificationAction(
                identifier: PushNotificationIdentifiers.Action.dismissAction.rawValue,
                title: "Nevermind...",
                options: [])
            let loveAction = UNNotificationAction(
                identifier: PushNotificationIdentifiers.Action.loveAction.rawValue,
                title: "Send Love Back! ❤️",
                options: [])
            let dailyPhotoSendAction = UNNotificationAction(
                identifier: PushNotificationIdentifiers.Action.dailyPhotoSendAction.rawValue,
                title: "Okay, I'm getting ready!",
                options: [])

            // MARK: - Notification Categories
            let timelinePhotoCategory = UNNotificationCategory(
                identifier: PushNotificationIdentifiers.Category.timelinePhoto.rawValue,
                actions: [viewAction, dismissAction],
                intentIdentifiers: [],
                options: [])
            let timeLinePhotoNotificationTimeUpdateCategory = UNNotificationCategory(
                identifier: PushNotificationIdentifiers.Category.timeLinePhotoNotificationTimeUpdate.rawValue,
                actions: [],
                intentIdentifiers: [],
                options: [])
            let loveCategory = UNNotificationCategory(
                identifier: PushNotificationIdentifiers.Category.love.rawValue,
                actions: [loveAction, dismissAction],
                intentIdentifiers: [],
                options: [])
            let dailyPhotoNotificationCategory = UNNotificationCategory(
                identifier: PushNotificationIdentifiers.Category.dailyPhotoNotification.rawValue,
                actions: [dailyPhotoSendAction, dismissAction],
                intentIdentifiers: [],
                options: [])

            UNUserNotificationCenter.current().setNotificationCategories([timelinePhotoCategory, timeLinePhotoNotificationTimeUpdateCategory, loveCategory, dailyPhotoNotificationCategory])

            self?.getNotificationSettings()
        }
    }
    
    // MARK: - Notification Settings
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else {
                AlertHelper.alertMessage(title: "Push Notifications Problem", message: "Please enable push notifications from your settings to improve the apps usability.", okButtonText: "OK")
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }

    // MARK: - Notification Handler
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        handlePayloadInBackground(userInfo: userInfo)
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
    }

}
// MARK: - Push Background Event
extension AppDelegate {
    func handlePayloadInBackground(userInfo: [AnyHashable: Any]) {
        guard let aps = userInfo["aps"] as? [String: Any] else { return }
        guard let categoryString = aps["category"] as? String else { return }
        guard let category = PushNotificationIdentifiers.Category(rawValue: categoryString) else { return }
        switch category {
            case .timeLinePhotoNotificationTimeUpdate:
                guard let customData = userInfo["custom"] as? [String: Any] else { return }
                guard let a = customData["a"] as? [String: Any] else { return }
                guard let additionalData = a["additionalData"] as? [String: Any] else { return }
                guard let time = additionalData["time"] as? String else { return }
                print(time)
                scheduleNotification(at: time)
            default:
                break
        }
        print(userInfo)
    }
}

// MARK: - Push Click Event
extension AppDelegate: OSNotificationClickListener {
    func onClick(event: OSNotificationClickEvent) {
        let category = event.notification.category ?? ""
        let additionalData = event.notification.additionalData ?? [:]
        handleClickEvent(data: additionalData)
        print(category)
    }
    private func handleClickEvent(data: [AnyHashable: Any]) {
        print(data)
        guard let categoryString = data["notificationCategory"] as? String else { return }
        guard let category = PushNotificationIdentifiers.Category(rawValue: categoryString) else { return }
        switch category {
            case .timeLinePhotoNotificationTimeUpdate:
                let action = getActionType(from: data)
                guard action != .dismissAction else { return }
                print("DEBUG: ----- Photo Notification Time Updated!")
                DispatchQueue.main.async {
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
                    sceneDelegate.navigateFromAuth(selectedIndex: 1)
                }
            case .timelinePhoto:
                let action = getActionType(from: data)
                guard action != .dismissAction else { return }
                print("DEBUG: ----- TimeLine Photo View!")
                DispatchQueue.main.async {
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
                    sceneDelegate.navigateFromAuth(selectedIndex: 1)
                }
            case .love:
                let action = getActionType(from: data)
                if action == .loveAction {
                    let homeServices = HomeServices()
                    Task {
                        let _ = await homeServices.sendLoveToPartner()
                        print("DEBUG: ----- Love Sent Back!")
                    }
                }
            default:
                break
        }
    }
    private func getActionType(from data: [AnyHashable: Any]) -> PushNotificationIdentifiers.Action? {
        guard let actionSelectedString = data["actionSelected"] as? String else { return nil }
        guard let action = PushNotificationIdentifiers.Action(rawValue: actionSelectedString) else { return nil }
        return action
    }
}

extension AppDelegate {
    func scheduleNotification(at userTime: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        if let date = dateFormatter.date(from: userTime) {
            let content = UNMutableNotificationContent()
            content.title = "Photo Time!"
            content.body = "Send your partner a stunning photo to blew their mind!"

            // Set a custom sound
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "romantic-notification.wav"))

            // Add custom information for the notification action
            content.userInfo = ["customAction": "photoSend"]
//            content.categoryIdentifier = PushNotificationIdentifiers.Category.dailyPhotoNotification.rawValue

            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let trigger2 = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)

            let request = UNNotificationRequest(identifier: "DailyNotification", content: content, trigger: trigger)

            UNUserNotificationCenter.current().getPendingNotificationRequests { array in
                print(array)
            }
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled successfully!")
                }
            }
        } else {
            print("Invalid date format")
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("DEBUG: ----- CLICKED OR RECEIVED")
        // Only handling daily photo notification for now. Should change when new types added.
//        let category = response.notification.request.content.categoryIdentifier
//        if category == PushNotificationIdentifiers.Category.dailyPhotoNotification.rawValue {
//            let action = PushNotificationIdentifiers.Action(rawValue: response.actionIdentifier)
//            guard action != .dismissAction else { return }
//            DispatchQueue.main.async {
//                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
//                sceneDelegate.navigateFromAuth(selectedIndex: 1, isDailyPhotoAction: true)
//                completionHandler()
//            }
//        }
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
            sceneDelegate.navigateFromAuth(selectedIndex: 1, isDailyPhotoAction: true)
            completionHandler()
        }
    }
}


