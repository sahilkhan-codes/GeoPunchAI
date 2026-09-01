import Foundation
import CoreLocation
import FirebaseFirestore
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let manager = CLLocationManager()
    private let db = Firestore.firestore()
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var isInsideGeofence: Bool = false
    @Published var currentDistance: Double = 0.0
    @Published var isLoadingGeofence: Bool = true
    @Published var locationError: String?
    
    // Dynamic Production Office Boundaries (Fetched from Firestore)
    private var officeLocation: CLLocation?
    private var allowedRadius: CLLocationDistance?
    
    override private init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5 // Update every 5 meters movement
        
        fetchGeofenceSettingsFromFirestore()
        requestLocationPermission()
    }
    
    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    // MARK: - Firestore Dynamic Sync (Zero-Hardcoding)
    
    func fetchGeofenceSettingsFromFirestore() {
        isLoadingGeofence = true
        db.collection("settings").document("geofence").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoadingGeofence = false
                
                if let error = error {
                    self.locationError = "Geofence sync failed: \(error.localizedDescription)"
                    self.isInsideGeofence = false
                    return
                }
                
                if let data = snapshot?.data(), snapshot?.exists == true {
                    guard let lat = data["latitude"] as? Double,
                          let lng = data["longitude"] as? Double,
                          let radius = data["radius"] as? Double else {
                        self.locationError = "Invalid geofence schema in Firestore."
                        self.isInsideGeofence = false
                        return
                    }
                    
                    self.officeLocation = CLLocation(latitude: lat, longitude: lng)
                    self.allowedRadius = radius
                    self.locationError = nil
                    self.reevaluateGeofence()
                } else {
                    self.locationError = "No office geofence configured by Admin."
                    self.isInsideGeofence = false
                }
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        
        DispatchQueue.main.async {
            self.userLocation = latestLocation.coordinate
            self.calculateDistanceAndGeofence(userLoc: latestLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = "GPS Error: \(error.localizedDescription)"
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.locationError = "Location permission denied. Enable access in Settings."
                self.isInsideGeofence = false
            }
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    // MARK: - Geofence Calculation Logic
    
    private func calculateDistanceAndGeofence(userLoc: CLLocation) {
        guard let officeLoc = officeLocation, let radius = allowedRadius else {
            self.isInsideGeofence = false
            return
        }
        
        let distance = userLoc.distance(from: officeLoc)
        self.currentDistance = distance
        self.isInsideGeofence = distance <= radius
    }
    
    private func reevaluateGeofence() {
        guard let userCoord = userLocation else { return }
        let userLoc = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
        calculateDistanceAndGeofence(userLoc: userLoc)
    }
}
