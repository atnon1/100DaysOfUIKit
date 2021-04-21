//
//  ViewController.swift
//  Project27
//
//  Created by Anton Makeev on 21.04.2021.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var currentDrawType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawRectangle()
    }

    @IBAction func redrawTapped(_ sender: UIButton) {
        currentDrawType += 1
        if currentDrawType > 8 {
            currentDrawType = 0
        }
        
        switch currentDrawType {
        case 0:
            drawRectangle()
        case 1:
            drawCircle()
        case 2:
            drawCheckerboard()
        case 3:
            drawRotatedSqueres()
        case 4:
            drawLines()
        case 5:
            drawTextAndImage()
        case 6:
            drawSmile()
        case 7:
            drawTwin()
        default:
            break
        }
    }
    
    func drawRectangle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let image = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        imageView.image = image
    }
    
    func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let image = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        imageView.image = image
    }
    
    func drawCheckerboard() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let image = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            for row in 0..<8 {
                for column in 0..<8 {
                    if (row + column).isMultiple(of: 2) {
                        ctx.cgContext.fill(CGRect(x: 64 * row, y: 64 * column, width: 64, height: 64))
                    }
                }
            }
        }
        imageView.image = image
    }
    
    func drawRotatedSqueres() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let image = renderer.image { ctx in
            
            ctx.cgContext.translateBy(x: 256, y: 256)
            let rotations = 16
            let angle = Double.pi / Double(rotations)
            for _ in 0..<rotations {
                ctx.cgContext.rotate(by: CGFloat(angle))
                ctx.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        imageView.image = image
    }
    
    func drawLines() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let image = renderer.image { ctx in
            
            ctx.cgContext.translateBy(x: 256, y: 256)
            var lenght: CGFloat = 256
            var first = true
            
            for _ in 0..<256 {
                ctx.cgContext.rotate(by: .pi/2)
                if first {
                    ctx.cgContext.move(to: CGPoint(x: lenght, y: 50))
                    first = false
                } else {
                    ctx.cgContext.addLine(to: CGPoint(x: lenght, y: 50))
                }
                lenght *= 0.99
            }
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        imageView.image = image
    }
    
    func drawTextAndImage() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let image = renderer.image { ctx in
            let paragraphStype = NSMutableParagraphStyle()
            paragraphStype.alignment = .center
            
            let attrs: [NSMutableAttributedString.Key : Any] = [
                .font : UIFont.systemFont(ofSize: 36),
                .paragraphStyle: paragraphStype
            ]
            
            let string = "Here goes the text I do\nnot understand!"
            let attributedString = NSMutableAttributedString(string: string, attributes: attrs)
            
            attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
            
            let image = UIImage(named: "mouse")
            image?.draw(at: CGPoint(x: 300, y: 150))
        }
        imageView.image = image
    }
    
    func drawSmile() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let image = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
            
            ctx.cgContext.setFillColor(UIColor.yellow.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.setLineWidth(5)
            ctx.cgContext.move(to: CGPoint(x: 512/3, y: 512/3))
            ctx.cgContext.addLine(to: CGPoint(x: 512/3-100, y: 512/3))
            ctx.cgContext.move(to: CGPoint(x: 512/3*2, y: 512/3))
            ctx.cgContext.addLine(to: CGPoint(x: 512/3*2 + 100, y: 512/3))
            ctx.cgContext.move(to: CGPoint(x: 512/3, y: 512/3 * 2))
            ctx.cgContext.addLine(to: CGPoint(x: 512/3*2, y: 512/3*2))
            
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        imageView.image = image
    }
    
    func drawTwin() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let image = renderer.image { ctx in
            
            ctx.cgContext.setFillColor(UIColor.yellow.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            
            ctx.cgContext.setLineWidth(5)
            
            let topLine: CGFloat = 512/3
            let baseLine: CGFloat = 512/3 * 2
            let xStep: CGFloat = 45
            let space: CGFloat = 10
            
            
            ctx.cgContext.move(to: CGPoint(x: xStep * 2, y: topLine))
            ctx.cgContext.addLine(to: CGPoint(x: xStep * 2 - xStep * 2, y: topLine))
            ctx.cgContext.move(to: CGPoint(x: xStep * 2 - xStep, y: topLine))
            ctx.cgContext.addLine(to: CGPoint(x: xStep * 2 - xStep , y: baseLine))
            ctx.cgContext.move(to: CGPoint(x: xStep * 2 + space, y: topLine))
            ctx.cgContext.addLine(to: CGPoint(x: xStep * 2 + space + xStep, y: baseLine))
            ctx.cgContext.addLine(to: CGPoint(x: xStep * 2 + space + xStep*2, y: topLine))
            ctx.cgContext.addLine(to: CGPoint(x: xStep * 2 + space + xStep*3, y: baseLine))
            ctx.cgContext.addLine(to: CGPoint(x: xStep * 2 + space + xStep*4, y: topLine))
            ctx.cgContext.move(to: CGPoint(x: xStep * 2 + space*2 + xStep*4, y: topLine))
            ctx.cgContext.addLine(to: CGPoint(x: xStep * 2 + space*2 + xStep*6, y: topLine))
            ctx.cgContext.move(to: CGPoint(x: xStep * 2 + space*2 + xStep*5, y: topLine))
            ctx.cgContext.addLine(to: CGPoint(x: xStep * 2 + space*2 + xStep*5, y: baseLine))
            ctx.cgContext.move(to: CGPoint(x: xStep * 2 + space*2 + xStep*4, y: baseLine))
            ctx.cgContext.addLine(to: CGPoint(x: xStep * 2 + space*2 + xStep*6, y: baseLine))
            ctx.cgContext.move(to: CGPoint(x: xStep * 2 + space*3 + xStep*6, y: baseLine))
            ctx.cgContext.addLine(to: CGPoint(x: xStep * 2 + space*3 + xStep*6, y: topLine))
            ctx.cgContext.addLine(to: CGPoint(x: xStep * 2 + space*3 + xStep*8, y: baseLine))
            ctx.cgContext.addLine(to: CGPoint(x: xStep * 2 + space*3 + xStep*8, y: topLine))
            
            ctx.cgContext.drawPath(using: .stroke)
        }
        imageView.image = image
    }
}

