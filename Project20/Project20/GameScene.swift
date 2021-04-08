//
//  GameScene.swift
//  Project20
//
//  Created by Anton Makeev on 06.04.2021.
//

import SpriteKit

class GameScene: SKScene {
    
    var gameTimer: Timer!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var launchNumber = 0
    var scoreLabel: SKLabelNode!
    var fireworks = [SKNode]()
    var leftEdge = -22
    var bottomEdge = -22
    var rightEdge = 1024 + 22
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = view.center
        background.zPosition = -1
        background.blendMode = .replace
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        switch Int.random(in: 0..<3) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        case 2:
            firework.color = .red
        default:
            break
        }
        
        let emitter = SKEmitterNode(fileNamed: "fuse")!
        emitter.position = CGPoint(x: 0, y: -22)
        node.addChild(emitter)
        addChild(node)
        fireworks.append(node)
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
    }
    
    @objc func launchFireworks() {
        launchNumber += 1
        if launchNumber == 10 {
            gameTimer.invalidate()
        }
        
        let xMovement: CGFloat = 1800
        
        var direction: CGFloat = 0
        var angleDiff: CGFloat = 0
        var xDistance = 0
        var yDistance = 0
        var xCenter = 0
        var yCenter = 0
        
        switch Int.random(in: 0...3) {
        case 0:
            // straight
            xCenter = 512
            yCenter = bottomEdge
            xDistance = 100
        case 1:
            // fan
            xCenter = 512
            yCenter = bottomEdge
            xDistance = 100
            angleDiff = 100
        case 2:
            // left to right
            xCenter = rightEdge
            yCenter = 334
            yDistance = 100
            direction = -xMovement
        case 3:
            // right to left
            xCenter = leftEdge
            yCenter = 334
            yDistance = 100
            direction = xMovement
        default:
            break
        }
        
        for i in 0..<5 {
            createFirework(xMovement: direction + angleDiff * (CGFloat(i)-2), x: xCenter + xDistance * (i-2), y: yCenter + yDistance * (i-2))
        }
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        for case let node as SKSpriteNode in nodes(at: location) {
            guard node.name == "firework" else { continue }
            
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            node.colorBlendFactor = 0
            node.name = "selected"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    func explode(_ firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
            let actions = SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.removeFromParent()])
            emitter.run(actions)
        }
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var explodesNumber = 0
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first else { continue }
            if firework.name == "selected" {
                explode(fireworkContainer)
                fireworks.remove(at: index)
                explodesNumber += 1
            }
        }
        
        switch  explodesNumber {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
}
