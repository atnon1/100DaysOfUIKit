//
//  GameScene.swift
//  Milestone 16-18
//
//  Created by Anton Makeev on 31.03.2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var timer: Timer!
    var timeTimer: Timer!
    var heights = [CGPoint]()
    var bounds: CGRect!
    var scoreLabel: SKLabelNode!
    var timeLabel: SKLabelNode!
    
    var timeInterval = 2.0
    var targetsCreated = 0
    var initialVelocity = -200
    var timeLeft = 60.0 {
        didSet {
            timeLabel.text = "Time: \(String(format: "%.1f", timeLeft)) s."
        }
    }
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        bounds = view.bounds
        
        let back = SKSpriteNode(imageNamed: "background")
        back.scale(to: bounds.size)
        back.position = CGPoint(x: bounds.midX, y: bounds.midY)
        back.zPosition = -1
        addChild(back)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: bounds.maxX - 150, y: bounds.maxY - 50)
        addChild(scoreLabel)
        score = 0
        
        timeLabel = SKLabelNode(fontNamed: "Chalkduster")
        timeLabel.position = CGPoint(x: bounds.minX + 150, y: bounds.maxY - 50)
        addChild(timeLabel)
        timeLeft = 60

        backgroundColor = .white
        for j in 0..<3 {
            let mountainDistance = bounds.height / 7 * CGFloat(j*2 + 1)
            heights.append(CGPoint(x: (j == 1) ? -200 : bounds.width + 200, y: mountainDistance + 75))
            for i in 0..<5 {
                let mountain = SKSpriteNode(imageNamed: "mountain")
                mountain.scale(to: CGSize(width: bounds.width/3, height: bounds.height / 6))
                mountain.position = CGPoint(x: bounds.width / 4 * CGFloat(i) + 100 * CGFloat(j % 2), y: mountainDistance)
                mountain.zPosition = CGFloat(0)
                addChild(mountain)
            }
            //createTarget(at: CGPoint(x: bounds.width + 200, y: mountainDistance + 75), zPosition: 1)
        }
        createTarget()
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(createTarget), userInfo: nil, repeats: true)
        timeTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(setTimer), userInfo: nil, repeats: true)
        physicsWorld.gravity = .zero
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        for node in nodes(at: location) {
            if let name = node.name{
                if name != "hit" {
                    if name.contains("ski") {
                        score += 50
                        if name.contains("baby") {
                            score += 50
                        }
                        node.name = "hit"
                    }
                    if name.contains("snowboard") {
                        score -= 100
                        if name.contains("baby") {
                            score -= 100
                        }
                        node.name = "hit"
                    }
                    if let sprite = node as? SKSpriteNode {
                        sprite.physicsBody?.angularVelocity = 10
                        sprite.physicsBody?.velocity.dy = CGFloat([-200, 200].randomElement()!)
                    }
                }
            }
        }
    }

    @objc func createTarget() {
        targetsCreated += 1
        if targetsCreated % 10 == 0 {
            timer.invalidate()
            timeInterval -= 0.3
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createTarget), userInfo: nil, repeats: true)
        }
        let target: SKSpriteNode!
        let heightIndex = Int.random(in: 0..<3)
        let position = heights[heightIndex]
        let velocity = initialVelocity * ( heightIndex == 1 ? -1 : 1 )
        switch Int.random(in: 0..<5) {
        case 0:
            target = SKSpriteNode(imageNamed: "snowboard")
            target.name = "snowboard"
        case 1:
            target = SKSpriteNode(imageNamed: "babySki")
            target.name = "babyski"
            target.scale(to: CGSize(width: 100, height:  target.size.height / target.size.width * 100))
        case 2:
            target = SKSpriteNode(imageNamed: "babySnowboard")
            target.name = "babysnowboard"
            target.scale(to: CGSize(width: 100, height:  target.size.height / target.size.width * 100))
        default:
            target = SKSpriteNode(imageNamed: "ski")
            target.name = "ski"
        }
        if heightIndex == 1 {
            target.xScale = target.xScale * -1
        }
        target.physicsBody = SKPhysicsBody(texture: target.texture!, size: target.size)
        target.physicsBody?.velocity = CGVector(dx: velocity, dy: 0)
        target.physicsBody?.linearDamping = 0
        if target.name!.contains("baby") {
            target.physicsBody?.velocity = CGVector(dx: velocity * 2, dy: 0)
        }
        target.physicsBody?.collisionBitMask = 0
        target.position = position
        target.zPosition = 1
        addChild(target)
        
        initialVelocity += 2
    }
    
    @objc func setTimer() {
        timeLeft -= 0.1
        if String(format: "%.1f", timeLeft) == "0.0" {
            timer.invalidate()
            timeTimer.invalidate()
            
            let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            gameOverLabel.text = "Game over!"
            gameOverLabel.fontSize = 50
            gameOverLabel.position = CGPoint(x: bounds.midX, y: bounds.midY)
            gameOverLabel.zPosition = 1
            gameOverLabel.fontColor = .black
            addChild(gameOverLabel)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for child in children {
            if child.position.x < -300 || child.position.x > bounds.width + 300 {
                child.removeFromParent()
            }
        }
    }
}
