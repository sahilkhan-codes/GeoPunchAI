import SwiftUI
import AVFoundation
import FirebaseFirestore

struct EmployeeCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var authManager = AuthManager.shared
    
    @State private var isProcessingPunch = false
    @State private var faceDetected = false
    @State private var activeLogId: String? = nil
    @State private var activeCheckInTime: Date? = nil
    @State private var isCheckingActiveStatus = true
    
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
                
                // MARK: - Shift Status Banner
                if let checkInTime = activeCheckInTime {
                    HStack {
                        Image(systemName: "clock.badge.checkmark.fill")
                            .foregroundColor(.blue)
                        Text("Active Shift Started: \(checkInTime, style: .time)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // MARK: - Face Detection Camera Viewport
                ZStack {
                    if locationManager.isInsideGeofence {
                        CameraPreviewHolder(faceDetected: $faceDetected)
                            .frame(height: 320)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(faceDetected ? Color.green : Color.gray.opacity(0.5), lineWidth: 3)
                            )
                        
                        Ellipse()
                            .stroke(faceDetected ? Color.green : Color.white.opacity(0.8), style: StrokeStyle(lineWidth: 3, dash: [8]))
                            .frame(width: 180, height: 240)
                        
                        VStack {
                            Spacer()
                            Text(faceDetected ? "Face Aligned — Ready" : "Position face inside frame")
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
                            Text("Check-in / Check-out Locked")
                                .font(.headline)
                            Text("You must enter the office geofence boundary to activate biometric operations.")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 32)
                        }
                        .frame(height: 320)
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // MARK: - Action Punch Button
                Button(action: handlePunchAction) {
                    HStack {
                        Spacer()
                        if isProcessingPunch || isCheckingActiveStatus {
                            ProgressView()
                                .padding(.trailing, 8)
                        }
                        Text(buttonTitle)
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding()
                    .background(buttonBackgroundColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!locationManager.isInsideGeofence || !faceDetected || isProcessingPunch || isCheckingActiveStatus)
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .navigationTitle(activeLogId == nil ? "Face Check-In" : "Shift Check-Out")
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
                checkActiveShift()
            }
        }
    }
    
    // MARK: - Dynamic UI Helpers
    private var buttonTitle: String {
        if isCheckingActiveStatus {
            return "Checking Shift Status..."
        }
        if isProcessingPunch {
            return activeLogId == nil ? "Recording Punch In..." : "Recording Punch Out..."
        }
        return activeLogId == nil ? "Punch In / Check In" : "Punch Out / Check Out"
    }
    
    private var buttonBackgroundColor: Color {
        guard locationManager.isInsideGeofence && faceDetected && !isProcessingPunch && !isCheckingActiveStatus else {
            return Color.gray
        }
        return activeLogId == nil ? Color.blue : Color.orange
    }
    
    // MARK: - Firestore Operations
    private func checkActiveShift() {
        guard let userId = authManager.currentUserData?.id else {
            isCheckingActiveStatus = false
            return
        }
        
        db.collection("attendance_logs")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "ACTIVE")
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    self.isCheckingActiveStatus = false
                    if let doc = snapshot?.documents.first {
                        self.activeLogId = doc.documentID
                        if let timestamp = doc.get("checkInTime") as? Timestamp {
                            self.activeCheckInTime = timestamp.dateValue()
                        }
                    }
                }
            }
    }
    
    private func handlePunchAction() {
        if activeLogId == nil {
            recordPunchIn()
        } else {
            recordPunchOut()
        }
    }
    
    private func recordPunchIn() {
        guard let user = authManager.currentUserData, let userCoord = locationManager.userLocation else {
            showAlert(title: "Authentication Error", message: "Unable to fetch user credentials or GPS metrics.")
            return
        }
        
        isProcessingPunch = true
        
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
                    self.showAlert(title: "Punch In Failed", message: error.localizedDescription, success: false)
                } else {
                    self.showAlert(title: "Punch In Successful", message: "Welcome! Your shift has been started.", success: true)
                }
            }
        }
    }
    
    private func recordPunchOut() {
        guard let docId = activeLogId else { return }
        
        isProcessingPunch = true
        
        let updateData: [String: Any] = [
            "checkOutTime": FieldValue.serverTimestamp(),
            "status": "COMPLETED"
        ]
        
        db.collection("attendance_logs").document(docId).updateData(updateData) { error in
            DispatchQueue.main.async {
                self.isProcessingPunch = false
                if let error = error {
                    self.showAlert(title: "Punch Out Failed", message: error.localizedDescription, success: false)
                } else {
                    self.showAlert(title: "Punch Out Successful", message: "Have a great day! Your shift has ended.", success: true)
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String, success: Bool = false) {
        self.alertTitle = title
        self.alertMessage = message
        self.isSuccess = success
        self.showAlert = true
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
