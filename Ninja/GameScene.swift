



//
//  GameScene.swift
//  Ninja
//
//  Created by Push on 11/21/16.
//  Copyright © 2016 Apple inc. All rights reserved.
//






//游戏主要逻辑代码

import SpriteKit
import GameplayKit


//用于菜单项的渐隐和渐出
extension SKAction {
    class func moveDistance(_ distance:CGVector, fadeInWithDuration duration:TimeInterval) -> SKAction {
        let fadeIn = SKAction.fadeIn(withDuration: duration)
        let moveIn = SKAction.move(by: distance, duration: duration)
        return SKAction.group([fadeIn, moveIn])
    }
    
    class func moveDistance(_ distance:CGVector, fadeOutWithDuration duration:TimeInterval) -> SKAction {
        let fadeOut = SKAction.fadeOut(withDuration: duration)
        let moveOut = SKAction.move(by: distance, duration: duration)
        return SKAction.group([fadeOut, moveOut])
    }
}



//在一定范围内生成随机的Int数
func randomInRange(_ range: ClosedRange<Int>) -> Int {
    let count = UInt32(range.upperBound - range.lowerBound)
    return  Int(arc4random_uniform(count)) + range.lowerBound
}



//在一定范围内生成随机的CGFloat数
func random(_ range: ClosedRange<CGFloat>) -> CGFloat {
    let count = (range.upperBound - range.lowerBound)
    let my_float = CGFloat(arc4random_uniform(UInt32(count)))
    return  my_float + range.lowerBound
}



//Scene类
class NinjaGameScene: SKScene, SKPhysicsContactDelegate {
    
    
    struct GAP {
        
        static let XGAP:CGFloat = 20
        static let YGAP:CGFloat = 4
        
    }
   
    
    let StackHeight:CGFloat = 400.0
    
    let StackMaxWidth:CGFloat = 300.0
    
    let StackMinWidth:CGFloat = 100.0
    
    let gravity:CGFloat = -100.0
    
    let StackGapMinWidth:Int = 80
    
    let HeroSpeed:CGFloat = 500
    
    let MonsterLow:CGFloat = 100
    
    let MonsterHigh:CGFloat = 600
    
    var isBegin = false                               //human begins to move
    
    var isEnd = false                                 //human stops moving
    
    var nextLeftStartX:CGFloat = 0
    
    var stickHeight:CGFloat = 0
    
    let StoreScoreName = "com.Ninja.score"

    
    
    
    //用于Ninja和monster的碰撞检测
    let heroCatagory: UInt32 = 0x1 << 0
    let monsterCategory: UInt32 = 0x1 << 1
    
    
    //判断是否开始碰撞
    var collision_start = false
    
    
    
    var gameOver = false {
        willSet {
            if (newValue) {
                checkHighScoreAndStore()
                let hero = childNode(withName: NinjaGameSceneChildName.HeroName.rawValue) as? SKSpriteNode
                hero?.physicsBody?.affectedByGravity = true
                hero?.physicsBody?.isDynamic = true

                let gameOverLayer = childNode(withName: NinjaGameSceneChildName.GameOverLayerName.rawValue) as SKNode?
                gameOverLayer?.run(SKAction.moveDistance(CGVector(dx:0,dy:100), fadeInWithDuration: 0.2))
                
            }
        }
    }
    
    
    
    
    //会根据score的大小做出加载不同的背景，产生monster等动作
    var score:Int = 0 {
        willSet {
            let scoreBand = childNode(withName: NinjaGameSceneChildName.ScoreName.rawValue) as? SKLabelNode
            scoreBand?.text = "\(newValue)"
            scoreBand?.run(SKAction.sequence([SKAction.scale(to: 1.5, duration: 0.1), SKAction.scale(to: 1, duration: 0.1)]))
            
            if (newValue == 1) {
                let tip = childNode(withName: NinjaGameSceneChildName.TipName.rawValue) as? SKLabelNode
                tip?.run(SKAction.fadeAlpha(to: 0, duration: 0.4))
            }
            
            if(newValue==1)
            {
                loadBackground(2,layer: 1.0)
            }
            
            if(newValue==3)
            {
                loadBackground(3,layer: 2.0)
            }
            
            if(newValue==5)
            {
                loadBackground(4,layer: 3.0)
            }
            
            if(newValue==7)
            {
                loadBackground(5,layer: 4.0)
            }
            
            if(newValue==10)
            {
                loadBackground(6,layer: 5.0)
            }
            
            if(newValue==15)
            {
                loadBackground(7,layer: 6.0)
            }
            
        }
    }
    
    
    //根据当前血量做出动作
    var blood:Int = 3{
        willSet{
            let bloodBand = childNode(withName: NinjaGameSceneChildName.BloodName.rawValue) as? SKLabelNode
            bloodBand?.text = "\(newValue)"
            bloodBand?.run(SKAction.sequence([SKAction.scale(to: 1.5, duration: 0.1), SKAction.scale(to: 1, duration: 0.1)]))
            if(newValue == 0)
            {
                //let hero = childNode(withName: NinjaGameSceneChildName.HeroName.rawValue) as? SKSpriteNode
                //hero?.physicsBody?.affectedByGravity = true
                gameOver = true
            }
        
        
        }
    }
    
    
    
    
    var leftStack:SKShapeNode?
    var rightStack:SKShapeNode?
    
    
    
    
    //游戏区域
    lazy var playAbleRect:CGRect = {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let maxAspectRatioWidth = self.size.height / maxAspectRatio
        let playableMargin = (self.size.width - maxAspectRatioWidth) / 2.0
        return CGRect(x: playableMargin, y: 0, width: maxAspectRatioWidth, height: self.size.height)
    }()
    
    
    //monster的移动
    lazy var monsterAction:SKAction = {
        
        
        
        let action1 = SKAction.moveBy(x:0, y:800, duration: 3)
        let action2 = SKAction.moveBy(x:0, y:-900, duration: 3)
        let action = SKAction.sequence([action1,action2])
        return SKAction.repeatForever(action)
    }()
    
    
    
