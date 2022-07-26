//
//  Image+.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/25.
//

import UIKit
import Kingfisher

extension UIImage {
    
    func resizeImageTo(size: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    var roundedImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: self.size.height
            ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
}

extension UIImageView {
    func setImage(url: String) {
        guard let url = try! URL(string: url) else { return }
        
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url, options: [.transition(.fade(0.3)), .forceTransition, .keepCurrentImageWhileLoading])
    }
    
    func setImage(url: URL) {
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url, options: [.transition(.fade(0.3)), .forceTransition, .keepCurrentImageWhileLoading])
    }
}
