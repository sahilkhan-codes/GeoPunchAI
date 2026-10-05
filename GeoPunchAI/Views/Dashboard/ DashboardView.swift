import SwiftUI

struct DashboardView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var showCheckInSheet = false
    @State private var showProfileSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Modern Welcome Banner Card
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back 👋")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(authManager.currentUserData?.name ?? "Employee")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        // Interactive Top-Right Profile Avatar
                        Button(action: { showProfileSheet = true }) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 48, height: 48)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // MARK: - Daily Attendance Hero Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("DAILY ATTENDANCE")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                
                                Text("Check-in using Geofence & Face Recognition")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "faceid")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            showCheckInSheet = true
                        }) {
                            HStack {
                                Image(systemName: "location.fill.viewfinder")
                                    .font(.title3)
                                Text("Punch In / Face Check-In")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(colors: [.blue, .indigo], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.35), radius: 6, x: 0, y: 3)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // MARK: - Navigation Quick Actions
                    VStack(spacing: 12) {
                        
                        // 1. Attendance History
                        NavigationLink(destination: AttendanceHistoryView()) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.12))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.title3)
                                        .foregroundColor(.orange)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Attendance History")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("View past check-ins & shift duration")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                        }
                        
                        // 2. Profile & Account Settings Card
                        Button(action: { showProfileSheet = true }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.purple.opacity(0.12))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "person.crop.square.fill")
                                        .font(.title3)
                                        .foregroundColor(.purple)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("My Profile & Settings")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("View details, edit info & profile photo")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .sheet(isPresented: $showCheckInSheet) {
                EmployeeCheckInView()
            }
            .sheet(isPresented: $showProfileSheet) {
                ProfileView()
            }
        }
    }
}
