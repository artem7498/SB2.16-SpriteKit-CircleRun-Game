//
//  GameScene.swift
//  SB2.16 SpriteKit CircleRun Game
//
//  Created by Артём on 4/8/21.
//

//struct PhysicsCategory {
//  static let none      : UInt32 = 0
//  static let all       : UInt32 = UInt32.max
//  static let monster   : UInt32 = 0b1       // 1
//  static let projectile: UInt32 = 0b10      // 2
//}

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var enemyRadius: CGFloat = 20
    
    let none: UInt32 = 0
    let playerCategory: UInt32 = 0b1 // 1
    let enemyCategory: UInt32 = 0b10 // 2
    
    let playerCircle = SKShapeNode(circleOfRadius: 20)
    var enemyCircle = SKShapeNode()
    var enemyPosition = CGPoint(x: 0, y: 0)
    
    var scoreLabel: SKLabelNode!
    var score: Int = 0{
        didSet{scoreLabel.text = "Score: \(score)"}
    }
    
    var radiusUpdateTimer: Timer!
    var scoreTimer: Timer!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)

        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
                
        addPlayer()
        addEnemy(position: enemyPosition)
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 100, y: view.frame.size.height - 60)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = .white
        score = 0
        
        addChild(scoreLabel)
        
//        move(node: enemyCircle, to: playerCircle.position, speed: 80)
        moveEnemy()
        
        scoreTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addScore), userInfo: nil, repeats: true)
        radiusUpdateTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(addRadius), userInfo: nil, repeats: true)
    }
    
    func addPlayer(){
        playerCircle.position = CGPoint(x: frame.midX, y: frame.maxY)
        playerCircle.strokeColor = .black
        playerCircle.glowWidth = 1.0
        playerCircle.fillColor = .white
        playerCircle.fillTexture = SKTexture(imageNamed: "player")
        playerCircle.physicsBody = SKPhysicsBody(circleOfRadius: 20, center: CGPoint(x: 0.5, y: 0.5))
        playerCircle.physicsBody?.isDynamic = true
//        playerCircle.physicsBody?.affectedByGravity = false
        playerCircle.physicsBody?.categoryBitMask = playerCategory
        playerCircle.physicsBody?.contactTestBitMask = enemyCategory
        playerCircle.physicsBody?.collisionBitMask = 0
//        print(playerCircle.frame.size)
        addChild(playerCircle)
    }
    
    func addEnemy(position: CGPoint){
        enemyCircle = SKShapeNode(circleOfRadius: enemyRadius)
        enemyCircle.position = position
        enemyCircle.strokeColor = .black
        enemyCircle.glowWidth = 1.0
        enemyCircle.fillColor = .white
        enemyCircle.fillTexture = SKTexture(imageNamed: "enemy")
        enemyCircle.physicsBody = SKPhysicsBody(circleOfRadius: enemyRadius, center: CGPoint(x: 0.5, y: 0.5))
        enemyCircle.physicsBody?.isDynamic = true
        enemyCircle.physicsBody?.categoryBitMask = enemyCategory
        enemyCircle.physicsBody?.contactTestBitMask = playerCategory
        enemyCircle.physicsBody?.collisionBitMask = 0
        enemyCircle.physicsBody?.usesPreciseCollisionDetection = false
        addChild(enemyCircle)
    }
    
    @objc func addScore(){
        score += 1
    }
    
    @objc func addRadius(){
//        попробовать заменять нод на новый с увеличенным радиусом, удаляя предыдущий
        enemyRadius += 1
        print(enemyRadius)
        enemyPosition = enemyCircle.position
        enemyCircle.removeFromParent()
        addEnemy(position: enemyPosition)
        moveEnemy()
        
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
        
        radiusUpdateTimer.invalidate()
        let scene = GameOverScene(size: size)
        scene.score = score
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        self.view?.presentScene(scene, transition: reveal)
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
        
        if ((firstBody.categoryBitMask & playerCategory != 0) &&
          (secondBody.categoryBitMask & enemyCategory != 0)) {
//          if let playerCircle = firstBody.node as? SKShapeNode,
//            let enemyCircle = secondBody.node as? SKShapeNode {
            print("contact")
            gameOver()
//          }
        }
        
    }
    
}
