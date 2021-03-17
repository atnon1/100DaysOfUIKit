//
//  GameScene.swift
//  Project11
//
//  Created by Anton Makeev on 10.03.2021.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    var ballImageNames = ["ballBlue","ballCyan","ballGreen","ballGrey","ballPurple", "ballRed", "ballYellow"]
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    var ballsLeft = 5 {
        didSet {
            self.removeChildren(in: ballsLeftNodes)
            
            for i in 0..<ballsLeft {
                let ballLife = SKSpriteNode(imageNamed: "ballRed")
                ballLife.scale(to: CGSize(width: 16, height: 16))
                ballLife.position = CGPoint(x: self.frame.midX - (ballLife.size.width * CGFloat(ballsLeft) / 2) + ballLife.size.width * CGFloat(i) , y: self.frame.maxY - ballLife.size.height)
                addChild(ballLife)
                ballsLeftNodes.append(ballLife)
            }
        }
    }

    var ballsLeftNodes = [SKNode]()

    var editLabel: SKLabelNode!
    
    var editingMode = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    

    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y:384)
        background.blendMode = .replace
        background.zPosition = -2
        addChild(background)
        
        for i in 0..<ballsLeft {
            let ballLife = SKSpriteNode(imageNamed: "ballRed")
            ballLife.scale(to: CGSize(width: 16, height: 16))
            ballLife.position = CGPoint(x: self.frame.midX - (ballLife.size.width * CGFloat(ballsLeft) / 2) + ballLife.size.width * CGFloat(i) , y: self.frame.maxY - ballLife.size.height)
            addChild(ballLife)
            ballsLeftNodes.append(ballLife)
        }
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: self.frame.maxX - 50, y: self.frame.maxY - scoreLabel.frame.height - 50)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.horizontalAlignmentMode = .left
        editLabel.position = CGPoint(x: self.frame.minX + 50, y: self.frame.maxY - scoreLabel.frame.height - 50)
        addChild(editLabel)
        
        
        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        let bouncersNumber = 5
        
        for i in 0..<bouncersNumber {
            let x = Int(self.size.width) / (bouncersNumber-1) * i
            makeBouncer(at: CGPoint(x: x, y: 0))
            makeSlot(at: CGPoint(x: x + 128 ,y: 0), isGood: i % 2 == 0)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let color = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
                let box = SKSpriteNode(color: color, size: size)
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.name = "obstacle"
                box.position = location
                box.zRotation = CGFloat.random(in: 0...3)
                box.physicsBody?.isDynamic = false
                addChild(box)
            } else {
                if ballsLeft > 0 {
                    let ball = SKSpriteNode(imageNamed: ballImageNames.randomElement() ?? "ballRed")
                    ball.name = "ball"
                    
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                    ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                    ball.physicsBody?.restitution = 0.4
                    ball.position = CGPoint(x: location.x, y: self.frame.maxY)
                    addChild(ball)
                    ballsLeft -= 1
                }
            }
        }
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        slotBase.position = position
        slotGlow.position = position
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        slotGlow.zPosition = -1
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            ballsLeft += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        } else if object.name == "obstacle" {
            object.removeFromParent()
        }
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
    
    
}
