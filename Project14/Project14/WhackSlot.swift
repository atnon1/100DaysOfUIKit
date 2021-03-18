//
//  WhackSlot.swift
//  Project14
//
//  Created by Anton Makeev on 18.03.2021.
//

import SpriteKit
import UIKit

class WhackSlot: SKNode {
    
    var isVisible = false
    var isHit = false
    var charNode: SKSpriteNode!
    
    func configute(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        charNode = SKSpriteNode(imageNamed: "penguinEvil")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        cropNode.addChild(charNode)
        
        addChild(cropNode)
        
    }
    
    func show(hideTime: Double) {
        if isVisible { return }
        charNode.xScale = 1
        charNode.yScale = 1
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.1))
        showMud()
        isVisible = true
        isHit = false
        
        if Int.random(in: 0...2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) {
            [weak self] in
            self?.hide()
        }
    }
    
    func hide() {
        if !isVisible { return }
        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.1))
        isVisible = false
        showMud()
    }
    
    func showMud() {
        let mud = SKEmitterNode(fileNamed: "MudParticles")
        mud?.position = CGPoint(x: 0, y: -5)
        if let mudNode = mud {
            addChild(mudNode)
        }
    }
    
    func hit() {
        isHit = true
        charNode.xScale = 0.85
        charNode.yScale = 0.85
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.run { [weak self] in self?.hide() }
        self.run(SKAction.sequence([delay, hide]))
    }
    
}
