//
//  Colors.swift
//  Ninja
//
//  Created by Push on 11/21/16.
//  Copyright © 2016 Apple inc. All rights reserved.
//

import UIKit

struct Colors {
  static let blue = UIColor(red: 46.0 / 255.0, green: 117.0 / 255.0, blue: 146.0 / 255.0, alpha: 1.0)
  static let red = UIColor(red: 209.0 / 255.0, green: 42.0 / 255.0, blue: 24.0 / 255.0, alpha: 1.0)
  static let white = UIColor.white
  static let clear = UIColor.clear
}



extension UIColor {
    
    
    var pixelImage: UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        
        self.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    class var flatWhiteColor: UIColor {
        return UIColor(red: 0.9274, green: 0.9436, blue: 0.95, alpha: 1.0)
    }
    class var flatBlackColor: UIColor {
        return UIColor(red: 0.1674, green: 0.1674, blue: 0.1674, alpha: 1.0)
    }
    class var flatBlueColor: UIColor {
        return UIColor(red: 0.3132, green: 0.3974, blue: 0.6365, alpha: 1.0)
    }
    class var flatRedColor: UIColor {
        return UIColor(red: 0.9115, green: 0.2994, blue: 0.2335, alpha: 1.0)
    }
}