    lazy var secondmonsterAction:SKAction = {
        
        let action1 = SKAction.moveBy(x:0, y:-900,duration:2.5)
        let action2 = SKAction.moveBy(x:0, y:800, duration:2.5)
        
        let action = SKAction.sequence([action1,action2])
        return SKAction.repeatForever(action)
        
        
    }()
    
    
    
    lazy var birdAction:SKAction = {
        
        let action = SKAction.moveBy(x: -DefinedScreenWidth, y: 0, duration: 8)
        
        return action
    }()
    
    lazy var bird_moveAction:SKAction = {
        var textures:[SKTexture] = []
        for i in 1...7{
            
            let texture = SKTexture(imageNamed: "bird\(i).png")
            textures.append(texture)
        }
        
        let action = SKAction.animate(with: textures, timePerFrame:0.4,resize: true, restore: true)
        
        return SKAction.repeatForever(action)
    }()
    
    
    
    //Ninja的移动
    lazy var walkAction:SKAction = {
        var textures:[SKTexture] = []
        for i in 0...1 {
            let texture1 = SKTexture(imageNamed: "rabbit\(i + 1).png")
            let texture2 = SKTexture(imageNamed: "rabbit\(i + 2).png")
            textures.append(texture1)
            textures.append(texture2)
        }
        
        let action = SKAction.animate(with: textures, timePerFrame: 0.1, resize: true, restore: true)
        
        return SKAction.repeatForever(action)
    }()
    
    
    
    
    lazy var monster_moveAction:SKAction = {
        var textures:[SKTexture] = []
        for i in 0...1 {
            let texture1 = SKTexture(imageNamed: "monkey\(i + 1).png")
            let texture2 = SKTexture(imageNamed: "monkey\(i + 2).png")
            textures.append(texture1)
            textures.append(texture2)
        }
        
        let action = SKAction.animate(with: textures, timePerFrame: 0.1, resize: true, restore: true)
        
        return SKAction.repeatForever(action)
    }()

    
    

    
    
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        //physicsWorld.contactDelegate = self
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        start()
    }
    
    
    
    //开始按住屏幕
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !gameOver else {
            let gameOverLayer = childNode(withName: NinjaGameSceneChildName.GameOverLayerName.rawValue) as SKNode?
            
            let location = touches.first?.location(in: gameOverLayer!)
            let retry = gameOverLayer!.atPoint(location!)
            
            
            if (retry.name == NinjaGameSceneChildName.RetryButtonName.rawValue) {
                retry.run(SKAction.sequence([SKAction.setTexture(SKTexture(imageNamed: "button_retry_down"), resize: false), SKAction.wait(forDuration: 0.3)]), completion: {[unowned self] () -> Void in
                    self.restart()
                })
            }
            return
        }
        
        if !isBegin && !isEnd {
            isBegin = true
            
            let stick = loadStick()
            let hero = childNode(withName: NinjaGameSceneChildName.HeroName.rawValue) as! SKSpriteNode
            
            let action = SKAction.resize(toHeight: CGFloat(DefinedScreenHeight - StackHeight), duration: 1.5)
            stick.run(action, withKey:NinjaGameSceneActionKey.StickGrowAction.rawValue)
            
            let scaleAction = SKAction.sequence([SKAction.scaleY(to: 0.9, duration: 0.05), SKAction.scaleY(to: 1, duration: 0.05)])
            hero.run(SKAction.repeatForever(scaleAction), withKey: NinjaGameSceneActionKey.HeroScaleAction.rawValue)
            
            return
        }
        
    }

    
    //结束按住屏幕
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isBegin && !isEnd {
            isEnd  = true
            
            let hero = childNode(withName: NinjaGameSceneChildName.HeroName.rawValue) as! SKSpriteNode
            hero.removeAction(forKey: NinjaGameSceneActionKey.HeroScaleAction.rawValue)
            hero.run(SKAction.scaleY(to: 1, duration: 0.04))
            
            let stick = childNode(withName: NinjaGameSceneChildName.StickName.rawValue) as! SKSpriteNode
            stick.removeAction(forKey: NinjaGameSceneActionKey.StickGrowAction.rawValue)
            stick.removeAction(forKey: NinjaGameSceneActionKey.StickGrowAudioAction.rawValue)
           
            
            stickHeight = stick.size.height;
            
            let action = SKAction.rotate(toAngle: CGFloat(-M_PI / 2), duration: 0.4, shortestUnitArc: true)
           
            
            stick.run(SKAction.sequence([SKAction.wait(forDuration: 0.2), action]), completion: {[unowned self] () -> Void in
                self.heroGo(self.checkPass())
            })
        }
    }

    
    //加载所有Node，开始游戏
    func start() {
        
        loadBackground(1,layer: 0.0)
        
        loadScoreBackground()
        
        loadScore()
        
        loadBlood()
        
        loadTip()
        
        loadGameOverLayer()
        
        loadBird()
        
        
        leftStack = loadStacks(false, startLeftPoint: playAbleRect.origin.x)
        self.removeMidTouch(false, left:true)
        loadHero()
        let maxGap = Int(playAbleRect.width - StackMaxWidth - (leftStack?.frame.size.width)!)
        
        let gap = CGFloat(randomInRange(StackGapMinWidth...maxGap))
        rightStack = loadStacks(false, startLeftPoint: nextLeftStartX + gap)
        
        
        loadMonster()
        
        gameOver = false
        
        
        
        //physicsWorld.contactDelegate = self
        
        /*
        let monster = self.childNode(withName: NinjaGameSceneChildName.MonsterName.rawValue ) as? SKSpriteNode
        monster?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: (monster?.size.width)!, height: (monster?.size.height)!))
        monster?.physicsBody?.collisionBitMask = 1
        monster?.physicsBody?.affectedByGravity = false
        monster?.physicsBody?.contactTestBitMask = 1
        monster?.physicsBody?.categoryBitMask = 1
 
 
        */
        
        //let hero = self.childNode(withName: NinjaGameSceneChildName.HeroName.rawValue) as? SKSpriteNode
       
        
        //hero?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: (hero?.size.width)!, height: (hero?.size.height)!))
        
        
        
        /*
        hero?.physicsBody?.collisionBitMask = 1
         
        hero?.physicsBody?.contactTestBitMask = 1
         
        hero?.physicsBody?.categoryBitMask = 1
 
 
 
        */
        
        
        /*
        print(monster!.size.width)
        
        print(monster!.size.height)
        
        print(hero!.size.width)
        
        print(hero!.size.height)
        */
        
        
    }
    /*
    
    func didBeginContact(contact: SKPhysicsContact){
        print("hh")
        gameOver = true
    }
    */
    
    
    
    
    //检测碰撞开始
    func didBegin(_ contact: SKPhysicsContact) {
        
        if(collision_start == false)
        {
            
            collision_start = true
            if(blood > 1)
            {
                blood -= 1
            
                let hero = childNode(withName: NinjaGameSceneChildName.HeroName.rawValue) as! SKSpriteNode
                //hero.run(SKAction.rotate(byAngle: 3.14159265357, duration: 0.5))
            
                //hero.physicsBody?.isDynamic = false

            
                let scale = SKAction.sequence([SKAction.scale(to: 0.7, duration: 0.3), SKAction.scale(to: 1, duration: 0.3)])
                hero.run(scale)
            
            
                let monster = childNode(withName: NinjaGameSceneChildName.MonsterName.rawValue) as! SKSpriteNode
                monster.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
                
                if let monster2 = childNode(withName: NinjaGameSceneChildName.SecondMonsterName.rawValue)
                {
                    monster2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
                }
            
            }
            else
            {
                let hero = childNode(withName: NinjaGameSceneChildName.HeroName.rawValue) as! SKSpriteNode
                hero.removeAllActions()
            
                //hero.physicsBody?.isDynamic = true
            
                let monster = childNode(withName: NinjaGameSceneChildName.MonsterName.rawValue) as! SKSpriteNode
                monster.removeAllActions()
            
            
                
                if let monster2 = childNode(withName: NinjaGameSceneChildName.SecondMonsterName.rawValue)
                {
                    monster2.removeAllActions()
                }
                
                
                //hero.physicsBody?.affectedByGravity = true
            
                gameOver = true
            
            }
        
        }
        
        
    }
    
    //检测碰撞结束
    func didEnd(_ contact: SKPhysicsContact) {
        //let hero = childNode(withName: NinjaGameSceneChildName.HeroName.rawValue) as! SKSpriteNode
        //hero.run(SKAction.rotate(byAngle: 3.14159265357, duration: 0.5))
        
        //hero.physicsBody?.isDynamic = true


    }
    
    func restart() {
        //记录分数
        //if (blood == 1){
            isBegin = false
            isEnd = false
            score = 0
            blood = 3
            nextLeftStartX = 0
            removeAllChildren()
            start()
       // }
            
//        else{
//            //isBegin = false
//            //isEnd = false
//            //score = 0
//            blood -= 1
//            nextLeftStartX = 0
//            //removeAllChildren()
//            //start()
//        }
    }
    
    
    
    fileprivate func showHighScore() {
        
        
    }
    
    fileprivate func checkHighScoreAndStore() {
        let highScore = UserDefaults.standard.integer(forKey: StoreScoreName)
        if (score > Int(highScore)) {
            showHighScore()
            
            UserDefaults.standard.set(score, forKey: StoreScoreName)
            UserDefaults.standard.synchronize()
        }
    }

    
    
    //remove the mid 20X20
    fileprivate func removeMidTouch(_ animate:Bool, left:Bool) {
        let stack = left ? leftStack : rightStack
        let mid = stack?.childNode(withName: NinjaGameSceneChildName.StackMidName.rawValue) as? SKShapeNode
        if (animate) {
            mid?.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
        }
        else {
            mid?.removeFromParent()
        }
    }

  
    fileprivate func checkPass() -> Bool {
        let stick = childNode(withName: NinjaGameSceneChildName.StickName.rawValue) as! SKSpriteNode
        
        let rightPoint = DefinedScreenWidth / 2 + stick.position.x + self.stickHeight
    
        
        guard (rightPoint < self.nextLeftStartX && rightPoint > self.nextLeftStartX - (self.rightStack?.frame.width)!)
            else
        {
            return false
        }
        
       /* guard ((leftStack?.frame)!.intersects(stick.frame) && (rightStack?.frame)!.intersects(stick.frame)) else {
            return false
        }*/
        
        
        self.checkTouchMidStack()
        
        return true
    }

    
    fileprivate func checkTouchMidStack() {
        let stick = childNode(withName: NinjaGameSceneChildName.StickName.rawValue) as! SKSpriteNode
        let stackMid = rightStack!.childNode(withName: NinjaGameSceneChildName.StackMidName.rawValue) as! SKShapeNode
        
        let newPoint = stackMid.convert(CGPoint(x: -10, y: 10), to: self)
        
        /*if ((stick.position.x + self.stickHeight) >= newPoint.x + 8  && (stick.position.x + self.stickHeight) <= newPoint.x + 12){
            //闪出特效 精准 +3分  也没起作用 why??
            loadPerfect_3Points()
            score += 3
            
        }*/
        
        if ((stick.position.x + self.stickHeight) >= newPoint.x  && (stick.position.x + self.stickHeight) <= newPoint.x + 20) {
            
            loadPerfect()
            score += 1
        }
        
        else {
            //score -= 1
            
//               var current_blood = blood
//                var current_score = score
//                nextLeftStartX = 0
//                removeAllChildren()
//                start()
        }
        
    }

    
    
    //Ninja移动
    fileprivate func heroGo(_ pass:Bool) {
        
        collision_start = false
        
        let hero = childNode(withName: NinjaGameSceneChildName.HeroName.rawValue) as! SKSpriteNode
        
        guard pass else {
            let stick = childNode(withName: NinjaGameSceneChildName.StickName.rawValue) as! SKSpriteNode
            
            let dis:CGFloat = stick.position.x + self.stickHeight
            
            let overGap = DefinedScreenWidth / 2 - abs(hero.position.x)
            let disGap = nextLeftStartX - overGap - (rightStack?.frame.size.width)! / 2
            
            let move = SKAction.moveTo(x: dis, duration: TimeInterval(abs(disGap / HeroSpeed)))
            
            //if(self.blood == 0){
            hero.run(walkAction, withKey: NinjaGameSceneActionKey.WalkAction.rawValue)
            hero.run(move, completion: {[unowned self] () -> Void in
                stick.run(SKAction.rotate(toAngle: CGFloat(-M_PI), duration: 0.4))
                
                //hero.physicsBody!.affectedByGravity = true
               
                hero.removeAction(forKey: NinjaGameSceneActionKey.WalkAction.rawValue)
                self.run(SKAction.wait(forDuration: 0), completion: {[unowned self] () -> Void in
                        self.gameOver = true
                })
            })
            
                
            //}
            
//            else{
//                let current_blood = blood
//                let current_score = score
//                nextLeftStartX = 0
//                blood = current_blood
//                score = current_score
//                removeAllChildren()
//                start()
//                
//            }
            return
        }
        
        let dis:CGFloat = nextLeftStartX - DefinedScreenWidth / 2 - hero.size.width / 2 - GAP.XGAP
        
        let overGap = DefinedScreenWidth / 2 - abs(hero.position.x)
        let disGap = nextLeftStartX - overGap - (rightStack?.frame.size.width)! / 2
        
        let move = SKAction.moveTo(x: dis, duration: TimeInterval(abs(disGap / HeroSpeed)))
        
        hero.run(walkAction, withKey: NinjaGameSceneActionKey.WalkAction.rawValue)
        hero.run(move, completion: { [unowned self]() -> Void in
            self.score += 1
            
            hero.removeAction(forKey: NinjaGameSceneActionKey.WalkAction.rawValue)
            let monster = self.childNode(withName: NinjaGameSceneChildName.MonsterName.rawValue ) as? SKSpriteNode
            monster?.removeFromParent()
            
            
            if let monster2 = self.childNode(withName: NinjaGameSceneChildName.SecondMonsterName.rawValue)
            {
                monster2.removeFromParent()
            }
            
            
            self.moveStackAndCreateNew()
            
        }) 
    }



    
    fileprivate func moveStackAndCreateNew() {
    let action = SKAction.move(by: CGVector(dx: -nextLeftStartX + (rightStack?.frame.size.width)! + playAbleRect.origin.x - 2, dy: 0), duration: 0.3)
    rightStack?.run(action)
    self.removeMidTouch(true, left:false)
    
    let hero = childNode(withName: NinjaGameSceneChildName.HeroName.rawValue) as! SKSpriteNode
    let stick = childNode(withName: NinjaGameSceneChildName.StickName.rawValue) as! SKSpriteNode
    
    hero.run(action)
    stick.run(SKAction.group([SKAction.move(by: CGVector(dx: -DefinedScreenWidth, dy: 0), duration: 0.5), SKAction.fadeAlpha(to: 0, duration: 0.3)]), completion: { () -> Void in
        stick.removeFromParent()
    })
    
    leftStack?.run(SKAction.move(by: CGVector(dx: -DefinedScreenWidth, dy: 0), duration: 0.5), completion: {[unowned self] () -> Void in
        self.leftStack?.removeFromParent()
        
        let maxGap = Int(self.playAbleRect.width - (self.rightStack?.frame.size.width)! - self.StackMaxWidth)
        let gap = CGFloat(randomInRange(self.StackGapMinWidth...maxGap))
        
        self.leftStack = self.rightStack
        self.rightStack = self.loadStacks(true, startLeftPoint:self.playAbleRect.origin.x + (self.rightStack?.frame.size.width)! + gap)
    })
    }
}



