//
//  Capital.swift
//  Project16
//
//  Created by Anton Makeev on 25.03.2021.
//

import UIKit
import MapKit

class Capital: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var info: String
    var wikiDir: String?
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String, wikiDir: String? = nil) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.wikiDir = wikiDir
    }

    
    
}
