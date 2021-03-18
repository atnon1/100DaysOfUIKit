//
//  GameScene.swift
//  Project14
//
//  Created by Anton Makeev on 17.03.2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var roundsNumber = 30
    var popupTime = 0.85
    var slots = [WhackSlot]()
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            [weak self] in
            self?.createEnemy()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let smoke = SKEmitterNode(fileNamed: "Smoke")
        for node in nodes(at: location) {
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
            if !whackSlot.isVisible { return }
            if whackSlot.isHit { return }
            whackSlot.hit()
            smoke?.position = CGPoint(x: whackSlot.position.x, y: whackSlot.position.y + 10)
            
            if let smokeNode = smoke {
                addChild(smokeNode)
            }
            if node.name == "charFriend" {
                score -= 5
                run(SKAction.playSoundFileNamed("whackBad", waitForCompletion: false))
            } else if node.name == "charEnemy"  {
                score += 1
                run(SKAction.playSoundFileNamed("whack", waitForCompletion: false))
            }
            
        }
        
        
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configute(at: position)
        addChild(slot)
        slots.append(slot)
    }
 
    func createEnemy() {
        roundsNumber -= 1
        if roundsNumber == 0 {
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: view!.bounds.midX, y: view!.bounds.midY)
            gameOver.zPosition = 1
            addChild(gameOver)
            
            let finalScore = SKLabelNode(fontNamed: "Chalkduster")
            finalScore.text = "Your score is \(score)!"
            finalScore.zPosition = 1
            finalScore.fontSize = 48
            finalScore.position = CGPoint( x: gameOver.position.x, y: gameOver.position.y - 100 )
            addChild(finalScore)
            
            run(SKAction.playSoundFileNamed("GameOver.m4a", waitForCompletion: false))
            return
        }
        
        if popupTime > 0.05 {
            popupTime *= 0.97
        }
        slots.shuffle()
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 8 { slots[2].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime) }
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2.0
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            [weak self] in
            self?.createEnemy()
        }
    }
}
