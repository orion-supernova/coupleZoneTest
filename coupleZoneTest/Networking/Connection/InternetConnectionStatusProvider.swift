//
//  InternetConnectionStatusProvider.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import Foundation

protocol InternetConnectionStatusProvider {
    var isInternetConnectionAvailable: Bool { get }
}

struct ReachabilityConnectionStatusProvider: InternetConnectionStatusProvider {
    var isInternetConnectionAvailable: Bool {
        return ReachabilitySwift.internetConnectionAvailable()
    }
}
