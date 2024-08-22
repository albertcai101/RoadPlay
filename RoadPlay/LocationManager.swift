//
//  LocationManager.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/20/24.
//

import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    // DESIRED UNITS: MPH
    @Published var speed: [CLLocationSpeed] = []
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let currentSpeedMetersPerSecond = location.speed // This is in meters/second
        let currentSpeedMPH = currentSpeedMetersPerSecond * 2.23694
        
        DispatchQueue.main.async {
            self.speed.append(currentSpeedMPH)
            
            // Limit array size to 100 points
            if self.speed.count > 100 {
                self.speed.removeFirst()
            }
        }
    }
}
