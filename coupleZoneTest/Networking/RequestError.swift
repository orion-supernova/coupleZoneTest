//
//  RequestError.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 19.10.2023.
//

import Foundation

enum RequestError: Error {
    case generic
}

extension RequestError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .generic:
            return NSLocalizedString("Something went wrong", comment: "")
        }
    }
}
