import SwiftUI
import CoreLocation

struct DashboardView: View {
    @ObservedObject var authManager = AuthManager.shared
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var attendanceManager = AttendanceManager.shared
    
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showCameraScanner = false
    
    var isCheckedIn: Bool {
        attendanceManager.activeRecord != nil
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemGroupedBackground), Color(.systemBackground)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Premium Profile Bar
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 52, height: 52)
                                
                                Text(authManager.currentUserData?.name.prefix(1).uppercased() ?? "E")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("WELCOME BACK")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                    .tracking(1.2)
                                
                                Text(authManager.currentUserData?.name ?? "Employee")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Button(action: handleLogout) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.red)
                                    .padding(12)
                                    .background(Color.red.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Apple Watch Style Premium Timer Card
                        VStack(spacing: 18) {
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "timer")
                                    Text("SHIFT WORKSPACE")
                                        .tracking(1.0)
                                }
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(isCheckedIn ? Color.green : Color.orange)
                                        .frame(width: 7, height: 7)
                                    Text(isCheckedIn ? "ACTIVE" : "OFF-DUTY")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(isCheckedIn ? .green : .orange)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(isCheckedIn ? Color.green.opacity(0.12) : Color.orange.opacity(0.12))
                                .clipShape(Capsule())
                            }
                            
                            Text(formatElapsedTime(elapsedTime))
                                .font(.system(size: 48, weight: .semibold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(
                                    isCheckedIn ?
                                    LinearGradient(colors: [.blue, .indigo], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [.primary, .primary.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                                )
                                .padding(.vertical, 4)
                            
                            Text(isCheckedIn ? "Live Session Tracked in Cloud" : "Tap Punch to start your working shift")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        
                        // Summary Metrics Section
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Summary & Location Logs")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal, 4)
                            
                            HStack(spacing: 14) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Image(systemName: "arrow.down.left.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Check-In")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text(attendanceManager.activeRecord != nil ? timeString(date: attendanceManager.activeRecord!.checkInTime) : "--:--")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                    }
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Image(systemName: locationManager.isInsideGeofence ? "checkmark.shield.fill" : "xmark.shield.fill")
                                        .font(.title2)
                                        .foregroundColor(locationManager.isInsideGeofence ? .green : .red)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Geofence Status")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text(locationManager.isInsideGeofence ? "Inside Office" : "Outside Office")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(locationManager.isInsideGeofence ? .green : .red)
                                    }
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
                            }
                            
                            HStack(spacing: 10) {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.blue)
                                Text(locationManager.geofenceStatusMessage)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 8)
                        }
                        .padding(.horizontal)
                        
                        // Punch Action Button
                        Button(action: {
                            if locationManager.isInsideGeofence || isCheckedIn {
                                showCameraScanner = true
                            }
                        }) {
                            HStack(spacing: 10) {
                                if attendanceManager.isProcessing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: isCheckedIn ? "arrow.right.to.line.circle.fill" : "camera.metering.matrix")
                                        .font(.title3)
                                    
                                    Text(isCheckedIn ? "Punch Check-Out" : (locationManager.isInsideGeofence ? "Scan Face & Punch In" : "Out of Office Range"))
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                isCheckedIn ?
                                LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing) :
                                (locationManager.isInsideGeofence ?
                                 LinearGradient(colors: [.blue, .indigo], startPoint: .leading, endPoint: .trailing) :
                                 LinearGradient(colors: [.gray, .gray.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                            )
                            .foregroundColor(.white)
                            .cornerRadius(18)
                            .shadow(color: (isCheckedIn ? Color.red : (locationManager.isInsideGeofence ? Color.blue : Color.clear)).opacity(0.3), radius: 12, x: 0, y: 6)
                        }
                        .disabled(!locationManager.isInsideGeofence && !isCheckedIn || attendanceManager.isProcessing)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                locationManager.requestLocationPermission()
                locationManager.setTargetGeofence(latitude: 28.5355, longitude: 77.3910, radius: 100.0)
                
                if let userId = authManager.currentUserData?.id {
                    attendanceManager.fetchActiveShift(userId: userId)
                }
            }
            .onChange(of: attendanceManager.activeRecord?.checkInTime) { newCheckInTime in
                if let startTime = newCheckInTime {
                    startTimer(from: startTime)
                } else {
                    stopTimer()
                }
            }
            .sheet(isPresented: $showCameraScanner) {
                VStack(spacing: 24) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 36, height: 5)
                        .padding(.top, 10)
                    
                    Text("Face Verification")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.08))
                            .frame(width: 140, height: 140)
                        
                        Image(systemName: "faceid")
                            .font(.system(size: 64))
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 10)
                    
                    Text("Align your face in the frame to register attendance.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button(action: {
                        handleAttendancePunch()
                        showCameraScanner = false
                    }) {
                        Text("Confirm Verification")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)
                    
                    Button("Cancel") {
                        showCameraScanner = false
                    }
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .padding(.bottom, 16)
                }
                .presentationDetents([.height(420)])
                .presentationCornerRadius(28)
            }
        }
    }
    
    private func handleAttendancePunch() {
        guard let user = authManager.currentUserData else { return }
        
        if let activeRecord = attendanceManager.activeRecord, let recordId = activeRecord.id {
            // Punch Out
            attendanceManager.punchOut(recordId: recordId) { success in
                if success {
                    stopTimer()
                }
            }
        } else {
            // Punch In
            attendanceManager.punchIn(
                userId: user.id,
                userName: user.name,
                location: locationManager.userLocation?.coordinate,
                isInside: locationManager.isInsideGeofence
            ) { success in
                if success, let startTime = attendanceManager.activeRecord?.checkInTime {
                    startTimer(from: startTime)
                }
            }
        }
    }
    
    private func startTimer(from date: Date) {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime = Date().timeIntervalSince(date)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
    }
    
    private func handleLogout() {
        stopTimer()
        try? authManager.logout()
    }
    
    private func formatElapsedTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func timeString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
