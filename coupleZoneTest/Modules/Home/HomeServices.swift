//
//  HomeServices.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import Foundation
import UIKit.UIImage
import SupabaseStorage

class HomeServices {
    
    let supabase = SensitiveData.supabase

    // MARK: - Public Methods
    func getHomeInfo() async -> Result<HomeItem, RequestError> {
        do {
            guard let userID = AppGlobal.shared.user?.id else { return .failure(.generic) }
            let homeIDData = try await supabase.database.from("users").select(columns: "homeID").eq(column: "userID", value: userID).execute().underlyingResponse.data
            let homeIDStringData = String(data: homeIDData, encoding: .utf8) ?? ""
            let homeIDDict = homeIDStringData.convertStringToDictionary()
            let homeID = homeIDDict?["homeID"] as? String ?? ""
            let homeData = try await supabase.database.from("homes").select(columns: "*", head: false).eq(column: "id", value: homeID).execute().underlyingResponse.data
            let homeStringData = String(data: homeData, encoding: .utf8) ?? ""
            guard let homeDict = homeStringData.convertStringToDictionary() else { return .failure(.generic) }
            guard let item = HomeItem(with: homeDict) else { return .failure(.generic) }
            return .success(item)
        } catch {
            return .failure(.generic)
        }
    }
    func uploadPhoto(_ image: UIImage) async -> Result<Void, CustomMessageError> {
        do {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return .failure(.init(message: "Image Convertion to Data Error")) }
            let fileName = UUID().uuidString
            let file = File(name: fileName, data: imageData, fileName: fileName, contentType: "image/jpeg")
            let homeID = await getHomeID()
            let uploadPhotoToStorage = try await supabase.storage.from(id: "homes/\(homeID)/homePhotos").upload(path: "\(fileName).jpeg", file: file, fileOptions: FileOptions(cacheControl: "3600"))
            let urlString = try supabase.storage.from(id: "homes/\(homeID)/homePhotos").getPublicURL(path: "\(fileName).jpeg").absoluteString
            print(urlString)
            print(uploadPhotoToStorage)
            try await supabase.database.from("homes").update(values: ["imageURLString": urlString]).eq(column: "id", value: homeID).execute()
            return .success(())
        } catch let error {
            print(error.localizedDescription)
            return .failure(.init(message: "Something went wrong."))
        }
    }
    func sendLoveToPartner() async -> Result<Void, CustomMessageError> {
        do {
            let partnerUserID = await getPartnerUserID()
            guard !partnerUserID.isEmpty else { return .failure(.init(message: "Partner not found."))}
            let pushDevicesIDArray = try await SensitiveData.supabase.database.from("users").select(columns: "pushSubscriptionIDs", head: false).eq(column: "userID", value: partnerUserID).execute().underlyingResponse.data.convertDataToString().convertStringToDictionary()?["pushSubscriptionIDs"] as? [String] ?? []
            let username = AppGlobal.shared.username ?? ""
            OneSignalManager.shared.postNotification(to: pushDevicesIDArray, title: "Love Received!" , message: "\(username) sent you love!", notificationSoundString: "guitar-notification.wav", photoURLString: "https://ifhmuzgasdnjaegpvzpo.supabase.co/storage/v1/object/public/photos/balloon.jpg",pushCategory: .love)
            return .success(())
        } catch let error {
            print(error.localizedDescription)
            return .failure(.init(message: error.localizedDescription))
        }
    }
    func getPartnerUsername() async -> Result<String, CustomMessageError> {
        do {
            let partnerUserID = await getPartnerUserID()
            let partnerUsername = try await SensitiveData.supabase.database.from("users").select(columns: "username", head: false).eq(column: "userID", value: partnerUserID).execute().underlyingResponse.data.convertDataToString().convertStringToDictionary()?["username"] as? String ?? ""
            return .success(partnerUsername)
        } catch let error {
            return .failure(.init(message: error.localizedDescription))
        }
    }
    // MARK: - Private Methods
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
    private func getPartnerUserID() async -> String {
        do {
            guard let userID = AppGlobal.shared.user?.id.uuidString else { return "" }
            let partnerUserID = try await SensitiveData.supabase.database.from("users").select(columns: "partnerUserID", head: false).eq(column: "userID", value: userID).execute().underlyingResponse.data.convertDataToString().convertStringToDictionary()?["partnerUserID"] as? String ?? ""
            guard !partnerUserID.isEmpty else { return "" }
            return (partnerUserID)
        } catch let error {
            print(error.localizedDescription)
            return ""
        }
    }
}
