import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    @Published var userLocation: CLLocation?
    @Published var isInsideGeofence: Bool = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var geofenceStatusMessage: String = "Checking location..."
    
    var targetCoordinate: CLLocationCoordinate2D?
    var geofenceRadius: CLLocationDistance = 50.0 // Default 50 meters
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func setTargetGeofence(latitude: Double, longitude: Double, radius: Double) {
        self.targetCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.geofenceRadius = radius
        checkGeofenceStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location
            self.checkGeofenceStatus()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                self.startUpdatingLocation()
            }
        }
    }
    
    private func checkGeofenceStatus() {
        guard let userLoc = userLocation, let targetCoord = targetCoordinate else {
            DispatchQueue.main.async {
                self.geofenceStatusMessage = "Fetching office location..."
            }
            return
        }
        
        let targetLocation = CLLocation(latitude: targetCoord.latitude, longitude: targetCoord.longitude)
        let distanceInMeters = userLoc.distance(from: targetLocation)
        
        DispatchQueue.main.async {
            if distanceInMeters <= self.geofenceRadius {
                self.isInsideGeofence = true
                self.geofenceStatusMessage = "You are inside the office premises (\(Int(distanceInMeters))m away)"
            } else {
                self.isInsideGeofence = false
                self.geofenceStatusMessage = "Outside office boundary (\(Int(distanceInMeters))m away)"
            }
        }
    }
}
