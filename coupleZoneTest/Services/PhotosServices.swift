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
            let data = try await supabase.database.from("photosTimeline").select(columns: "*", head: false).execute().underlyingResponse.data
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

    func uploadPhoto(_ image: UIImage) async -> Result<Bool, RequestError> {
        do {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return .failure(.convertImageToDataError) }
            let fileName = UUID().uuidString
            let file = File(name: fileName, data: imageData, fileName: fileName, contentType: "image/jpeg"
            )
            let uploadPhotoToStorage = try await supabase.storage.from(id: "/timelinePhotos").upload(path: "\(fileName).jpeg", file: file, fileOptions: FileOptions(cacheControl: "3600"))
            let urlString = try supabase.storage.from(id: "/timelinePhotos").getPublicURL(path: "\(fileName).jpeg").absoluteString
            print(urlString)
            print(uploadPhotoToStorage)
            let username = await getUsername()
            let dict = ["imageURL": "\(urlString)", "username": username]
            let photosItem = PhotosItem(imageURLString: urlString, username: AppGlobal.shared.username ?? "Anonymous")
            let updateTable = supabase.database.from("photosTimeline").upsert(values: dict)
            try await updateTable.execute()
            return .success(true)
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
}
