//
//  GameOverScene.swift
//  SB2.16 SpriteKit CircleRun Game
//
//  Created by Артём on 4/8/21.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene{
    
    let label = SKLabelNode(text: "Game Over :(")
    var scoreLabel: SKLabelNode!
    var score = 0
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        scoreLabel = SKLabelNode(text: "Your score is \(score)")
        scoreLabel.position = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height - 60)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = .white
        
        addChild(scoreLabel)
        addChild(label)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let scene = GameScene(size: size)
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(scene, transition: reveal)
    }
    
}
