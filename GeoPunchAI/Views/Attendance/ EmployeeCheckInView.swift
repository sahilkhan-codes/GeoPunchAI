import SwiftUI
import AVFoundation
import FirebaseFirestore

struct EmployeeCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var authManager = AuthManager.shared
    
    @State private var isProcessingPunch = false
    @State private var faceDetected = false
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var isSuccess = false
    
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // MARK: - Geofence Status Header
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: locationManager.isInsideGeofence ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                            .font(.title)
                            .foregroundColor(locationManager.isInsideGeofence ? .green : .red)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(locationManager.isInsideGeofence ? "Inside Office Geofence" : "Outside Office Boundary")
                                .font(.headline)
                            
                            Text("Distance to office: \(Int(locationManager.currentDistance)) meters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(locationManager.isInsideGeofence ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // MARK: - Face Detection Camera Viewport
                ZStack {
                    if locationManager.isInsideGeofence {
                        CameraPreviewHolder(faceDetected: $faceDetected)
                            .frame(height: 360)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(faceDetected ? Color.green : Color.gray.opacity(0.5), lineWidth: 3)
                            )
                        
                        Ellipse()
                            .stroke(faceDetected ? Color.green : Color.white.opacity(0.8), style: StrokeStyle(lineWidth: 3, dash: [8]))
                            .frame(width: 200, height: 260)
                        
                        VStack {
                            Spacer()
                            Text(faceDetected ? "Face Aligned — Ready to Punch" : "Position face inside frame")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(20)
                                .padding(.bottom, 12)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "location.slash.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.secondary)
                            Text("Check-in Locked")
                                .font(.headline)
                            Text("You must enter the office geofence boundary to activate biometric check-in.")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 32)
                        }
                        .frame(height: 360)
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // MARK: - Action Punch Button
                Button(action: recordAttendancePunch) {
                    HStack {
                        Spacer()
                        if isProcessingPunch {
                            ProgressView()
                                .padding(.trailing, 8)
                        }
                        Text(isProcessingPunch ? "Recording Punch..." : "Punch In / Check In")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding()
                    .background((locationManager.isInsideGeofence && faceDetected && !isProcessingPunch) ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!locationManager.isInsideGeofence || !faceDetected || isProcessingPunch)
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .navigationTitle("Face Attendance")
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
        }
    }
    
    private func recordAttendancePunch() {
        guard let user = authManager.currentUserData, let userCoord = locationManager.userLocation else {
            alertTitle = "Authentication Error"
            alertMessage = "Unable to fetch user credentials or GPS metrics."
            isSuccess = false
            showAlert = true
            return
        }
        
        isProcessingPunch = true
        
        // Fix: Changed user.uid to user.id
        let attendanceRecord: [String: Any] = [
            "userId": user.id,
            "userName": user.name,
            "checkInTime": FieldValue.serverTimestamp(),
            "checkOutTime": NSNull(),
            "latitude": userCoord.latitude,
            "longitude": userCoord.longitude,
            "isWithinGeofence": locationManager.isInsideGeofence,
            "status": "ACTIVE"
        ]
        
        db.collection("attendance_logs").addDocument(data: attendanceRecord) { error in
            DispatchQueue.main.async {
                self.isProcessingPunch = false
                if let error = error {
                    self.alertTitle = "Punch Failed"
                    self.alertMessage = error.localizedDescription
                    self.isSuccess = false
                } else {
                    self.alertTitle = "Attendance Recorded"
                    self.alertMessage = "Face recognition and Geofence verified successfully."
                    self.isSuccess = true
                }
                self.showAlert = true
            }
        }
    }
}

private struct CameraPreviewHolder: UIViewRepresentable {
    @Binding var faceDetected: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        context.coordinator.setupSession(on: view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(faceDetected: $faceDetected)
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        @Binding var faceDetected: Bool
        private let captureSession = AVCaptureSession()
        
        init(faceDetected: Binding<Bool>) {
            self._faceDetected = faceDetected
        }
        
        func setupSession(on view: UIView) {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                self.captureSession.beginConfiguration()
                
                guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                      let input = try? AVCaptureDeviceInput(device: camera) else {
                    return
                }
                
                if self.captureSession.canAddInput(input) {
                    self.captureSession.addInput(input)
                }
                
                let metadataOutput = AVCaptureMetadataOutput()
                if self.captureSession.canAddOutput(metadataOutput) {
                    self.captureSession.addOutput(metadataOutput)
                    metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    metadataOutput.metadataObjectTypes = [.face]
                }
                
                self.captureSession.commitConfiguration()
                self.captureSession.startRunning()
                
                DispatchQueue.main.async {
                    let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                    previewLayer.frame = view.bounds
                    previewLayer.videoGravity = .resizeAspectFill
                    view.layer.addSublayer(previewLayer)
                }
            }
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            DispatchQueue.main.async {
                self.faceDetected = !metadataObjects.isEmpty
            }
        }
    }
}