private extension NinjaGameScene {
    
    
    //background texture
    func loadBackground(_ num:Int,layer current_layer:CGFloat) {
        if(num>1)
        {
            let oldBackground = childNode(withName: NinjaGameSceneChildName.BackgroundName.rawValue + "\(num-1)") as?SKSpriteNode
            oldBackground?.run(SKAction.fadeOut(withDuration:0.5), completion: {[] () -> Void in oldBackground?.removeFromParent()})
        }
        let texture = SKTexture(image: UIImage(named: "background\(num)")!)
        let node = SKSpriteNode(texture: texture)
        node.name = NinjaGameSceneChildName.BackgroundName.rawValue + "\(num)"
        node.size.height = self.size.height
        node.size.width = self.size.width
        node.position=CGPoint(x: self.frame.midX, y: self.frame.midY)
        node.zPosition = current_layer
        self.physicsWorld.gravity = CGVector(dx: 0, dy: gravity)
        addChild(node)
        node.alpha=0
        node.run(SKAction.fadeIn(withDuration:0.5))
        
        return
    }
    
    
    //rect score table
    func loadScoreBackground() {
        let back = SKShapeNode(rect: CGRect(x: 0-130, y: DefinedScreenHeight/2-200-30, width: 320, height: 120), cornerRadius: 20)
        back.zPosition = NinjaGameSceneZposition.scoreBackgroundZposition.rawValue
        back.fillColor = SKColor.lightGray
        back.strokeColor = SKColor.white
        addChild(back)
    }
    
    
    //current score
    func loadScore() {
        let scoreBand = SKLabelNode(fontNamed: "Chalkduster")
        scoreBand.name = NinjaGameSceneChildName.ScoreName.rawValue
        scoreBand.text = "0"
        scoreBand.position = CGPoint(x: 130, y: DefinedScreenHeight / 2 - 200)
        scoreBand.fontColor = SKColor.red
        scoreBand.fontSize = 65
        scoreBand.zPosition = NinjaGameSceneZposition.scoreZposition.rawValue
        scoreBand.horizontalAlignmentMode = .center
       
        let scoreTitle = SKLabelNode(fontNamed: "Chalkduster")
        scoreTitle.name = NinjaGameSceneChildName.ScoreName.rawValue
        scoreTitle.text = "Score"
        scoreTitle.position = CGPoint(x: 0, y: DefinedScreenHeight / 2 - 200)
        scoreTitle.fontColor = SKColor.red
        scoreTitle.fontSize = 60
        scoreTitle.zPosition = NinjaGameSceneZposition.scoreZposition.rawValue
        scoreTitle.horizontalAlignmentMode = .center

        
        addChild(scoreBand)
        addChild(scoreTitle)
    }
    
    
    //current blood
    func loadBlood(){
        let bloodBand = SKLabelNode(fontNamed: "Chalkduster")
        bloodBand.name = NinjaGameSceneChildName.BloodName.rawValue
        bloodBand.text = "3"
        bloodBand.position = CGPoint(x: 430, y: DefinedScreenHeight / 2 - 230)
        bloodBand.fontColor = SKColor.red
        bloodBand.fontSize = 50
        bloodBand.zPosition = NinjaGameSceneZposition.bloodZposition.rawValue
        bloodBand.horizontalAlignmentMode = .right
        
        let bloodTitle = SKLabelNode(fontNamed: "Chalkduster")
        bloodTitle.text = "Blood: "
        bloodTitle.name = NinjaGameSceneChildName.BloodName.rawValue
        
        bloodTitle.position = CGPoint(x: 390, y: DefinedScreenHeight / 2 - 230)
        bloodTitle.fontColor = SKColor.red
        bloodTitle.fontSize = 45
        bloodTitle.zPosition = NinjaGameSceneZposition.bloodZposition.rawValue
        bloodTitle.horizontalAlignmentMode = .right
        
        addChild(bloodBand)
        addChild(bloodTitle)
    }

    
    
