import SwiftUI

struct AdminDashboardView: View {
    @StateObject private var authManager = AuthManager.shared
    
    // MARK: - Sheet Presentation States
    @State private var showGeofenceSetup = false
    @State private var showAttendanceLogs = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Admin Welcome Header Card
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Admin Portal")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(authManager.currentUserData?.name ?? "Administrator")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        Image(systemName: "shield.authorization")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 40)
                            .foregroundColor(.indigo)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // MARK: - Management Tools Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Management Tools")
                            .font(.headline)
                            .padding(.horizontal, 4)
                        
                        // TOOL 1: CONFIGURE GEOFENCE
                        Button(action: {
                            showGeofenceSetup = true
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "location.magnifyingglass")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Configure Geofence")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Update office location & radius threshold")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        
                        // TOOL 2: REAL-TIME ATTENDANCE LOGS
                        Button(action: {
                            showAttendanceLogs = true
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "list.clipboard")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(Color.green)
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Attendance Logs")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Monitor real-time employee check-ins & shifts")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Admin Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        try? authManager.logout()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            // MARK: - Sheets Integration
            .sheet(isPresented: $showGeofenceSetup) {
                AdminGeofenceSetupView()
            }
            .sheet(isPresented: $showAttendanceLogs) {
                AttendanceLogsView()
            }
        }
    }
}
