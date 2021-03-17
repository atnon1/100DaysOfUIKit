//
//  Person.swift
//  Project10
//
//  Created by Anton Makeev on 09.03.2021.
//

import UIKit

class Person: NSObject {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
