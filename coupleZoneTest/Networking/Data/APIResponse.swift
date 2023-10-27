//
//  APIResponse.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 19.10.2023.
//

import Foundation

typealias APIResponse = JSONConvertible & Parseable
typealias JSON = [AnyHashable: Any]

protocol JSONConvertible {
    init?(with json: JSON)
}

protocol Parseable {
    static func parse(_ data: Any) -> Self?
}

extension Parseable where Self: JSONConvertible {
    static func parse(_ data: Any) -> Self? {
        guard let json = data as? JSON else { return nil }
        return Self.init(with: json)
    }
}

extension Array: Parseable where Element: JSONConvertible {
    static func parse(_ data: Any) -> Self? {
        guard let json = data as? [JSON] else { return [] }
        return json.compactMap(Element.init)
    }
}

extension Bool: Parseable {
    static func parse(_ data: Any) -> Bool? {
        return data as? Bool
    }
}
