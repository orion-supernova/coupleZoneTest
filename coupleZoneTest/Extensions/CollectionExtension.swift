//
//  CollectionExtension.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import Foundation

extension Collection {
    /**
     Get at index object
     
     - Parameters:
        - safeIndex: Index of object
     - Returns:
        - Element at index or nil
     */
    
    subscript (safeIndex index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
