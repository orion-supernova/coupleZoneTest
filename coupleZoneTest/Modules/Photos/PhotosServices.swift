//
//  PhotosServices.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 30.10.2023.
//

import Foundation
import UIKit.UIImage
import Supabase

class PhotosServices {

    let supabase = SensitiveData.supabase

    func getPhotos() async -> Result<[PhotosItem], RequestError> {
        do {
            guard let userID = AppGlobal.shared.user?.id else { return .failure(.generic) }
            let homeIDData = try await supabase.database.from("users").select("homeID").eq("userID", value: userID).execute().data
            let homeIDStringData = String(data: homeIDData, encoding: .utf8) ?? ""
            let homeIDDict = homeIDStringData.convertStringToDictionary()
            let homeID = homeIDDict?["homeID"] as? String ?? ""
            let data = try await supabase.database.from("photosTimeline").select("*", head: false).eq("homeID", value: homeID).execute().data
            let stringData = String(data: data, encoding: .utf8) ?? ""
            guard let dict = stringData.convertStringToDictionaryArray() else { return .failure(.generic) }
            var items = [PhotosItem]()
            for item in dict {
                guard let photoItem = PhotosItem(with: item) else { continue }
                items.append(photoItem)
            }
            return .success(items)
        } catch {
            return .failure(.generic)
        }
    }

    func uploadPhoto(_ image: UIImage) async -> Result<Void, RequestError> {
        do {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return .failure(.convertImageToDataError) }
            let fileName = UUID().uuidString
            let fileData = File(name: fileName, data: imageData, fileName: fileName, contentType: "image/jpeg").data
            let homeID = await getHomeID()
            let uploadPhotoToStorage = try await supabase.storage.from("homes/\(homeID)/timelinePhotos").upload(path: "\(fileName).jpeg", file: fileData, options: .init(cacheControl: "3600"))
            let urlString = try supabase.storage.from("homes/\(homeID)/timelinePhotos").getPublicURL(path: "\(fileName).jpeg").absoluteString
            print(urlString)
            print(uploadPhotoToStorage)
            let username = await getUsername()
            let dict = ["imageURL": "\(urlString)", "username": username, "homeID": homeID]
            try await supabase.database.from("photosTimeline").upsert(dict).execute()
            await sendNotificationToPartner(title: "Wow!", message: "\(username) has sent you a photo!", pushCategory: .timelinePhoto, notificationSoundString: "photo-notification.wav")
            return .success(())
        } catch let error {
            print(error.localizedDescription)
            return .failure(.generic)
        }
    }
    
    func getNotificationTime() async -> Result<String, CustomMessageError> {
        do {
            let homeID = await getHomeID()
            let notificationTimestamp = try await SensitiveData.supabase.database.from("homes").select("photoNotificationTime", head: false).eq("id", value: homeID).execute().data.convertDataToString().convertStringToDictionary()?["photoNotificationTime"] as? String ?? ""
            return .success(notificationTimestamp)
        } catch let error {
            print(error.localizedDescription)
            return .failure(.init(message: "Something went wrong"))
        }
    }
    
    func updateNotificationTime(_ time: String) async -> Result<String, CustomMessageError> {
        do {
            let homeID = await getHomeID()
            try await SensitiveData.supabase.database.from("homes").update(["photoNotificationTime": time]).eq("id", value: homeID).execute()
            print("Update Notification Time Success")
            let newNotificationTimeWithTimeZoneResponse = await getNotificationTime()
            var newTime = ""
            if case let .success(time) = newNotificationTimeWithTimeZoneResponse {
                newTime = time
            }
            await sendNotificationToPartner(title: "Your Photo Time Changed!", message: "Your Partner has changed the time of notification to \(newTime.convertStringToDate(receivedformat: "yyyy-MM-dd'T'HH:mm:ssZ", desiredFormat: "HH:mm"))!", pushCategory: .timeLinePhotoNotificationTimeUpdate, notificationSoundString: "guitar-notification.wav", data: ["time": time])
            return .success(time)
        } catch let error {
            print(error.localizedDescription)
            return .failure(.init(message: "Something went wrong."))
        }
    }

    // MARK: - Private Methods
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
    private func getHomeID() async -> String {
        do {
            guard let userID = AppGlobal.shared.user?.id else { return "" }
            let userDict = try await SensitiveData.supabase.database.from("users").select("*", head: false).eq("userID", value: userID).execute().data.convertDataToString().convertStringToDictionary()
            let idString = userDict?["homeID"] as? String ?? ""
            print("DEBUG: ----- \(idString)", userDict!)
            return idString
        } catch let error {
            print(error.localizedDescription)
            return ""
        }
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
}
