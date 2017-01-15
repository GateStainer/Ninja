//
//  Define.swift
//  Ninja
//
//  Created by Push on 11/21/16.
//  Copyright © 2016 Apple inc. All rights reserved.
//

import Foundation
import CoreGraphics


let DefinedScreenWidth:CGFloat = 1536
let DefinedScreenHeight:CGFloat = 2048



enum NinjaGameSceneChildName : String {
    case BackgroundName = "background"
    case HeroName = "hero"
    case StickName = "stick"
    case StackName = "stack"
    case StackMidName = "stack_mid"
    case ScoreName = "score"
    case MonsterName = "monster"
    case SecondMonsterName = "second_monster"
    case TipName = "tip"
    case PerfectName = "perfect"
    case GameOverLayerName = "over"
    case RetryButtonName = "retry"
    case HighScoreName = "highscore"
    
    //new add
    case BloodName = "blood"
}


enum NinjaGameSceneZposition: CGFloat {
    case backgroundZposition = 0
    case stackZposition = 10
    case stackMidZposition = 20
    case stickZposition = 30
    case monsterZposition=35
    case scoreBackgroundZposition = 40
    case bloodZposition, heroZposition, scoreZposition, tipZposition, perfectZposition = 50
    case emitterZposition=60
    case gameOverZposition=70
}


enum NinjaGameSceneActionKey: String {
    case WalkAction = "walk"
    case MonsterAction = "monster_action"
    case SecondMonsterAction = "second_monster_action"
    case MonsterMoveAction = "monster_move_action"
    case StickGrowAudioAction = "stick_grow_audio"
    case StickGrowAction = "stick_grow"
    case HeroScaleAction = "hero_scale"
}
