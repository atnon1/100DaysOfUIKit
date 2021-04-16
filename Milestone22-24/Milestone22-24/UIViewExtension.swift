//
//  UIViewExtension.swift
//  Milestone22-24
//
//  Created by Anton Makeev on 16.04.2021.
//

import UIKit

extension UIView {
    func bounceOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            [weak self] in self?.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }
        5.times { print("Hello!") }
    }
}
