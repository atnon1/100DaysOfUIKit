//
//  IntExtension.swift
//  Milestone22-24
//
//  Created by Anton Makeev on 16.04.2021.
//

import Foundation

extension Int {
    func times(_ block: () -> Void)  {
        if self > 0 {
            for _ in 0..<self {
                block()
            }
        }
    }
}
