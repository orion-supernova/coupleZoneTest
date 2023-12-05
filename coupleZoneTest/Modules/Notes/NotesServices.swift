//
//  NotesServices.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 2023-12-03.
//


import Foundation
import UIKit.UIImage
import SupabaseStorage

class NotesServices {

    let supabase = SensitiveData.supabase

    func getNotes() async -> Result<[NoteItem], CustomMessageError> {
        do {
            guard let userID = AppGlobal.shared.user?.id else { return .failure(.init(message: "Couldn't find your user ID.")) }
            let homeID = try await supabase.database.from("users").select(columns: "homeID").eq(column: "userID", value: userID).execute().underlyingResponse.data.convertDataToString().convertStringToDictionary()?["homeID"] as? String ?? ""
            let noteDict = try await supabase.database.from("notes").select(columns: "*", head: false).execute().underlyingResponse.data.convertDataToString().convertStringToDictionaryArray() ?? [[:]]
            var items = [NoteItem]()
            for item in noteDict {
                guard let noteItem = NoteItem(with: item) else { continue }
                items.append(noteItem)
            }
            return .success(items)
        } catch {
            return .failure(.init(message: "Something went wrong while getting notes."))
        }

    }

    func createNote(title: String) async -> Result<Void, CustomMessageError> {
        do {
            guard let userID = AppGlobal.shared.user?.id else { return .failure(.init(message: "Couldn't find your user ID.")) }
            let homeID = try await supabase.database.from("users").select(columns: "homeID").eq(column: "userID", value: userID).execute().underlyingResponse.data.convertDataToString().convertStringToDictionary()?["homeID"] as? String ?? ""
            let dict = ["title": title, "edited_at": getCurrentDateForServer(), "homeID": homeID]
            let noteDict = try await supabase.database.from("notes").upsert(values: dict).execute()
            let username = await getUsername()
            await sendNotificationToPartner(title: "New Note", message: "\(username) created a new note!", pushCategory: .note, notificationSoundString: "typewriter-notification.wav")
            return .success(())
        } catch {
            return .failure(.init(message: "Something went wrong while creating your note."))
        }
    }
    // MARK: - Private Methods
    private func getCurrentDateForServer() -> String {
        let dateFormatter = DateFormatter()
        let format = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.dateFormat = format
        let currentDate = dateFormatter.string(from: Date())
        return currentDate
    }
    private func sendNotificationToPartner(title: String, message: String, pushCategory: PushNotificationIdentifiers.Category, notificationSoundString: String, data: [String: Any]? = nil) async {
        do {
            guard let userID = AppGlobal.shared.user?.id.uuidString else { return }
            let partnerUserID = try await SensitiveData.supabase.database.from("users").select(columns: "partnerUserID", head: false).eq(column: "userID", value: userID).execute().underlyingResponse.data.convertDataToString().convertStringToDictionary()?["partnerUserID"] as? String ?? ""
            let pushDevicesIDArray = try await SensitiveData.supabase.database.from("users").select(columns: "pushSubscriptionIDs", head: false).eq(column: "userID", value: partnerUserID).execute().underlyingResponse.data.convertDataToString().convertStringToDictionary()?["pushSubscriptionIDs"] as? [String] ?? []
            OneSignalManager.shared.postNotification(to: pushDevicesIDArray, title: title, message: message, notificationSoundString: notificationSoundString, pushCategory: pushCategory, data: data)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    private func getUsername() async -> String {
        do {
            guard let userEmail = AppGlobal.shared.user?.email else { return "" }
            let data = try await supabase.database.from("users").select(columns: "*", head: false).eq(column: "email", value: userEmail).execute().underlyingResponse.data
            let stringData = String(data: data, encoding: .utf8)
            guard let userDict = stringData?.convertStringToDictionary() else { return "" }
            let username = userDict["username"] as? String ?? ""
            return username
        } catch  {
            return ""
        }
    }
}

