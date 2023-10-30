//
//  AppGlobal.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 28.10.2023.
//

import Foundation
import Supabase

class AppGlobal {
    static let shared: AppGlobal = {
        return AppGlobal()
    }()

    var username: String? {
        get {
            return UserDefaults.standard.value(forKey: "username") as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "username")
        }
    }

    var appleCredentialUserFullName: PersonNameComponents? {
        get {
            if let data = UserDefaults.standard.data(forKey: "appleCredentialUser") {
                do {
                    let decoder = JSONDecoder()
                    let user = try decoder.decode(PersonNameComponents.self, from: data)
                    return user
                } catch {
                    print("Unable to Decode appleCredentialUser (\(error))")
                    return nil
                }
            } else {
                return nil
            }
        }
        set {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(newValue)
                Foundation.UserDefaults.standard.set(data, forKey: "appleCredentialUser")
            } catch {
                print("Unable to ENcode appleCredentialUser (\(error))")
            }
        }
    }
    
    var user: User? {
        get {
            if let data = UserDefaults.standard.data(forKey: "supabaseUser") {
                do {
                    let decoder = JSONDecoder()
                    let user = try decoder.decode(User.self, from: data)
                    return user
                } catch {
                    print("Unable to Decode appleCredentialUser (\(error))")
                    return nil
                }
            } else {
                return nil
            }
        }
        set {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(newValue)
                UserDefaults.standard.set(data, forKey: "supabaseUser")
            } catch {
                print("Unable to ENcode appleCredentialUser (\(error))")
            }
        }
    }

}
