//
//  Note.swift
//  Milestone 19-21
//
//  Created by Anton Makeev on 09.04.2021.
//

import Foundation

struct Note: Codable {
    var title: String {
        let firstReturn = body.firstIndex(of: "\n")
        if body.isEmpty {
            return "Новая заметка"
        }
        if let index = firstReturn {
            return String(body.prefix(upTo: index))
        } else {
            return body
        }
    }
    var body: String {
        didSet {
            modified = Date()
        }
    }
    var created: Date
    var modified: Date
    var uuid = UUID()
    
    init(body: String, created: Date = Date(), modified: Date = Date()) {
        self.body = body
        self.created = created
        self.modified = modified
    }
}
