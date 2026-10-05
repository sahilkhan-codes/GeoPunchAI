import CoreLocation
import FirebaseFirestore

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let manager = CLLocationManager()
    private let db = Firestore.firestore()
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var isInsideGeofence: Bool = false
    @Published var currentDistance: CLLocationDistance = 0.0
    
    // Default fallback coordinates
    private var officeLocation = CLLocation(latitude: 28.5355, longitude: 77.3910)
    private var geofenceRadius: Double = 100.0 // meters
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        fetchGeofenceSettings()
    }
    
    func fetchGeofenceSettings() {
        db.collection("settings").document("geofence").addSnapshotListener { snapshot, error in
            guard let data = snapshot?.data(), error == nil else { return }
            
            if let lat = data["latitude"] as? Double,
               let lon = data["longitude"] as? Double,
               let radius = data["radius"] as? Double {
                DispatchQueue.main.async {
                    self.officeLocation = CLLocation(latitude: lat, longitude: lon)
                    self.geofenceRadius = radius
                    self.reevaluateGeofence()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location.coordinate
        reevaluateGeofence()
    }
    
    private func reevaluateGeofence() {
        guard let userCoord = userLocation else { return }
        let userCLLocation = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
        
        // Calculate exact distance in meters
        let distance = userCLLocation.distance(from: officeLocation)
        self.currentDistance = distance
        
        // Inside condition: distance must be LESS THAN OR EQUAL TO radius
        self.isInsideGeofence = (distance <= geofenceRadius)
    }
}
