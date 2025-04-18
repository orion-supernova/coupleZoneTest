//
//  LocalNotificationManager.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 2023-12-09.
//

import UIKit.UIApplication
import UserNotifications

class LocalNotificationManager {
    static let shared = LocalNotificationManager()
}

extension LocalNotificationManager {
    func scheduleDailyPhotoNotification(at userTime: String) {
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
