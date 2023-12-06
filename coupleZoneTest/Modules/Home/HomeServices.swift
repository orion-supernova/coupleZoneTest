//
//  HomeServices.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import Foundation
import UIKit.UIImage
import Supabase

class HomeServices {
    
    let supabase = SensitiveData.supabase

    // MARK: - Public Methods
    func getHomeInfo() async -> Result<HomeItem, RequestError> {
        do {
            guard let userID = AppGlobal.shared.user?.id else { return .failure(.generic) }
            let homeIDData = try await supabase.database.from("users").select("homeID").eq("userID", value: userID).execute().data
            let homeIDStringData = String(data: homeIDData, encoding: .utf8) ?? ""
            let homeIDDict = homeIDStringData.convertStringToDictionary()
            let homeID = homeIDDict?["homeID"] as? String ?? ""
            let homeData = try await supabase.database.from("homes").select("*", head: false).eq("id", value: homeID).execute().data
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
            let fileData = File(name: fileName, data: imageData, fileName: fileName, contentType: "image/jpeg").data
            let homeID = await getHomeID()
            let uploadPhotoToStorage = try await supabase.storage.from("homes/\(homeID)/homePhotos").upload(path: "\(fileName).jpeg", file: fileData, options: .init(cacheControl: "3600"))
            let urlString = try supabase.storage.from("homes/\(homeID)/homePhotos").getPublicURL(path: "\(fileName).jpeg").absoluteString
            print(urlString)
            print(uploadPhotoToStorage)
            try await supabase.database.from("homes").update(["imageURLString": urlString]).eq("id", value: homeID).execute()
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
            let pushDevicesIDArray = try await SensitiveData.supabase.database.from("users").select("pushSubscriptionIDs").eq("userID", value: partnerUserID).execute().data.convertDataToString().convertStringToDictionary()?["pushSubscriptionIDs"] as? [String] ?? []
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
            let partnerUsername = try await SensitiveData.supabase.database.from("users").select("username").eq("userID", value: partnerUserID).execute().data.convertDataToString().convertStringToDictionary()?["username"] as? String ?? ""
            return .success(partnerUsername)
        } catch let error {
            return .failure(.init(message: error.localizedDescription))
        }
    }
    // MARK: - Private Methods
    private func getHomeID() async -> String {
        do {
            guard let userID = AppGlobal.shared.user?.id else { return "" }
            let userDict = try await SensitiveData.supabase.database.from("users").select("*").eq("userID", value: userID).execute().data.convertDataToString().convertStringToDictionary()
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
            let partnerUserID = try await SensitiveData.supabase.database.from("users").select("partnerUserID").eq("userID", value: userID).execute().data.convertDataToString().convertStringToDictionary()?["partnerUserID"] as? String ?? ""
            guard !partnerUserID.isEmpty else { return "" }
            return (partnerUserID)
        } catch let error {
            print(error.localizedDescription)
            return ""
        }
    }
}
