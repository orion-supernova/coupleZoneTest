//
//  UIImageViewExtension.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import UIKit
import Kingfisher

@objc extension UIImageView {
    
    func makeCircular() {
        layer.cornerRadius  = bounds.size.height/2
        layer.masksToBounds = true
        clipsToBounds       = true
    }
    
    func setImage(url: URL?, placeholder: UIImage? = nil) {
        kf.setImage(with: url, placeholder: placeholder)
    }
    
    func setImage(urlString: String?, placeholder: UIImage? = nil) {
        guard let urlString, let url = URL(string: urlString) else { return }
        setImage(url: url, placeholder: placeholder)
    }
}
