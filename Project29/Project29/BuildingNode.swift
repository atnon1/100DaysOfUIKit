//
//  BuildingNode.swift
//  Project29
//
//  Created by Anton Makeev on 26.04.2021.
//

import UIKit
import SpriteKit

class BuildingNode: SKSpriteNode {

    var currentImage: UIImage!
    
    func setup() {
        name = "building"
        
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
        configurePhysics()
    }
    
    
    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = CollisionType.building.rawValue
        physicsBody?.contactTestBitMask = CollisionType.banana.rawValue
    }
    
    func drawBuilding(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            let color: UIColor
            switch Int.random(in: 0...2) {
            case 0:
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 1:
                color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }
            color.setFill()
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)
            
            let lightOnColor = UIColor(hue: 0.190, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
            
            for row in stride(from: 10, through: Int(size.height - 10), by: 40) {
                for column in stride(from: 10, through: Int(size.width - 10), by: 40) {
                    if Bool.random() {
                        lightOnColor.setFill()
                    } else {
                        lightOffColor.setFill()
                    }
                    
                    ctx.cgContext.fill(CGRect(x: column, y: row, width: 15, height: 20))
                }
            }
        }
        return img
    }
    
    func hit(at location: CGPoint) {
        let renderer = UIGraphicsImageRenderer(size: size)
        let convertedPoint = CGPoint(x: location.x + self.size.width / 2, y: abs(location.y - self.size.height / 2))
        let img = renderer.image { ctx in
            currentImage.draw(at: .zero)
            
            let elipseRect = CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64)
            ctx.cgContext.addEllipse(in: elipseRect)
            ctx.cgContext.setBlendMode(.clear)
            ctx.cgContext.drawPath(using: .fill)
            
        }
        
        currentImage = img
        texture = SKTexture(image: img)
        configurePhysics()
    }
    
}