    func loadTip() {
        let tip = SKLabelNode(fontNamed: "Chalkduster")
        tip.name = NinjaGameSceneChildName.TipName.rawValue
        tip.text = "Press to prolong the stick"
        tip.position = CGPoint(x: 0, y: DefinedScreenHeight / 2 - 850)
        tip.fontColor = SKColor.lightGray
        tip.fontSize = 60
        tip.zPosition = NinjaGameSceneZposition.tipZposition.rawValue
        tip.horizontalAlignmentMode = .center
        
        addChild(tip)
    }
    
    
    //Game over && Retry && Highscore(init scale to 0)
    func loadGameOverLayer() {
        
        let node = SKNode()
        node.alpha = 0      //hide initially
        node.name = NinjaGameSceneChildName.GameOverLayerName.rawValue
        node.zPosition = NinjaGameSceneZposition.gameOverZposition.rawValue
        node.alpha = 0
        addChild(node)
        
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Game Over"
        label.fontColor = SKColor.red
        label.fontSize = 150
        label.position = CGPoint(x: 0, y: 100)
        label.horizontalAlignmentMode = .center
        node.addChild(label)
        
        let retry = SKSpriteNode(imageNamed: "button_retry_up")
        retry.name = NinjaGameSceneChildName.RetryButtonName.rawValue
        retry.position = CGPoint(x: 0, y: -200)
        node.addChild(retry)
        
        let highScore = SKLabelNode(fontNamed: "AmericanTypewriter")
        highScore.text = "Highscore!"
        highScore.fontColor = UIColor.white
        highScore.fontSize = 50
        highScore.name = NinjaGameSceneChildName.HighScoreName.rawValue
        highScore.position = CGPoint(x: 0, y: 300)
        highScore.horizontalAlignmentMode = .center
        highScore.setScale(0)
        node.addChild(highScore)
        
    }
    
    
    
