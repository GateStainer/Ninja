//
//  Button.swift
//  Ninja
//
//  Created by Push on 1/15/17.
//  Copyright © 2017 Apple inc. All rights reserved.
//




//自定义的Button

import Foundation
import UIKit



import UIKit

class FloatingButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init(image: UIImage?, backgroundColor: UIColor = UIColor.flatBlueColor) {
        self.init()
        setImage(image, for: UIControlState())
        setBackgroundImage(backgroundColor.pixelImage, for: UIControlState())
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        tintColor = UIColor.white
        if backgroundImage(for: UIControlState()) == nil {
            setBackgroundImage(UIColor.flatBlueColor.pixelImage, for: UIControlState())
        }
        
        layer.cornerRadius = frame.width/2
        layer.masksToBounds = true
    }
    
}
