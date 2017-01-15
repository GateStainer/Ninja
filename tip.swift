//
//  tip.swift
//  Ninja
//
//  Created by Push on 1/15/17.
//  Copyright © 2017 Apple inc. All rights reserved.
//


//棍子伸长，旋转的动画效果

import Foundation
import UIKit



struct Tip {
    let title:String
    let summary: String
    let image: UIImage?
}




class TipView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var surmmaryLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var tip: Tip? {
        didSet {
            titleLabel.text = tip?.title ?? "No Title"
            surmmaryLabel.text = tip?.summary ?? "No Summary"
            imageView.image = tip?.image
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    override func alignmentRect(forFrame frame: CGRect) -> CGRect {
        return bounds
    }
    
}



private let kTipViewOffset: CGFloat = 500
private let kTipViewHeight: CGFloat = 400
private let kTipViewWidth: CGFloat = 300

class TipViewViewController: UIViewController {
    
    var tips = [Tip]()
    var index = 0
    
    var tipView: TipView!
    var animator: UIDynamicAnimator!
    var attachmentBehavior: UIAttachmentBehavior!
    var snapBehavior: UISnapBehavior!
    var panBehavior: UIAttachmentBehavior!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设为白色则不会使界面全黑
        self.view.backgroundColor = UIColor(white: 1, alpha: 0.6)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAnimator()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    enum TipViewPosition: Int {
        case `default`
        case rotatedLeft
        case rotatedRight
        
        func viewCenter(_ center: CGPoint) -> CGPoint {
            var center = center
            switch self {
            case .rotatedLeft:
                center.y += kTipViewOffset
                center.x -= kTipViewOffset
            case .rotatedRight:
                center.y += kTipViewOffset
                center.x += kTipViewOffset
            default:
                ()
            }
            return center
        }
        func viewTransform() -> CGAffineTransform {
            switch self {
            case .rotatedLeft:
                return CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
                
            case .rotatedRight:
                return CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
                
            default:
                return CGAffineTransform.identity
            }
        }
    }
    
    func createTipView() -> TipView? {
        
        if let view = UINib(nibName: "TipView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! TipView? {
            
            view.frame = CGRect(x: 0, y: 0, width: kTipViewWidth, height: kTipViewHeight)
            
            return view
        }
        return nil
    }
    
    func updateTipView(_ tipView: UIView, position: TipViewPosition) {
        let center = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        tipView.center = position.viewCenter(center)
        tipView.transform = position.viewTransform()
    }
    
    func resetTipView(_ tipView: UIView, position: TipViewPosition) {
        animator.removeAllBehaviors()
        
        updateTipView(tipView, position: position)
        animator.updateItem(usingCurrentState: tipView)
        
        animator.addBehavior(attachmentBehavior)
        animator.addBehavior(snapBehavior)
    }
    
    func setupAnimator() {
        animator = UIDynamicAnimator(referenceView: view)
        
        var center = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        
        tipView = createTipView()
        view.addSubview(tipView)
        snapBehavior = UISnapBehavior(item: tipView, snapTo: center)
        
        center.y += kTipViewOffset
        attachmentBehavior = UIAttachmentBehavior(item: tipView, offsetFromCenter: UIOffset(horizontal: 0, vertical: kTipViewOffset), attachedToAnchor: center)
        
        setupTipView(tipView, index: 0)
        resetTipView(tipView, position: .rotatedRight)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(TipViewViewController.panTipView(_:)))
        view.addGestureRecognizer(pan)
        
    }
    
    func panTipView(_ pan: UIPanGestureRecognizer) {
        let location = pan.location(in: view)
        
        switch pan.state {
        case .began:
            animator.removeBehavior(snapBehavior)
            panBehavior = UIAttachmentBehavior(item: tipView, attachedToAnchor: location)
            animator.addBehavior(panBehavior)
            
        case .changed:
            panBehavior.anchorPoint = location
            
        case .ended:
            fallthrough
        case .cancelled:
            let center = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
            let offset = location.x - center.x
            if fabs(offset) < 100 {
                animator.removeBehavior(panBehavior)
                animator.addBehavior(snapBehavior)
            }else{
                
                var nextIndex = self.index
                var position = TipViewPosition.rotatedRight
               
                
                if offset > 0 {
                    nextIndex -= 1
                    position = .rotatedRight
                }else{
                    nextIndex += 1
                    position = .rotatedLeft
                }
                
                if nextIndex < 0 {
                    nextIndex = 0

                }
                
                //                let position = offset > 0 ? TipViewPosition.RotatedRight : TipViewPosition.RotatedLeft
                //                let nextPosition = offset > 0 ? TipViewPosition.RotatedLeft : TipViewPosition.RotatedRight
               
                
                let center = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
                
                panBehavior.anchorPoint = position.viewCenter(center)
                
            }
        default:
            ()
        }
    }
    
    func setupTipView(_ tipView: TipView, index: Int) {
        if index < tips.count {
            let tip = tips[index]
            tipView.tip = tip
            
            
            tipView.pageControl.numberOfPages = tips.count
            tipView.pageControl.currentPage = index
        }else{
            tipView.tip = nil
        }
    }
    
}



extension UIViewController {
    
    func presentTips(_ tips: [Tip], animated: Bool, completion: (() -> Void)?) {
        
        let controller = TipViewViewController()
        controller.tips = tips
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: animated, completion: completion)
    }
}



