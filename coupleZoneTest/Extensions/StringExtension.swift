//
//  StringExtension.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 19.10.2023.
//

import Foundation

extension String {
    func convertStringToDictionary() -> [AnyHashable:Any]? {
        if let data = self.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[AnyHashable:Any]]
                return json?.first
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    func convertStringToDictionaryArray() -> [[AnyHashable:Any]]? {
        if let data = self.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[AnyHashable:Any]]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    func convertStringToDate(receivedformat: String, desiredFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = receivedformat

        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = desiredFormat
            let convertedDateString = dateFormatter.string(from: date)
            return convertedDateString
        } else {
            print("Invalid time string format")
            return ""
        }
    }
}
