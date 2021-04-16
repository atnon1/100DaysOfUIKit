//
//  ArrayExtension.swift
//  Milestone22-24
//
//  Created by Anton Makeev on 16.04.2021.
//

import Foundation

extension Array where Element: Comparable {
    mutating func remove(item: Element) {
        if let index = self.firstIndex(of: item) {
            self.remove(at: index)
        }
    }
}
