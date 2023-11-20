//
//  RequestError.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 19.10.2023.
//

import Foundation

enum RequestError: Error {
    case generic
    case convertImageToDataError
}

extension RequestError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .generic:
                return NSLocalizedString("Something went wrong.", comment: "")
            case .convertImageToDataError:
                return NSLocalizedString("Couldn't convert image to data.", comment: "")

        }
    }
}

struct CustomMessageError: Error {
    let message: String?
}
extension CustomMessageError: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
