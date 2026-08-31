import SwiftUI

struct DashboardView: View {
    @ObservedObject var authManager = AuthManager.shared
    
    @State private var isCheckedIn = false
    @State private var checkInTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showCameraScanner = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic Background Gradient
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
                            
                            Text(isCheckedIn ? "Live Session Tracked" : "Tap Punch to start your working shift")
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
                        
                        // Summary Metrics Section (Glassmorphic Cards)
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Summary & Logs")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal, 4)
                            
                            HStack(spacing: 14) {
                                // Check-in Metric Card
                                VStack(alignment: .leading, spacing: 12) {
                                    Image(systemName: "arrow.down.left.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Check-In")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text(checkInTime != nil ? timeString(date: checkInTime!) : "--:--")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                    }
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
                                
                                // Status Metric Card
                                VStack(alignment: .leading, spacing: 12) {
                                    Image(systemName: "checkmark.shield.fill")
                                        .font(.title2)
                                        .foregroundColor(isCheckedIn ? .green : .gray)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Location Status")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text(isCheckedIn ? "Inside Geofence" : "Ready")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(isCheckedIn ? .green : .primary)
                                    }
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Action Button
                        Button(action: {
                            showCameraScanner = true
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: isCheckedIn ? "arrow.right.to.line.circle.fill" : "camera.metering.matrix")
                                    .font(.title3)
                                
                                Text(isCheckedIn ? "Punch Check-Out" : "Scan Face & Punch In")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                isCheckedIn ?
                                LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [.blue, .indigo], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(18)
                            .shadow(color: (isCheckedIn ? Color.red : Color.blue).opacity(0.3), radius: 12, x: 0, y: 6)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
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
                        toggleCheckInState()
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
    
    private func toggleCheckInState() {
        if isCheckedIn {
            isCheckedIn = false
            timer?.invalidate()
            timer = nil
        } else {
            isCheckedIn = true
            checkInTime = Date()
            elapsedTime = 0
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if let startTime = checkInTime {
                    elapsedTime = Date().timeIntervalSince(startTime)
                }
            }
        }
    }
    
    private func handleLogout() {
        timer?.invalidate()
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
