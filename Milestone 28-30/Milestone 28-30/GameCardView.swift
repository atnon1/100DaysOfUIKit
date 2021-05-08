//
//  GameCardView.swift
//  Milestone 28-30
//
//  Created by Anton Makeev on 06.05.2021.
//

import UIKit

class GameCardView: UICollectionViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var backView: UIView!
    @IBOutlet var frontView: UIView!
    
    @objc func flip() {
        let firstView: UIView
        let secondView: UIView
        if frontView.isHidden == false {
            firstView = frontView
            secondView = backView
        } else {
            firstView = backView
            secondView = frontView
        }
        
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews
        ]
        UIView.transition(with: self, duration: 1.0, options: transitionOptions, animations: {
            firstView.isHidden = true
        })
        UIView.transition(with: self, duration: 1.0, options: transitionOptions, animations: {
            secondView.isHidden = false
        })
    }
    
    func configureSides() {
        title.textColor = .black
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.gray.cgColor
        frontView.layer.borderWidth = 1
        frontView.layer.borderColor = UIColor.gray.cgColor
        backView.layer.cornerRadius = 8
        frontView.layer.cornerRadius = 8
    }
    
    
    func flipCard() {
        perform(#selector(flip))
    }
}

