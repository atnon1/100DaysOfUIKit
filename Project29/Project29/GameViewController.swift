//
//  GameViewController.swift
//  Project29
//
//  Created by Anton Makeev on 26.04.2021.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    
    var currentGame: GameScene?
    @IBOutlet var angleSlider: UISlider!
    @IBOutlet var angleLabel: UILabel!
    @IBOutlet var velocitySlider: UISlider!
    @IBOutlet var velocityLabel: UILabel!
    @IBOutlet var lauchButton: UIButton!
    @IBOutlet var playerLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
                currentGame = scene as? GameScene
                currentGame?.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        setSlidersDefault()
        angleDidChange(self)
        velocityDidChange(self)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @IBAction func angleDidChange(_ sender: Any) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
    }
    
    @IBAction func velocityDidChange(_ sender: Any) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
    }
    
    @IBAction func launch(_ sender: Any) {
        
        angleSlider.isHidden = true
        angleLabel.isHidden = true
        velocitySlider.isHidden = true
        velocityLabel.isHidden = true
        playerLabel.isHidden = true
        lauchButton.isHidden = true
        
        currentGame?.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value) )
        setSlidersDefault()
    }
    
    func activatePlayer(number: Int) {
        if number == 1 {
            playerLabel.text = "<<< PLAYER ONE"
            currentGame?.currentPlayer = 1
        } else {
            playerLabel.text = "PLAYER TWO >>>"
            currentGame?.currentPlayer = 2
        }
        
        angleSlider.isHidden = false
        angleLabel.isHidden = false
        velocitySlider.isHidden = false
        velocityLabel.isHidden = false
        playerLabel.isHidden = false
        lauchButton.isHidden = false
    }
    
    func setSlidersDefault() {
        angleSlider.setValue(45, animated: true)
        velocitySlider.setValue(125, animated: true)
        angleDidChange(self)
        velocityDidChange(self)
    }
    
    
    
}
