//
//  ViewController.swift
//  Project22
//
//  Created by Anton Makeev on 11.04.2021.
//

import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var distanceReading: UILabel!
    @IBOutlet var uuidLabel: UILabel!
    
    
    var locationManager: CLLocationManager?
    var isAlreadyLocated = false
    let beacons = [
        CLBeaconRegion(uuid: UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!, major: 123, minor: 456, identifier: "My beacon"),
        CLBeaconRegion(uuid: UUID(uuidString: "74278BDA-B644-4520-8F0C-720EAF059935")!, major: 111, minor: 333, identifier: "Another beacon"),
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray

        
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        for beacon in beacons {
//        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
//        let beaconRegion = CLBeaconRegion(uuid: uuid, major: 123, minor: 456, identifier: "My beacon")
        locationManager?.startMonitoring(for: beacon)
        locationManager?.startRangingBeacons(satisfying: beacon.beaconIdentityConstraint)
        }
    }
    
    
    
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 1) {
            switch  distance {
            case .far:
                self.view.backgroundColor = .blue
                self.distanceReading.text = "FAR"
            case .near:
                self.view.backgroundColor = .orange
                self.distanceReading.text = "NEAR"
            case .immediate:
                self.view.backgroundColor = .red
                self.distanceReading.text = "RIGHT HERE"
            default:
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
            uuidLabel.text = beaconConstraint.uuid.uuidString
            if !isAlreadyLocated {
                isAlreadyLocated = true
                let ac = UIAlertController(title: "Beacon is located!", message: beacon.uuid.uuidString, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
        } else {
            if uuidLabel.text == beaconConstraint.uuid.uuidString {
                update(distance: .unknown)
            }
        }
    }
    
    
}

