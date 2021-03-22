//
//  DetailViewController.swift
//  Mileston 13-15
//
//  Created by Anton Makeev on 22.03.2021.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {

    @IBOutlet var flagImageView: UIImageView!
    
    var country: Country!
    
    @IBOutlet var capitalLabel: UILabel!
    @IBOutlet var areaLabel: UILabel!
    @IBOutlet var populationLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = country.name
        navigationItem.largeTitleDisplayMode = .never
        flagImageView.image = UIImage(named: country.flagFileName)
        capitalLabel.text = "Capital: \(country.capital)"
        populationLabel.text = "Population: \(country.population)"
        areaLabel.text = "Area: \(country.population) km²"
        let location = CLLocationCoordinate2D(latitude: country.capitalLatitude, longitude: country.capitalLongitude)
        let coordinateRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        mapView.setRegion(coordinateRegion, animated: true)
        flagImageView.frame.size = flagImageView.image!.size
        flagImageView.layer.borderWidth = 0.5
        flagImageView.layer.borderColor = UIColor.lightGray.cgColor
    }

}