    func loadStacks(_ animate: Bool, startLeftPoint: CGFloat) -> SKShapeNode {
       
        let max:Int = Int(StackMaxWidth / 10)
        let min:Int = Int(StackMinWidth / 10)
        let width:CGFloat = CGFloat(randomInRange(min...max) * 10)
        let height:CGFloat = StackHeight
        let stack = SKShapeNode(rectOf: CGSize(width: width, height: height))
        stack.fillColor = SKColor.lightGray
        stack.strokeColor = SKColor.white
        stack.zPosition = NinjaGameSceneZposition.stackZposition.rawValue
        stack.name = NinjaGameSceneChildName.StackName.rawValue
        
        if (animate) {
            stack.position = CGPoint(x: DefinedScreenWidth / 2, y: -DefinedScreenHeight / 2 + height / 2)
            
            stack.run(SKAction.moveTo(x: -DefinedScreenWidth / 2 + width / 2 + startLeftPoint, duration: 0.3), completion: {[unowned self] () -> Void in
                self.isBegin = false
                self.isEnd = false
                
                
                self.loadMonster()
                
                self.loadBird()
                
                
                
                if(self.score >= 5)
                {
                    self.loadMonster2()
                }
                
            })
            
        }
        else {
            stack.position = CGPoint(x: -DefinedScreenWidth / 2 + width / 2 + startLeftPoint, y: -DefinedScreenHeight / 2 + height / 2)
        }
      
        addChild(stack)
        
        
        let mid = SKShapeNode(rectOf: CGSize(width: 20, height: 20))
        mid.fillColor = SKColor.red
        mid.strokeColor = SKColor.red
        mid.zPosition = NinjaGameSceneZposition.stackMidZposition.rawValue
        mid.name = NinjaGameSceneChildName.StackMidName.rawValue
        mid.position = CGPoint(x: 0, y: height / 2 - 20 / 2)
        stack.addChild(mid)
        
        nextLeftStartX = width + startLeftPoint
        
        return stack
    }
    
    
    
