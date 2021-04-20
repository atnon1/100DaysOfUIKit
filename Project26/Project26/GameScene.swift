//
//  GameScene.swift
//  Project26
//
//  Created by Anton Makeev on 19.04.2021.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    enum ColisionType: UInt32 {
        case player = 1
        case wall = 2
        case star = 4
        case vortex = 8
        case finish = 16
        case portal = 32
    }
    
    var isGameOver = false
    var currentLevel = 1
    let lastLevel = 3
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var scoreLabel: SKLabelNode!
    
    var lastTouchPosition: CGPoint?
    var player: SKSpriteNode!
    var portals = [SKSpriteNode]()
    var lastPortalContact: Date?
    
    var cmMotionManager: CMMotionManager?
    var bounds: CGRect?
    
    override func didMove(to view: SKView) {
        bounds = view.bounds
        
        let reloadButton = SKSpriteNode(imageNamed: "reload")
        reloadButton.name = "reloadButton"
        reloadButton.position = CGPoint(x: 32, y: 735)
        reloadButton.color = .white
        reloadButton.zPosition = 2
        addChild(reloadButton)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -1
        background.blendMode = .replace
        background.position = CGPoint(x: 512, y: 334)
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        loadLevel()
        
        view.scene?.scaleMode = .aspectFit
        cmMotionManager = CMMotionManager()
        cmMotionManager?.startAccelerometerUpdates()
    }
    
    func nodePositionFor(column: Int, row: Int) -> CGPoint {
        CGPoint(x: (column * 64) + 32, y: (row * 64) + 32)
    }
    
    fileprivate func createWallAt(column: Int, row: Int) {
        let node = SKSpriteNode(imageNamed: "block")
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = ColisionType.wall.rawValue
        node.position = nodePositionFor(column: column, row: row)
        node.physicsBody?.isDynamic = false
        addChild(node)
    }
    
    fileprivate func createVortexAt(column: Int, row: Int) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "vortex"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2 * 0.9)
        node.physicsBody?.categoryBitMask = ColisionType.vortex.rawValue
        node.physicsBody?.contactTestBitMask = ColisionType.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        node.position = nodePositionFor(column: column, row: row)
        node.physicsBody?.isDynamic = false
        addChild(node)
    }
    
    fileprivate func createStarAt(column: Int, row: Int) {
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.categoryBitMask = ColisionType.star.rawValue
        node.physicsBody?.contactTestBitMask = ColisionType.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = nodePositionFor(column: column, row: row)
        node.physicsBody?.isDynamic = false
        addChild(node)
    }
    
    fileprivate func createPortalAt(column: Int, row: Int) {
        let node = SKSpriteNode(imageNamed: "portal")
        node.name = "portal"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.categoryBitMask = ColisionType.portal.rawValue
        node.physicsBody?.contactTestBitMask = ColisionType.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 4)))
        node.position = nodePositionFor(column: column, row: row)
        node.physicsBody?.isDynamic = false
        addChild(node)
        portals.append(node)
    }
    
    fileprivate func createFinishAt(column: Int, row: Int) {
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.categoryBitMask = ColisionType.finish.rawValue
        node.physicsBody?.contactTestBitMask = ColisionType.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = nodePositionFor(column: column, row: row)
        node.physicsBody?.isDynamic = false
        addChild(node)
    }
    
    func loadLevel() {
        guard let url = Bundle.main.url(forResource: "level\(currentLevel)", withExtension: "txt") else {
            fatalError("Could not find file level1.txt in the app bundle.")
        }
        guard let levelString = try? String(contentsOf: url) else {
            fatalError("Could not load file level1.txt from the app bundle.")
        }
        clearField()
        let lines = levelString.split(separator: "\n")
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                switch letter {
                case "x":
                    createWallAt(column: column, row: row)
                case "v":
                    createVortexAt(column: column, row: row)
                case "s":
                    createStarAt(column: column, row: row)
                case "f":
                    createFinishAt(column: column, row: row)
                case "p":
                    createPortalAt(column: column, row: row)
                case " ":
                    break
                default:
                    fatalError("Unknown letter: \(letter).")
                }
                
            }
        }
        createPlayer()
    }
    
    func clearField() {
        for child in self.children where child.physicsBody != nil || child.name == "gameOverLabel" {
            child.removeFromParent()
        }
        portals = []
        score = 0
        physicsWorld.gravity = .zero
        isGameOver = false
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        player.position = CGPoint(x: 96, y: 768 - 96)
        player.zPosition = 1
        
        player.physicsBody?.categoryBitMask = ColisionType.player.rawValue
        player.physicsBody?.collisionBitMask = ColisionType.wall.rawValue
        player.physicsBody?.contactTestBitMask = ColisionType.star.rawValue | ColisionType.vortex.rawValue | ColisionType.finish.rawValue | ColisionType.portal.rawValue
        
        
        addChild(player)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchPosition = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchPosition = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let nodesAtLocation = nodes(at: location)
            if nodesAtLocation.contains(where: { $0.name == "reloadButton"}) {
                loadLevel()
            }
        }
        lastTouchPosition = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
        #if targetEnvironment(simulator)
            if let currentTouch = lastTouchPosition {
                let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
                physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
            }
        #else
            if let accelerometerData = cmMotionManager?.accelerometerData {
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -30, dy: accelerometerData.acceleration.x * 30)
            }
        #endif
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        if nodeA == player {
            playerColided(with: nodeB)
        } else if nodeB == player {
            playerColided(with: nodeA)
        }
    }
 
    func playerColided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.5)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            player.run(sequence) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "portal" {
            guard let exitPortal = portals.first(where: { $0 != node }) else { return }
            if (lastPortalContact?.distance(to: Date()) ?? 2) >= 2 {
                portalPlayer(from: node, to: exitPortal)
            }
        } else if node.name == "finish" {
            if currentLevel != lastLevel {
                currentLevel += 1
                loadLevel()
            } else {
                player.physicsBody?.isDynamic = false
                isGameOver = true
                showFinalLabel()
            }
        }
    }
    
    func portalPlayer(from entry: SKNode, to exit: SKNode) {
        player.physicsBody?.isDynamic = false
        lastPortalContact = Date()
        let moveToEntry = SKAction.move(to: entry.position, duration: 0.25)
        let scaleIn = SKAction.scale(to: 0.0001, duration: 0.5)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.001)
        let moveToExit = SKAction.move(to: exit.position, duration: 0.001)
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.001)
        let scaleOut = SKAction.scale(to: 1, duration: 0.5)
        let sequence = SKAction.sequence([moveToEntry, scaleIn, fadeOut, moveToExit, fadeIn, scaleOut])
        player.run(sequence) { [weak self] in
            self?.player.physicsBody?.isDynamic = true
        }
    }
    
    func showFinalLabel() {
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.name = "gameOverLabel"
        label.text = """
            Game over!
            Your score is \(score)
            """
        label.numberOfLines = 0
        label.position = CGPoint(x: 512, y: 334)
        label.fontSize = 64
        label.zPosition = 2
        addChild(label)
    }
}
