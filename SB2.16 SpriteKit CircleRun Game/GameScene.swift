//
//  GameScene.swift
//  SB2.16 SpriteKit CircleRun Game
//
//  Created by Артём on 4/8/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var enemyRadius: CGFloat = 20
//    let player = SKSpriteNode(imageNamed: "player")
//    let enemy = SKSpriteNode(imageNamed: "enemy")
    let playerCategory: UInt32 = 0x1 << 1
    let enemyCategory: UInt32 = 0x1 << 0
    
    let playerCircle = SKShapeNode(circleOfRadius: 20)
    var enemyCircle = SKShapeNode()
    
    var scoreLabel: SKLabelNode!
    var score: Int = 0{
        didSet{scoreLabel.text = "Score: \(score)"}
    }
    
    var enemySizeW: CGFloat = 0
    var enemySizeH: CGFloat = 0
    
    var gameTimer: Timer!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)

        physicsWorld.contactDelegate = self
        playerCircle.position = CGPoint(x: frame.midX, y: frame.maxY)
        playerCircle.strokeColor = .black
        playerCircle.glowWidth = 1.0
        playerCircle.fillColor = .white
        playerCircle.fillTexture = SKTexture(imageNamed: "player")
        playerCircle.physicsBody = SKPhysicsBody(circleOfRadius: playerCircle.frame.size.width / 2)
        playerCircle.physicsBody?.isDynamic = false
        playerCircle.physicsBody?.categoryBitMask = playerCategory
        playerCircle.physicsBody?.contactTestBitMask = enemyCategory
        playerCircle.physicsBody?.collisionBitMask = 0
//        print(playerCircle.frame.size)
        
        enemyCircle = SKShapeNode(circleOfRadius: enemyRadius)
        enemyCircle.strokeColor = .black
        enemyCircle.glowWidth = 1.0
        enemyCircle.fillColor = .white
        enemyCircle.fillTexture = SKTexture(imageNamed: "enemy")
        enemyCircle.physicsBody = SKPhysicsBody(circleOfRadius: enemyCircle.frame.size.width / 2)
        enemyCircle.physicsBody?.isDynamic = false
        enemyCircle.physicsBody?.categoryBitMask = enemyCategory
        enemyCircle.physicsBody?.contactTestBitMask = playerCategory
        enemyCircle.physicsBody?.collisionBitMask = 0
        enemyCircle.physicsBody?.usesPreciseCollisionDetection = true
        
        
        enemySizeW = enemyCircle.frame.width
        enemySizeH = enemyCircle.frame.height
        
        addChild(playerCircle)
        addChild(enemyCircle)
        
//        player.size = CGSize(width: player.size.width/2, height: player.size.height/2)
//        player.position =  CGPoint(x: size.width/2, y: size.height/2)
//        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/4)
//        player.physicsBody?.isDynamic = false
//
//        enemy.size = CGSize(width: enemy.size.width/3, height: enemy.size.height/3)
//        enemy.physicsBody = SKPhysicsBody(circleOfRadius: (enemy.size.height/3)/2)
//        enemy.physicsBody?.isDynamic = false
////        enemy.position = CGPoint(x: size.width, y: size.height)
//
//        addChild(player)
//        addChild(enemy)
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 100, y: view.frame.size.height - 60)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = .white
        score = 0
        
        addChild(scoreLabel)
        
        move(node: enemyCircle, to: playerCircle.position, speed: 80)
        moveEnemy()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addRadius), userInfo: nil, repeats: true)
    }
    
    @objc func addRadius(){
        enemySizeW += 1
        enemySizeH += 1
        enemyRadius += 1
        print(enemyRadius)
//        enemyCircle.setScale(1.1)
        
//        let increase = SKAction.scale(to: CGSize(width: enemySizeW, height: enemySizeH), duration: 0.5)
//        let increase = SKAction.resize(toWidth: enemySizeW, height: enemySizeH, duration: 0.5)
//        enemyCircle.run(increase)
//        enemyRadius += 1
        score += 1
        print("Score is \(score)")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        move(node: playerCircle, to: (touches.first?.location(in: self))!, speed: 120)
//        moveEnemy()
        
//        let fadeOut = SKAction.fadeOut(withDuration: 1)
//        let moveUp = SKAction.move(to: CGPoint(x: size.width/2, y: size.height), duration: 1)
//        let group  = SKAction.group([fadeOut, moveUp])
//        player.run(group)
    }
    
    func moveEnemy(){
        move(node: enemyCircle, to: playerCircle.position, speed: 80, completion: moveEnemy)
    }
    
    func move(node: SKNode, to: CGPoint, speed: CGFloat, completion: (()->Void)? = nil){
        let x = node.position.x
        let y = node.position.y
        let distance =  sqrt((x - to.x) * (x - to.x) + (y - to.y) * (y - to.y))
        let duration = TimeInterval(distance / speed)
        
        let move = SKAction.move(to: to, duration: duration)
        node.run(move, completion: completion ?? { })
    }
    func gameOver(){
        
        gameTimer.invalidate()
        let scene = GameOverScene(size: size)
        scene.score = score
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        self.view?.presentScene(scene, transition: reveal)
    }
    
    override func didEvaluateActions() {
        super.didEvaluateActions()
//        if enemyCircle.frame.intersects(playerCircle.frame){
//            gameTimer.invalidate()
//            let scene = GameOverScene(size: size)
//            scene.score = score
//            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
//            view?.presentScene(scene, transition: reveal)
//        }
    }
    
    
}

extension GameScene: SKPhysicsContactDelegate{
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody =  contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody =  contact.bodyA
        }
        
        if (firstBody.categoryBitMask & enemyCategory) != 0 && (secondBody.categoryBitMask & playerCategory) != 0{
            gameOver()
        }
        
        
//        if contact.bodyA.categoryBitMask == playerCategory || contact.bodyB.categoryBitMask == playerCategory{
//            print("contact")
//            gameTimer.invalidate()
//            let scene = GameOverScene(size: size)
//            scene.score = score
//            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
//            view?.presentScene(scene, transition: reveal)
//        }
    }
    
}
