import SwiftUI
import MapKit
import FirebaseFirestore

struct AdminGeofenceSetupView: View {
    @Environment(\.dismiss) private var dismiss
    private let db = Firestore.firestore()
    
    // Form Inputs
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
                        Text("Fetching Geofence Configuration...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Form {
                        Section(header: Text("Current Device Location")) {
                            HStack {
                                Text("Latitude")
                                Spacer()
                                Text(locationManager.userLocation != nil ? String(format: "%.5f", locationManager.userLocation!.latitude) : "Locating...")
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Text("Longitude")
                                Spacer()
                                Text(locationManager.userLocation != nil ? String(format: "%.5f", locationManager.userLocation!.longitude) : "Locating...")
                                    .foregroundColor(.secondary)
                            }
                            
                            Button("Use Current Location As Target") {
                                if let loc = locationManager.userLocation {
                                    latitudeString = String(loc.latitude)
                                    longitudeString = String(loc.longitude)
                                }
                            }
                            .font(.subheadline)
                        }
                        
                        Section(header: Text("Geofence Parameters")) {
                            TextField("Target Latitude", text: $latitudeString)
                                .keyboardType(.decimalPad)
                            
                            TextField("Target Longitude", text: $longitudeString)
                                .keyboardType(.decimalPad)
                            
                            TextField("Geofence Radius (Meters)", text: $radiusString)
                                .keyboardType(.numberPad)
                        }
                        
                        Section {
                            Button(action: saveGeofenceConfig) {
                                HStack {
                                    Spacer()
                                    if isSaving {
                                        ProgressView()
                                            .padding(.trailing, 6)
                                    }
                                    Text("Save Geofence")
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                            }
                            .disabled(isSaving)
                        }
                    }
                }
            }
            .navigationTitle("Admin Geofence Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
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
            .onAppear {
                fetchExistingGeofence()
            }
        }
    }
    
    private func fetchExistingGeofence() {
        db.collection("settings").document("geofence").getDocument { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let data = snapshot?.data(), snapshot?.exists == true {
                    if let lat = data["latitude"] as? Double {
                        self.latitudeString = String(lat)
                    }
                    if let lon = data["longitude"] as? Double {
                        self.longitudeString = String(lon)
                    }
                    if let rad = data["radius"] as? Double {
                        self.radiusString = String(Int(rad))
                    }
                } else {
                    // Default values if no config exists in Firestore
                    self.latitudeString = "28.5355"
                    self.longitudeString = "77.3910"
                    self.radiusString = "100"
                }
            }
        }
    }
    
    private func saveGeofenceConfig() {
        guard let lat = Double(latitudeString),
              let lon = Double(longitudeString),
              let rad = Double(radiusString) else {
            displayAlert(title: "Invalid Input", message: "Numeric values enter karein latitude, longitude aur radius ke liye.", success: false)
            return
        }
        
        isSaving = true
        let geofenceData: [String: Any] = [
            "latitude": lat,
            "longitude": lon,
            "radius": rad,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("settings").document("geofence").setData(geofenceData, merge: true) { error in
            DispatchQueue.main.async {
                self.isSaving = false
                if let error = error {
                    self.displayAlert(title: "Save Failed", message: error.localizedDescription, success: false)
                } else {
                    LocationManager.shared.fetchGeofenceSettings()
                    self.displayAlert(title: "Success", message: "Geofence config update ho gaya hai!", success: true)
                }
            }
        }
    }
    
    private func displayAlert(title: String, message: String, success: Bool) {
        self.alertTitle = title
        self.alertMessage = message
        self.isSuccess = success
        self.showAlert = true
    }
}
