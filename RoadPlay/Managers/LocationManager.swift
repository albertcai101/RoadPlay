//
//  LocationManager.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/20/24.
//

import CoreLocation
import Combine

protocol LocationManagerProtocol: AnyObject {
    var speed: [Double] { get }
    func startUpdates()
    func stopUpdates()
}

class LocationManager: NSObject, ObservableObject, LocationManagerProtocol, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    // DESIRED UNITS: MPH
    @Published var speed: [CLLocationSpeed] = []
    
    override init() {
        super.init()
        configureLocationManager()
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func startUpdates() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdates() {
        locationManager.stopUpdatingLocation()
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}
