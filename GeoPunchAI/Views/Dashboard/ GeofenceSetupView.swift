import SwiftUI
import FirebaseFirestore

struct GeofenceSetupView: View {
    @State private var officeName: String = "Main Office"
    @State private var latitude: String = "28.5355"
    @State private var longitude: String = "77.3910"
    @State private var radiusMeters: String = "50"
    
    @State private var isSaving = false
    @State private var statusMessage = ""
    
    private var db = Firestore.firestore()
    
    var body: some View {
        Form {
            Section(header: Text("Office Location Details")) {
                TextField("Office Name", text: $officeName)
                TextField("Latitude", text: $latitude)
                    .keyboardType(.decimalPad)
                TextField("Longitude", text: $longitude)
                    .keyboardType(.decimalPad)
                TextField("Radius (in meters)", text: $radiusMeters)
                    .keyboardType(.numberPad)
            }
            
            Section {
                Button(action: saveGeofenceToFirestore) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save Geofence Settings")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .fontWeight(.bold)
                    }
                }
                .disabled(isSaving)
            }
            
            if !statusMessage.isEmpty {
                Section {
                    Text(statusMessage)
                        .foregroundColor(statusMessage.contains("Success") ? .green : .red)
                }
            }
        }
        .navigationTitle("Geofence Config")
    }
    
    private func saveGeofenceToFirestore() {
        guard let lat = Double(latitude),
              let lng = Double(longitude),
              let rad = Double(radiusMeters) else {
            statusMessage = "Please enter valid numerical values."
            return
        }
        
        isSaving = true
        
        let geofenceData: [String: Any] = [
            "name": officeName,
            "latitude": lat,
            "longitude": lng,
            "radius": rad,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("settings").document("geofence").setData(geofenceData, merge: true) { error in
            isSaving = false
            if let error = error {
                statusMessage = "Error: \(error.localizedDescription)"
            } else {
                statusMessage = "Successfully updated Geofence!"
            }
        }
    }
}
