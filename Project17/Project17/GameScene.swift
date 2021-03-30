//
//  GameScene.swift
//  Project17
//
//  Created by Anton Makeev on 30.03.2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var starfield: SKEmitterNode!
    var enemies = ["ball", "hammer", "tv"]
    var timer: Timer?
    var timerInterval = 1.0
    var isGameOver = false
    var enemiesEmitted = 0
    
    var scoreLabel = SKLabelNode(fontNamed: "Chalkduster") //SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    
    override func didMove(to view: SKView) {
        let bounds = view.bounds
        
        backgroundColor = .black
        starfield = SKEmitterNode(fileNamed: "starfield")
        starfield.particlePositionRange.dy = bounds.maxY
        starfield.advanceSimulationTime(10)
        starfield.zPosition = -1
        starfield.position = CGPoint(x: bounds.maxX, y: bounds.midY)
        starfield.particlePositionRange.dy = bounds.maxY
        addChild(starfield)

        player = SKSpriteNode(imageNamed: "player")
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        player.position = CGPoint(x: bounds.minX + 100, y: bounds.midY)
        addChild(player)
        
        //scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: bounds.minX + 16, y: bounds.minY + 16)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.color = .white
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        
    }
    
    @objc func createEnemy() {
        guard let enemy = enemies.randomElement() else { return }
        if (enemiesEmitted % 20 == 0) && timerInterval > 0.1 {
            timerInterval -= 0.1
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        }
        enemiesEmitted += 1
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        sprite.physicsBody?.categoryBitMask = 1
        addChild(sprite)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for child in children {
            if child.position.x < -300 {
                child.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        let transition = location - previousLocation
        var playerPosition = player.position + transition
        if playerPosition.x > 900 {
            playerPosition.x = 900
        }
        if playerPosition.x < 100 {
            playerPosition.x = 100
        }
        if playerPosition.y > 668 {
            playerPosition.y = 668
        }
        if playerPosition.y < 100 {
            playerPosition.y = 100
        }
        player.position = playerPosition
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        
        isGameOver = true
        timer?.invalidate()
        
    }
    
    
    
}
