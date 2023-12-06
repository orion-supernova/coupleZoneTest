//
//  NotesServices.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 2023-12-03.
//


import Foundation
import UIKit.UIImage
import Supabase

class NotesServices {

    let supabase = SensitiveData.supabase

    func getNotes() async -> Result<[NoteItem], CustomMessageError> {
        do {
            guard let userID = AppGlobal.shared.user?.id else { return .failure(.init(message: "Couldn't find your user ID.")) }
            let homeID = try await supabase.database.from("users").select("homeID").eq("userID", value: userID).execute().data.convertDataToString().convertStringToDictionary()?["homeID"] as? String ?? ""
            let noteDict = try await supabase.database.from("notes").select("*").eq("homeID", value: homeID).execute().data.convertDataToString().convertStringToDictionaryArray() ?? [[:]]
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
            let homeID = try await supabase.database.from("users").select("homeID").eq("userID", value: userID).execute().data.convertDataToString().convertStringToDictionary()?["homeID"] as? String ?? ""
            let dict = ["title": title, "edited_at": getCurrentDateForServer(), "homeID": homeID]
            try await supabase.database.from("notes").upsert(dict).execute()
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
            let partnerUserID = try await SensitiveData.supabase.database.from("users").select("partnerUserID", head: false).eq("userID", value: userID).execute().data.convertDataToString().convertStringToDictionary()?["partnerUserID"] as? String ?? ""
            let pushDevicesIDArray = try await SensitiveData.supabase.database.from("users").select("pushSubscriptionIDs", head: false).eq("userID", value: partnerUserID).execute().data.convertDataToString().convertStringToDictionary()?["pushSubscriptionIDs"] as? [String] ?? []
            OneSignalManager.shared.postNotification(to: pushDevicesIDArray, title: title, message: message, notificationSoundString: notificationSoundString, pushCategory: pushCategory, data: data)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    private func getUsername() async -> String {
        do {
            guard let userEmail = AppGlobal.shared.user?.email else { return "" }
            let data = try await supabase.database.from("users").select("*", head: false).eq("email", value: userEmail).execute().data
            let stringData = String(data: data, encoding: .utf8)
            guard let userDict = stringData?.convertStringToDictionary() else { return "" }
            let username = userDict["username"] as? String ?? ""
            return username
        } catch  {
            return ""
        }
    }
    func connectSocket(noteID: String, completion: @escaping (_ message: Message) -> Void) {
        print("DEBUG: ----- socket connection started")
        supabase.realtime.connect()
        print("DEBUG: ----- ", supabase.realtime.channels.count)

        supabase.realtime
            .channel("noteChanges")
            .on(
                "postgres_changes",
                filter: ChannelFilter(
                    event: "*",
                    schema: "public",
                    table: "notes",
                    filter: "id=eq.\(noteID)"
                ),
                handler: completion
            )
            .subscribe()
        print("DEBUG: ----- ", supabase.realtime.isConnected)
    }
    func disconnectSocket() {
        print("DEBUG: ----- socket connection was", supabase.realtime.isConnected)
        supabase.realtime.removeAllChannels()
        supabase.realtime.disconnect()
        print("DEBUG: ----- socket connection ended")
        print("DEBUG: ----- ", supabase.realtime.isConnected)
    }

}