    func loadHero() {
        let hero = SKSpriteNode(imageNamed: "rabbit1")
        hero.name = NinjaGameSceneChildName.HeroName.rawValue
        let x:CGFloat = nextLeftStartX - DefinedScreenWidth / 2 - hero.size.width / 2 - GAP.XGAP
        let y:CGFloat = StackHeight + hero.size.height / 2 - DefinedScreenHeight / 2 - GAP.YGAP
        hero.position = CGPoint(x: x, y: y)
        hero.zPosition = NinjaGameSceneZposition.heroZposition.rawValue
        hero.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: hero.size.width, height: hero.size.height))
        hero.physicsBody?.affectedByGravity = false
        hero.physicsBody?.allowsRotation = false
        
        addChild(hero)
        
        hero.physicsBody?.isDynamic = false
        
        
        hero.physicsBody?.categoryBitMask = heroCatagory
        
        hero.physicsBody?.contactTestBitMask = heroCatagory | monsterCategory
        hero.physicsBody?.collisionBitMask = heroCatagory | monsterCategory
        hero.physicsBody?.usesPreciseCollisionDetection = true


    }

    

    func loadMonster() {
        //let monster = SKSpriteNode(color: SKColor.red, size: CGSize(width:50, height:50))
        let monster = SKSpriteNode(imageNamed: "monkey1")
        monster.size.width = 90
        monster.size.height = 90
        monster.zPosition = NinjaGameSceneZposition.monsterZposition.rawValue
        monster.name = NinjaGameSceneChildName.MonsterName.rawValue
        monster.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        monster.position = CGPoint(x: ((leftStack?.position.x)! + (rightStack?.position.x)!) / 2, y: (-DefinedScreenHeight / 2) + random(0.0...300.0))
        
        addChild(monster)
        monster.run(monsterAction, withKey: NinjaGameSceneActionKey.MonsterAction.rawValue)
        
        
        monster.run(monster_moveAction, withKey: NinjaGameSceneActionKey.MonsterMoveAction.rawValue)
        
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: (monster.size.width/2-10), height: (monster.size.height/2)-10))
        
        
        
        monster.physicsBody?.isDynamic = true
        
        
        monster.physicsBody?.affectedByGravity = false
        
        monster.physicsBody?.categoryBitMask = monsterCategory
        
        
        /*monster.physicsBody?.collisionBitMask = 0
        monster.physicsBody?.affectedByGravity = false
        monster.physicsBody?.contactTestBitMask = 2
       */
        
        
        monster.physicsBody?.usesPreciseCollisionDetection = true
        
        
    }

    
    
    func loadBird() {
        let bird = SKSpriteNode(imageNamed: "bird1.png")
        bird.zPosition = NinjaGameSceneZposition.birdZposition.rawValue
        bird.anchorPoint = CGPoint(x:0.5, y:0.5)
        bird.position = CGPoint(x: (DefinedScreenWidth / 2 - 200) , y: (DefinedScreenHeight / 2) - 600)
        bird.name = NinjaGameSceneChildName.BirdName.rawValue
        
        addChild(bird)
        
        bird.run(birdAction, withKey:NinjaGameSceneActionKey.BirdAction.rawValue)
        
        bird.run(bird_moveAction,withKey:NinjaGameSceneActionKey.BirdMoveAction.rawValue)
        
        
    }
    
    
    func loadMonster2() {
        
        
        let monster = SKSpriteNode(imageNamed: "monkey1")
        monster.size.width = 120
        monster.size.height = 120
        monster.zPosition = NinjaGameSceneZposition.monsterZposition.rawValue
        monster.name = NinjaGameSceneChildName.SecondMonsterName.rawValue
        monster.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        monster.position = CGPoint(x: ((leftStack?.position.x)! + (rightStack?.position.x)!) / 2, y: (-DefinedScreenHeight / 2) + random(400.0...800.0))
        
        addChild(monster)
        monster.run(secondmonsterAction, withKey: NinjaGameSceneActionKey.SecondMonsterAction.rawValue)
        
        
        monster.run(monster_moveAction, withKey: NinjaGameSceneActionKey.MonsterMoveAction.rawValue)
        
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: (monster.size.width/2-10), height: (monster.size.height/2)-10))
        
        
        
        monster.physicsBody?.isDynamic = true
        
        
        monster.physicsBody?.affectedByGravity = false
        
        monster.physicsBody?.categoryBitMask = monsterCategory
        
        
        /*monster.physicsBody?.collisionBitMask = 0
         monster.physicsBody?.affectedByGravity = false
         monster.physicsBody?.contactTestBitMask = 2
         */
        
        
        monster.physicsBody?.usesPreciseCollisionDetection = true
        
    }
    
    
    func loadStick() -> SKSpriteNode {
        let hero = childNode(withName: NinjaGameSceneChildName.HeroName.rawValue) as! SKSpriteNode
        
        let stick = SKSpriteNode(color: SKColor.brown, size: CGSize(width: 12, height: 1))
        stick.zPosition = NinjaGameSceneZposition.stickZposition.rawValue
        stick.name = NinjaGameSceneChildName.StickName.rawValue
        stick.anchorPoint = CGPoint(x: 0.5, y: 0);
        stick.position = CGPoint(x: hero.position.x + hero.size.width / 2 + 18, y: hero.position.y - hero.size.height / 2)
        addChild(stick)
        
        return stick
    }
    

    
    func loadPerfect() {
        defer {
            let perfect = childNode(withName: NinjaGameSceneChildName.PerfectName.rawValue) as! SKLabelNode?
            let sequence = SKAction.sequence([SKAction.fadeAlpha(to: 1, duration: 0.3), SKAction.fadeAlpha(to: 0, duration: 0.3)])
            let scale = SKAction.sequence([SKAction.scale(to: 1.4, duration: 0.3), SKAction.scale(to: 1, duration: 0.3)])
            perfect!.run(SKAction.group([sequence, scale]))
        }
        
        guard let _ = childNode(withName: NinjaGameSceneChildName.PerfectName.rawValue) as! SKLabelNode? else {
            let perfect = SKLabelNode(fontNamed: "Chalkduster")
            perfect.text = "Perfect +1"
            perfect.name = NinjaGameSceneChildName.PerfectName.rawValue
            perfect.position = CGPoint(x: 0, y: -100)
            perfect.fontColor = SKColor.lightGray
            perfect.fontSize = 60
            perfect.zPosition = NinjaGameSceneZposition.perfectZposition.rawValue
            perfect.horizontalAlignmentMode = .center
            perfect.alpha = 0
            
            addChild(perfect)
            
            return
        }
        
    }
    /*
    func loadPerfect_3Points() {
        defer {
            let perfect = childNode(withName: NinjaGameSceneChildName.PerfectName.rawValue) as! SKLabelNode?
            let sequence = SKAction.sequence([SKAction.fadeAlpha(to: 1, duration: 0.3), SKAction.fadeAlpha(to: 0, duration: 0.3)])
            let scale = SKAction.sequence([SKAction.scale(to: 1.4, duration: 0.3), SKAction.scale(to: 1, duration: 0.3)])
            perfect!.run(SKAction.group([sequence, scale]))
        }
        
        guard let _ = childNode(withName: NinjaGameSceneChildName.PerfectName.rawValue) as! SKLabelNode? else {
            let perfect = SKLabelNode(fontNamed: "Arial")
            perfect.text = "Perfect +3"
            perfect.name = NinjaGameSceneChildName.PerfectName.rawValue
            perfect.position = CGPoint(x: 0, y: -100)
            perfect.fontColor = SKColor.lightGray
            perfect.fontSize = 60
            perfect.zPosition = NinjaGameSceneZposition.perfectZposition.rawValue
            perfect.horizontalAlignmentMode = .center
            perfect.alpha = 0
            
            addChild(perfect)
            
            return
        }
        
    }
 */
    

}

