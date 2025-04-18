//
//  NotificationExtension.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 18.11.2023.
//

import Foundation

extension NSNotification.Name {
    static let usernameChanged = NSNotification.Name("usernameChanged")
    static let anniversaryChanged = NSNotification.Name("anniversaryChanged")
    static let addUserToHomeSuccess = NSNotification.Name("addUserToHomeSuccess")
    static let newMessageReceived = NSNotification.Name("newMessageReceived")
    static let onlineStatusChanged = NSNotification.Name("onlineStatusChanged")
}
