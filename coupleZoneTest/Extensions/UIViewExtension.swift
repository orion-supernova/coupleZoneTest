//
//  UIViewExtension.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import UIKit

extension UIView {
    
    func screenshot() -> UIImage {
        let scalingAspect = UIScreen.main.scale
        let contentSize = CGSize(width: bounds.width, height: bounds.height)
        
        UIGraphicsBeginImageContextWithOptions(contentSize, false, scalingAspect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        layer.render(in: context)
        guard let screenshot = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        
        UIGraphicsEndImageContext()
        
        return screenshot
    }
    
    func animateView(cycles: Int, duration: Double, alpha: CGFloat, hide: Bool, completion:@escaping (Bool) -> () = { _ in }){
        let cycleDuration = duration / Double(cycles * 2)
        self.fadeInOut(duration: cycleDuration, cycles: cycles, alpha: alpha, hide: hide, completion: completion)
    }
    
    func animateView(cycles: Int, duration: Double, alpha: CGFloat, hide: Bool) {
        animateView(cycles: cycles, duration: duration, alpha: alpha, hide: hide, completion:  { _ in })
    }
    
    private func fadeInOut(duration: Double, cycles: Int, alpha: CGFloat, hide: Bool, completion:@escaping (Bool) -> () = { _ in }){
        self.fadeOut(duration: duration, alpha: alpha) { (completed) in
            if !completed {
                // self.isHidden = hide
                return
            }
            let currentCycles = cycles - 1
            if currentCycles >= 0 {
                self.fadeInOut(duration: duration, cycles: currentCycles, alpha: alpha, hide: hide, completion: completion)
            }else {
                // self.isHidden = hide
                completion(true)
            }
        }
    }
    
    private func fadeIn(duration: Double, alpha: CGFloat,completion: @escaping (_ isCompleted: Bool) -> Void){
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion:  { (completed) in
            completion(completed)
        })
    }
    
    
    private func fadeOut(duration: Double, alpha: CGFloat, completion: @escaping (_ isCompleted: Bool) -> Void){
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.alpha = alpha
        }, completion: { (completed) in
            self.fadeIn(duration: duration, alpha: alpha, completion: { (completed) in
                completion(completed)
            })
        })
    }
    
    public func round(corners: UIRectCorner, radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners.caCornerMaskValue()
    }
    
    public func addBorder(borderColor: UIColor, borderWidth: CGFloat) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
}

extension UIRectCorner {
    func caCornerMaskValue() -> CACornerMask {
        /*
         layerMaxXMaxYCorner - bottom right corner
         layerMaxXMinYCorner - top right corner
         layerMinXMaxYCorner - bottom left corner
         layerMinXMinYCorner - top left corner
         */
        
        if self.contains(.allCorners) {
            return [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        }
        
        var result = CACornerMask()
        
        if self.contains(.bottomLeft) {
            result.insert(.layerMinXMaxYCorner)
        }
        
        if self.contains(.bottomRight) {
            result.insert(.layerMaxXMaxYCorner)
        }
        
        if self.contains(.topLeft) {
            result.insert(.layerMinXMinYCorner)
        }
        
        if self.contains(.topRight) {
            result.insert(.layerMaxXMinYCorner)
        }
        
        return result
    }
}
