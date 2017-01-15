//
//  MenuController.swift
//  Ninja
//
//  Created by Push on 1/15/17.
//  Copyright © 2017 Apple inc. All rights reserved.
//



//控制菜单的动画效果


import Foundation
import UIKit




//按下按键收到消息
@objc
protocol FloatingMenuControllerDelegate: class {
    @objc optional func floatingMenuController(_ controller: FloatingMenuController, didTapOnButton button: UIButton, atIndex index: Int)
    @objc optional func floatingmenuControllerDidCancel(_ controller: FloatingMenuController)
}




class FloatingMenuController: UIViewController {
    
    let fromView: UIView
    
    let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let closeButton = FloatingButton(image: UIImage(named: "icon-close"), backgroundColor: UIColor.flatRedColor)
    
    var buttonDirection = Direction.up
    var buttonPadding: CGFloat = 70
    var buttonItems = [UIButton]()
    
    var labelDirection = Direction.left
    var labelTitles = [String]()
    var buttonLabels = [UILabel]()
    
    weak var delegate: FloatingMenuControllerDelegate?
    
    enum Direction {
        case up
        case down
        case left
        case right
        
        func offsetPoint(_ point: CGPoint, offset: CGFloat) -> CGPoint {
            switch self {
            case .up:
                return CGPoint(x: point.x, y: point.y - offset)
            case .down:
                return CGPoint(x: point.x, y: point.y + offset)
            case .left:
                return CGPoint(x: point.x - offset, y: point.y)
            case .right:
                return CGPoint(x: point.x + offset, y: point.y)
            }
        }
    }
    
    init(fromView: UIView) {
        
        self.fromView = fromView
        super.init(nibName: nil, bundle: nil)
        //make the system doesn't remove the presenting view controller.
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configButtons(_ initial: Bool) {
        let parentController = presentingViewController
        let center = parentController!.view.convert(fromView.center, from: fromView.superview)
        
        closeButton.center = center
        
        if initial {
            closeButton.alpha = 0
            closeButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            
            for (_, button) in buttonItems.enumerated() {
                button.center = center
                button.alpha = 0
                button.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            }
            
            for (index, label) in buttonLabels.enumerated() {
                let buttonCenter = buttonDirection.offsetPoint(center, offset: buttonPadding * CGFloat(index+1))
                
                let labelSize = labelDirection == .up || labelDirection == .down ? label.bounds.height : label.bounds.width
                let labelCenter = labelDirection.offsetPoint(buttonCenter, offset: buttonPadding/2 + labelSize)
                label.center = labelCenter
                label.alpha = 0
            }
            
        }else{
            closeButton.alpha = 1
            closeButton.transform = CGAffineTransform.identity
            
            for (index, button) in buttonItems.enumerated() {
                button.center = buttonDirection.offsetPoint(center, offset: buttonPadding * CGFloat(index+1))
                button.alpha = 1
                button.transform = CGAffineTransform.identity
            }
            
            for (index, label) in buttonLabels.enumerated() {
                let buttonCenter = buttonDirection.offsetPoint(center, offset: buttonPadding * CGFloat(index+1))
                
                let labelSize = labelDirection == .up || labelDirection == .down ? label.bounds.height : label.bounds.width
                let labelCenter = labelDirection.offsetPoint(buttonCenter, offset: buttonPadding/2 + labelSize/2)
                label.center = labelCenter
                label.alpha = 1
            }
            
        }
    }
    
    func animateButton(_ visible: Bool) {
        configButtons(visible)
        
    }
    
    func handleCloseMenu(_ sender: AnyObject) {
        delegate?.floatingmenuControllerDidCancel?(self)
        dismiss(animated: true, completion: nil)
    }
    
    //add the method to handle button taps,to find the index to our button and make a call to our delegate
    func handleMenuButton(_ sender: AnyObject) {
        let button = sender as! UIButton
        if let index = buttonItems.index(of: button) {
            delegate?.floatingMenuController!(self, didTapOnButton: button, atIndex: index)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurredView.frame = view.bounds
        view.addSubview(blurredView)
        view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(FloatingMenuController.handleCloseMenu(_:)), for: .touchUpInside)
        view.addSubview(closeButton)
        
        for button in buttonItems {
            button.addTarget(self, action: #selector(FloatingMenuController.handleMenuButton(_:)), for: .touchUpInside)
            view.addSubview(button)
        }
        
        for title in labelTitles {
            let label = UILabel()
            label.text = title
            label.textColor = UIColor.flatBlackColor
            label.textAlignment = .center
            label.font = UIFont(name: "HelveticaNeue-Light", size: 15)
            label.backgroundColor = UIColor.flatWhiteColor
            label.sizeToFit()
            label.bounds.size.height += 8
            label.bounds.size.width += 20
            label.layer.cornerRadius = 4
            label.layer.masksToBounds = true
            view.addSubview(label)
            buttonLabels.append(label)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateButton(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animateButton(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

