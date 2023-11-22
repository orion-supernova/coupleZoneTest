//
//  PhotosServices.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 30.10.2023.
//

import Foundation
import UIKit.UIImage
import SupabaseStorage

class PhotosServices {

    let supabase = SensitiveData.supabase

    func getPhotos() async -> Result<[PhotosItem], RequestError> {
        do {
            guard let userID = AppGlobal.shared.user?.id else { return .failure(.generic) }
            let homeIDData = try await supabase.database.from("users").select(columns: "homeID").eq(column: "userID", value: userID).execute().underlyingResponse.data
            let homeIDStringData = String(data: homeIDData, encoding: .utf8) ?? ""
            let homeIDDict = homeIDStringData.convertStringToDictionary()
            let homeID = homeIDDict?["homeID"] as? String ?? ""
            let data = try await supabase.database.from("photosTimeline").select(columns: "*", head: false).eq(column: "homeID", value: homeID).execute().underlyingResponse.data
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
            let file = File(name: fileName, data: imageData, fileName: fileName, contentType: "image/jpeg")
            let homeID = await getHomeID()
            let uploadPhotoToStorage = try await supabase.storage.from(id: "homes/\(homeID)/timelinePhotos").upload(path: "\(fileName).jpeg", file: file, fileOptions: FileOptions(cacheControl: "3600"))
            let urlString = try supabase.storage.from(id: "homes/\(homeID)/timelinePhotos").getPublicURL(path: "\(fileName).jpeg").absoluteString
            print(urlString)
            print(uploadPhotoToStorage)
            let username = await getUsername()
            let dict = ["imageURL": "\(urlString)", "username": username, "homeID": homeID]
            let updateTable = supabase.database.from("photosTimeline").upsert(values: dict)
            try await updateTable.execute()
            await sendNotificationToPartner()
            return .success(())
        } catch let error {
            print(error.localizedDescription)
            return .failure(.generic)
        }
    }

    // MARK: - Private Methods
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
    private func getHomeID() async -> String {
        do {
            guard let userID = AppGlobal.shared.user?.id else { return "" }
            let userDict = try await SensitiveData.supabase.database.from("users").select(columns: "*", head: false).eq(column: "userID", value: userID).execute().underlyingResponse.data.convertDataToString().convertStringToDictionary()
            let idString = userDict?["homeID"] as? String ?? ""
            return idString
        } catch let error {
            print(error.localizedDescription)
            return ""
        }
    }
    private func sendNotificationToPartner() async {
        do {
            guard let userID = AppGlobal.shared.user?.id.uuidString else { return }
            let username = await getUsername()
            let partnerUserID = try await SensitiveData.supabase.database.from("users").select(columns: "partnerUserID", head: false).eq(column: "userID", value: userID).execute().underlyingResponse.data.convertDataToString().convertStringToDictionary()?["partnerUserID"] as? String ?? ""
            let pushDevicesIDArray = try await SensitiveData.supabase.database.from("users").select(columns: "pushSubscriptionIDs", head: false).eq(column: "userID", value: partnerUserID).execute().underlyingResponse.data.convertDataToString().convertStringToDictionary()?["pushSubscriptionIDs"] as? [String] ?? []
            OneSignalManager.shared.postNotification(to: pushDevicesIDArray, title: "Wow!", message: "\(username) has sent you a photo!")
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
