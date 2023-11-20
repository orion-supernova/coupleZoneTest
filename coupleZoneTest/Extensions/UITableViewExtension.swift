//
//  UITableViewExtension.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 12.11.2023.
//

import UIKit

extension UITableView {
    func reloadData(completion:@escaping ()->()) {
        UIView.animate(withDuration: 0, animations: reloadData)
        { _ in completion() }
    }
}
