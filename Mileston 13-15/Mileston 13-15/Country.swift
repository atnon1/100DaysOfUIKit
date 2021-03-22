//
//  Country.swift
//  Mileston 13-15
//
//  Created by Anton Makeev on 19.03.2021.
//

import Foundation

struct Country: Codable {
    var name: String
    var capital: String
    var capitalLatitude: Double
    var capitalLongitude: Double
    var population: Int
    var area: Int
    var flagFileName: String
}
