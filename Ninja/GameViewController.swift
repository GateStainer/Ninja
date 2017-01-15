//
//  GameViewController.swift
//  Ninja
//
//  Created by Push on 11/21/16.
//  Copyright © 2016 Apple inc. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, HolderViewDelegate {

    
    var holderView = HolderView(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHolderView()
       /* let scene = NinjaGameScene(size:CGSize(width: DefinedScreenWidth, height: DefinedScreenHeight))
        
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
        */
        
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func addHolderView() {
        let boxSize: CGFloat = 100.0
        holderView.frame = CGRect(x: view.bounds.width / 2 - boxSize / 2,
                                  y: view.bounds.height / 2 - boxSize / 2,
                                  width: boxSize,
                                  height: boxSize)
        holderView.parentFrame = view.frame
        holderView.delegate = self
        view.addSubview(holderView)
        holderView.addOval()
    }

    
    func animateLabel() {
        // 1
        holderView.removeFromSuperview()
        view.backgroundColor = Colors.blue
        
        // 2
        let label: UILabel = UILabel(frame: view.frame)
        label.textColor = Colors.white
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 170.0)
        label.textAlignment = NSTextAlignment.center
        label.text = "S"
        label.transform = label.transform.scaledBy(x: 0.25, y: 0.25)
        view.addSubview(label)
        
        // 3
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: UIViewAnimationOptions(),
                       animations: ({
                        label.transform = label.transform.scaledBy(x: 4.0, y: 4.0)
                       }), completion: { finished in
                        self.addButton()
        })
    }

    
    func addButton() {
        let button = UIButton()
        button.frame = CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: view.bounds.height)
        button.addTarget(self, action: #selector(GameViewController.buttonPressed(_:)), for: .touchUpInside)
        view.addSubview(button)
    }
    
    func buttonPressed(_ sender: UIButton!) {
        view.backgroundColor = Colors.white
        
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        /*view.subviews.map({ $0.removeFromSuperview() })
        holderView = HolderView(frame: CGRect.zero)
        addHolderView()*/
        let scene = NinjaGameScene(size:CGSize(width: DefinedScreenWidth, height: DefinedScreenHeight))
        
        let skView = self.view as! SKView
        
        skView.showsFPS = false
        
        skView.showsNodeCount = false
        
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
        
    }

}
