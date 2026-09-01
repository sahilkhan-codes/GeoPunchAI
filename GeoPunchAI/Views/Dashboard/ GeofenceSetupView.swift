import SwiftUI
import MapKit
import FirebaseFirestore

struct GeofenceSetupView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Map Position & State Variables
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 28.5355, longitude: 77.3910),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    
    @State private var centerCoordinate = CLLocationCoordinate2D(latitude: 28.5355, longitude: 77.3910)
    @State private var officeName: String = "Main Office"
    @State private var radiusMeters: Double = 50.0
    
    @State private var isSaving = false
    @State private var statusMessage = ""
    
    private var db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Interactive Map View
                ZStack {
                    Map(position: $position) {
                        Annotation(officeName.isEmpty ? "Office" : officeName, coordinate: centerCoordinate) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.25))
                                    .frame(width: CGFloat(radiusMeters), height: CGFloat(radiusMeters))
                                
                                Image(systemName: "building.2.crop.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                    .background(Circle().fill(.white))
                            }
                        }
                    }
                    .onMapCameraChange(frequency: .continuous) { context in
                        self.centerCoordinate = context.region.center
                    }
                    
                    // Fixed Pin Indicator
                    Image(systemName: "mappin")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                        .offset(y: -16)
                }
                .frame(maxHeight: .infinity)
                
                // Details Input Card
                VStack(spacing: 14) {
                    TextField("Office Name", text: $officeName)
                        .textFieldStyle(.roundedBorder)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Radius:")
                                .font(.subheadline)
                            Spacer()
                            Text("\(Int(radiusMeters)) meters")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        Slider(value: $radiusMeters, in: 10...500, step: 5)
                    }
                    
                    Text(String(format: "Lat: %.5f | Lon: %.5f", centerCoordinate.latitude, centerCoordinate.longitude))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: saveGeofenceToFirestore) {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Save Geofence Settings")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(officeName.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(isSaving || officeName.isEmpty)
                    
                    if !statusMessage.isEmpty {
                        Text(statusMessage)
                            .font(.caption)
                            .foregroundColor(statusMessage.contains("Success") ? .green : .red)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Geofence Config")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func saveGeofenceToFirestore() {
        isSaving = true
        
        let geofenceData: [String: Any] = [
            "name": officeName,
            "latitude": centerCoordinate.latitude,
            "longitude": centerCoordinate.longitude,
            "radius": radiusMeters,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        // Exact original Firestore collection & document path
        db.collection("settings").document("geofence").setData(geofenceData, merge: true) { error in
            DispatchQueue.main.async {
                self.isSaving = false
                if let error = error {
                    self.statusMessage = "Error: \(error.localizedDescription)"
                } else {
                    self.statusMessage = "Successfully updated Geofence!"
                }
            }
        }
    }
}
