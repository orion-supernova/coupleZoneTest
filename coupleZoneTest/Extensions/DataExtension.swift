//
//  DataExtension.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 19.11.2023.
//

import Foundation

extension Data {
    func convertDataToString() -> String {
        if let stringData = String(data: self, encoding: .utf8) {
            return stringData
        } else {
            return ""
        }
    }
}
