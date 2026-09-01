import SwiftUI

struct RootView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        Group {
            if authManager.userSession != nil {
                // User login status ke according view switch hoga
                switch authManager.currentUserRole {
                case .admin:
                    AdminDashboardView()
                case .employee:
                    DashboardView()
                }
            } else {
                LoginView()
            }
        }
    }
}
