//
//  Define.swift
//  Ninja
//
//  Created by Push on 11/21/16.
//  Copyright © 2016 Apple inc. All rights reserved.
//



import Foundation
import CoreGraphics



//屏幕大小
let DefinedScreenWidth:CGFloat = 1536
let DefinedScreenHeight:CGFloat = 2048






//ChildNode Name
enum NinjaGameSceneChildName : String {
    case BackgroundName = "background"
    case HeroName = "hero"
    case StickName = "stick"
    case StackName = "stack"
    case StackMidName = "stack_mid"
    case ScoreName = "score"
    case MonsterName = "monster"
    case BirdName = "bird"
    case SecondMonsterName = "second_monster"
    case TipName = "tip"
    case PerfectName = "perfect"
    case GameOverLayerName = "over"
    case RetryButtonName = "retry"
    case HighScoreName = "highscore"
    
    //new add
    case BloodName = "blood"
}





//Z轴参数，用于判定显示覆盖
enum NinjaGameSceneZposition: CGFloat {
    case backgroundZposition = 0
    case stackZposition = 10
    case stackMidZposition = 20
    case stickZposition = 30
    case birdZposition = 32
    case monsterZposition=35
    case scoreBackgroundZposition = 40
    case bloodZposition, heroZposition, scoreZposition, tipZposition, perfectZposition = 50
    case emitterZposition=60
    case gameOverZposition=70
}




//动作名
enum NinjaGameSceneActionKey: String {
    case WalkAction = "walk"
    case MonsterAction = "monster_action"
    case SecondMonsterAction = "second_monster_action"
    case MonsterMoveAction = "monster_move_action"
    case BirdAction = "bird_action"
    case BirdMoveAction = "bird_move_action"
    case StickGrowAudioAction = "stick_grow_audio"
    case StickGrowAction = "stick_grow"
    case HeroScaleAction = "hero_scale"
}
