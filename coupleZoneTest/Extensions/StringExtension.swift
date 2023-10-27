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
}
