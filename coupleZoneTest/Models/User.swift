//
//  User.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 18.11.2023.
//

import Foundation
import Supabase

struct SupabaseUser: Codable {
    var userID: String
    var created_at: String
    var username: String
    var email: String
    var pushSubscriptionIDs: [String]?
}
