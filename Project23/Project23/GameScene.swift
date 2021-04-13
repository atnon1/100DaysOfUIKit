//
//  GameScene.swift
//  Project23
//
//  Created by Anton Makeev on 12.04.2021.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    enum ForceBomb {
        case always, never, random
    }
    
    enum SequenceType: CaseIterable {
        case one, oneNoBomb, two, twoWithOneBomb, three, four, chain, fastChain
    }
    
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var lives = 3
    var livesImages = [SKSpriteNode]()
    
    var activeSlicePoints = [CGPoint]()
    var isSwooshSoundActive = false
    var activeEnemies = [SKSpriteNode]()
    
    var bombSound: AVAudioPlayer?
    
    var sequence = [SequenceType]()
    var initialSequence: [SequenceType] = [.oneNoBomb, .one, .twoWithOneBomb, .two, .three, .four, .chain, .fastChain]
    var sequencePosition = 0
    var popupTime = 0.9
    var chainDelay = 3.0
    var nextSequenceQueued = true
    
    var isGameEnded = false
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = view.center
        background.zPosition = -1
        background.blendMode = .replace
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlices()
        
        sequence = initialSequence
        
        for _ in 0...1000 {
            if let type = SequenceType.allCases.randomElement() {
                sequence.append(type)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.tossEnemies()
        }
    }
    
    func createScore() {
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.fontSize = 48
        gameScore.horizontalAlignmentMode = .left
        score = 0
        
        addChild(gameScore)
    }
    
    func createLives() {
        for i in 0..<lives {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)
            
            livesImages.append(spriteNode)
        }
    }
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    
    func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3
        activeSliceFG.strokeColor = .white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        
        redrawActiveSlice()
        
        
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        activeSliceFG.alpha = 1
        activeSliceBG.alpha = 1
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameEnded == false else { return }
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        for case let node as SKSpriteNode in nodes(at: location) {
            
            if node.name == "enemy" || node.name == "bomb" {
                
                let emitterFileName: String
                let soundFileName: String
                let nodeToSlice: SKSpriteNode
                
                if node.name == "enemy" {
                    score += 1
                    nodeToSlice = node
                    emitterFileName = "sliceHitEnemy"
                    soundFileName = "whack.caf"
                } else {
                    guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                    nodeToSlice = bombContainer
                    emitterFileName =  "sliceHitBomb"
                    soundFileName = "explosion.caf"
                    endGame(triggeredByBomb: true)
                }
                
                if let emitter = SKEmitterNode(fileNamed: emitterFileName) {
                    emitter.position = nodeToSlice.position
                    addChild(emitter)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3 ) {
                        emitter.removeFromParent()
                    }
                }
                run(SKAction.playSoundFileNamed(soundFileName, waitForCompletion: false))
                
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let group = SKAction.group([fadeOut, scaleOut])
                let seq = SKAction.sequence([group, .removeFromParent()])
                nodeToSlice.run(seq)
            
                nodeToSlice.physicsBody?.isDynamic = false
                node.name = ""
                
                if let index = activeEnemies.firstIndex(of: nodeToSlice) {
                    activeEnemies.remove(at: index)
                }
            }
        }
    }
    
    func endGame(triggeredByBomb: Bool) {
        guard isGameEnded == false else { return }
        
        isGameEnded = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
    
        bombSound?.stop()
        bombSound = nil
        
        if triggeredByBomb {
            for image in livesImages {
                image.texture = SKTexture(imageNamed: "sliceLifeGone")
            }
        }
    }
    
    func substructLife() {
        lives -= 1
        
        run(.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        let life = livesImages[2 - lives]
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        life.setScale(1.3)
        life.run(.scale(to: 1, duration: 0.1))
        if lives == 0 {
            endGame(triggeredByBomb: false)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    func playSwooshSound() {
        isSwooshSoundActive = true
        
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        run(swooshSound) {
            [weak self] in self?.isSwooshSoundActive = false
        }
    }
    
    func redrawActiveSlice() {
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        for i in 1..<activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
    
    func createEnemy(forceBomb: ForceBomb = .random) {
        
        let enemy: SKSpriteNode
        var enemyType = Int.random(in: 0...6)
        
        if forceBomb == .always {
            enemyType = 0
        } else if forceBomb == .never{
            enemyType = 1
        }
        
        if enemyType == 0 {
            enemy = SKSpriteNode()
            enemy.name = "bombContainer"
            enemy.zPosition = 1
            
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
            
            if bombSound?.isPlaying == true {
                bombSound?.stop()
                bombSound = nil
            }
            
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSound = sound
                    sound.play()
                }
            }
        } else {
            //create enemy
            enemy = SKSpriteNode(imageNamed: "penguin")
            enemy.name = "enemy"
        }
        
        
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
        enemy.position = randomPosition
        
        let enemyAngularVelocity = Int.random(in: -3...3)
        let randomXVelocity: Int
        
        if randomPosition.x < 256 {
            randomXVelocity = Int.random(in: 8...15)
        } else if randomPosition.x < 512 {
            randomXVelocity = Int.random(in: 3...8)
        } else if randomPosition.x < 768 {
            randomXVelocity = -Int.random(in: 3...8)
        } else {
            randomXVelocity = -Int.random(in: 8...15)
        }
        let randomYVelocity = Int.random(in: 24...32)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.angularVelocity = CGFloat(enemyAngularVelocity)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !activeEnemies.isEmpty {
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
                    node.removeAllActions()
                    
                    if node.name == "enemy" {
                        substructLife()
                    }
                    node.name = ""
                    node.removeFromParent()
                    activeEnemies.remove(at: index)
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    self?.tossEnemies()
                }
            }
            nextSequenceQueued = true
        }
        
        if !activeEnemies.contains(where: {$0.name == "bombContainer"}) {
            bombSound?.stop()
            bombSound = nil
        }
    }
    
    func tossEnemies() {
        guard isGameEnded == false else { return }
        
        physicsWorld.speed *= 1.02
        chainDelay *= 0.99
        popupTime *= 0.991
        
        let sequenceType = sequence[sequencePosition]
        switch sequenceType {
        case .one:
            createEnemy()
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
        case .twoWithOneBomb:
            createEnemy(forceBomb: .always)
            createEnemy(forceBomb: .never)
        case .two:
            createEnemy()
            createEnemy()
        case .three:
            for _ in 0..<3 {
                createEnemy()
            }
        case .four:
            for _ in 0..<3 {
                createEnemy()
            }
        case .chain:
            for i in 0..<5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + chainDelay/5 * Double(i)) { [weak self] in
                    self?.createEnemy()
                }
            }
        case .fastChain:
            for i in 0..<5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + chainDelay/10 * Double(i)) { [weak self] in
                    self?.createEnemy()
                }
            }
        }
        
        sequencePosition += 1
        nextSequenceQueued = false
    }
    
}
