import SwiftUI

struct DashboardView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var showCheckInSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Header / Welcome Card
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome back,")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(authManager.currentUserData?.name ?? "Employee")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // MARK: - Action Card / Quick Attendance Button
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daily Attendance")
                                    .font(.headline)
                                Text("Check-in using Geofence & Face Recognition")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "faceid")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            showCheckInSheet = true
                        }) {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("Punch In / Face Check-In")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            // MARK: - Sheet Integration
            .sheet(isPresented: $showCheckInSheet) {
                EmployeeCheckInView()
            }
        }
    }
}
