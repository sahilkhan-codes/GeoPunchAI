import SwiftUI

struct AdminDashboardView: View {
    @ObservedObject var authManager = AuthManager.shared
    
    var body: some View {
        NavigationStack {
            List {
                Section("Management") {
                    NavigationLink(destination: GeofenceSetupView()) {
                        Label("Geofence Setup", systemImage: "location.circle.fill")
                    }
                    
                    NavigationLink(destination: AttendanceLogsView()) {
                        Label("Attendance Logs", systemImage: "doc.plaintext.fill")
                    }
                }
                
                Section("Account") {
                    Button(role: .destructive) {
                        try? authManager.logout()
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Admin Panel")
        }
    }
}
