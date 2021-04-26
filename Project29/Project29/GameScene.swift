//
//  GameScene.swift
//  Project29
//
//  Created by Anton Makeev on 26.04.2021.
//

import SpriteKit
import GameplayKit

enum CollisionType: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    weak var viewController: GameViewController?
    var buildings = [BuildingNode]()
    
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    var currentPlayer = 1
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        createBuildings()
        createPlayers()
        physicsWorld.contactDelegate = self
    }
    
    func createBuildings() {
        var currentX: CGFloat = -15
        while currentX < 1024 {
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            currentX += size.width + 2
            
            let building = BuildingNode(color: UIColor.red, size: size)
            building.position = CGPoint(x: currentX - building.size.width / 2, y: building.size.height / 2)
            building.setup()
            addChild(building)
            
            buildings.append(building)
        }
    }
    
    func launch(angle: Int, velocity: Int) {
        let speed = Double(velocity) / 10
        let radians = deg2rad(degrees: angle)
        
        createBananaSprite()
        
        let player: SKSpriteNode! = (currentPlayer == 1) ? player1 : player2
        let playerCoef: CGFloat = currentPlayer == 1 ? 1.0 : -1.0
        
        let lowArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
        let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player\(currentPlayer)Throw"))
        let pause = SKAction.wait(forDuration: 0.15)
        let sequence = SKAction.sequence([raiseArm, pause, lowArm])
        
        let bananaPosition = CGPoint(x: player.position.x - 30 * playerCoef, y: player.position.y + 40)
        let impulse = CGVector(dx: cos(radians) * speed * Double(playerCoef) , dy: sin(radians) * speed)
        
        banana.physicsBody?.angularVelocity = -20 * playerCoef
        banana.position = bananaPosition
        addChild(banana)
        player.run(sequence)
        banana.physicsBody?.applyImpulse(impulse)
    }
    
    func createPlayers() {
        player1 = createPlayerSprite()
        player1.name = "player1"
        let player1Building = buildings[1]
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        addChild(player1)
        
        player2 = createPlayerSprite()
        player2.name = "player2"
        let player2Building = buildings[buildings.count - 2]
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
        addChild(player2)
    }
    
    func createPlayerSprite() -> SKSpriteNode {
        let player = SKSpriteNode(imageNamed: "player")
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionType.banana.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.banana.rawValue
        player.physicsBody?.isDynamic = false
        
        return player
    }
    
    func deg2rad(degrees: Int) -> Double {
        Double(degrees) * .pi / 180
    }
    
    func createBananaSprite() {
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.usesPreciseCollisionDetection = true
        banana.physicsBody?.categoryBitMask = CollisionType.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.building.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.building.rawValue
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }
        guard firstNode.name == "banana" else { return }
        if secondNode.name == "building" {
            bananaHit(secondNode, at: contact.contactPoint)
        }
        if secondNode.name == "player1" {
            destroy(player1)
        }
        if secondNode.name == "player2" {
            destroy(player2)
        }
    }
    
    func changePlayer() {
        currentPlayer = (currentPlayer == 1) ? 2 : 1
        viewController?.activatePlayer(number: currentPlayer)
    }
    
    func bananaHit(_ building: SKNode, at contactPoint: CGPoint) {
        guard let building = building as? BuildingNode else { return }
        let buildingLoaction = convert(contactPoint, to: building)
        building.hit(at: buildingLoaction)
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = contactPoint
            addChild(explosion)
        }
        
        banana.name = ""
        banana.removeFromParent()
        banana = nil
        changePlayer()
    }
    
    func destroy(_ player: SKNode) {
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
        }
        
        player.removeFromParent()
        banana.removeFromParent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController?.currentGame = newGame
            
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer
            
            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }
        
        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
}
