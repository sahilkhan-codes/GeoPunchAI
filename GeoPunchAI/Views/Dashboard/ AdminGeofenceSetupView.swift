import SwiftUI
import MapKit
import FirebaseFirestore

struct AdminGeofenceSetupView: View {
    @Environment(\.dismiss) private var dismiss
    private let db = Firestore.firestore()
    
    // Form Inputs (Empty defaults - No hardcoding)
    @State private var latitudeString: String = ""
    @State private var longitudeString: String = ""
    @State private var radiusString: String = ""
    
    // Map Camera State
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    // Dynamic UI & Network States
    @State private var isLoading: Bool = true
    @State private var isSaving: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isSuccess: Bool = false
    
    @StateObject private var locationManager = LocationManager.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Fetching Geofence Configuration...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Form {
                        // MARK: - Section 1: Live Interactive Map
                        Section(header: Text("Target Office Location")) {
                            ZStack {
                                Map(position: $cameraPosition)
                                    .frame(height: 240)
                                    .cornerRadius(12)
                                
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 38))
                                    .foregroundColor(.red)
                                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                            .padding(.vertical, 4)
                            
                            Button(action: useCurrentLocationAsOffice) {
                                HStack {
                                    Image(systemName: "location.fill")
                                    Text("Set To My Current Device Location")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            }
                        }
                        
                        // MARK: - Section 2: Parameters Configuration
                        Section(header: Text("Geofence Parameters")) {
                            HStack {
                                Text("Latitude")
                                    .frame(width: 110, alignment: .leading)
                                TextField("Fetch/Enter Latitude", text: $latitudeString)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                            }
                            
                            HStack {
                                Text("Longitude")
                                    .frame(width: 110, alignment: .leading)
                                TextField("Fetch/Enter Longitude", text: $longitudeString)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                            }
                            
                            HStack {
                                Text("Radius (Meters)")
                                    .frame(width: 130, alignment: .leading)
                                TextField("e.g. 100", text: $radiusString)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        
                        // MARK: - Section 3: Production Save Action
                        Section {
                            Button(action: saveGeofenceToFirestore) {
                                HStack {
                                    Spacer()
                                    if isSaving {
                                        ProgressView()
                                            .padding(.trailing, 8)
                                    }
                                    Text(isSaving ? "Updating Database..." : "Publish Geofence Settings")
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                            }
                            .disabled(isSaving || latitudeString.isEmpty || longitudeString.isEmpty || radiusString.isEmpty)
                            .foregroundColor(isSaving ? .gray : .blue)
                        }
                    }
                }
            }
            .navigationTitle("Geofence Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear(perform: loadCurrentGeofenceSettings)
            .onMapCameraChange(frequency: .continuous) { context in
                let center = context.region.center
                latitudeString = String(format: "%.6f", center.latitude)
                longitudeString = String(format: "%.6f", center.longitude)
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK") {
                    if isSuccess {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Production Logic Handlers
    
    private func loadCurrentGeofenceSettings() {
        isLoading = true
        db.collection("settings").document("geofence").getDocument { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.triggerAlert(title: "Network Error", message: error.localizedDescription, success: false)
                    return
                }
                
                if let snapshot = snapshot, snapshot.exists, let data = snapshot.data() {
                    // Extract exact values saved by admin in Firestore
                    if let lat = data["latitude"] as? Double,
                       let lng = data["longitude"] as? Double,
                       let radius = data["radius"] as? Double {
                        
                        self.latitudeString = String(format: "%.6f", lat)
                        self.longitudeString = String(format: "%.6f", lng)
                        self.radiusString = String(format: "%.0f", radius)
                        
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        self.cameraPosition = .region(MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                        ))
                        return
                    }
                }
                
                // If configuration doesn't exist yet, fetch device current GPS position
                self.useCurrentLocationAsOffice()
            }
        }
    }
    
    private func useCurrentLocationAsOffice() {
        if let currentCoord = locationManager.userLocation {
            latitudeString = String(format: "%.6f", currentCoord.latitude)
            longitudeString = String(format: "%.6f", currentCoord.longitude)
            cameraPosition = .region(MKCoordinateRegion(
                center: currentCoord,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))
        } else {
            triggerAlert(title: "Location Unavailable", message: "Please ensure location services are enabled for this app.", success: false)
        }
    }
    
    private func saveGeofenceToFirestore() {
        guard let lat = Double(latitudeString),
              let lng = Double(longitudeString),
              let radius = Double(radiusString), radius > 0 else {
            triggerAlert(title: "Invalid Input", message: "Please provide valid numeric coordinates and a non-zero radius.", success: false)
            return
        }
        
        isSaving = true
        let geofenceData: [String: Any] = [
            "latitude": lat,
            "longitude": lng,
            "radius": radius,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("settings").document("geofence").setData(geofenceData, merge: true) { error in
            DispatchQueue.main.async {
                self.isSaving = false
                if let error = error {
                    self.triggerAlert(title: "Update Failed", message: error.localizedDescription, success: false)
                } else {
                    self.locationManager.fetchGeofenceSettingsFromFirestore()
                    self.triggerAlert(title: "Success", message: "Geofence rules updated successfully in production database.", success: true)
                }
            }
        }
    }
    
    private func triggerAlert(title: String, message: String, success: Bool) {
        self.alertTitle = title
        self.alertMessage = message
        self.isSuccess = success
        self.showAlert = true
    }
}
