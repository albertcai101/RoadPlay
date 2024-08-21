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
    
    @Published var speed: [CLLocationSpeed] = []
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let currentSpeed = location.speed
        
        DispatchQueue.main.async {
            self.speed.append(currentSpeed)
            
            // Limit array size to 100 points
            if self.speed.count > 100 {
                self.speed.removeFirst()
            }
        }
    }
}
