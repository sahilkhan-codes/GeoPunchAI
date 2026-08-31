import SwiftUI

struct ContentView: View {
    @ObservedObject var authManager = AuthManager.shared
    
    var body: some View {
        Group {
            if authManager.userSession != nil {
                if authManager.currentUserRole == .admin {
                    AdminDashboardView()
                } else {
                    DashboardView()
                }
            } else {
                LoginView()
            }
        }
        .onAppear {
            if authManager.userSession != nil {
                authManager.fetchUserRole()
            }
        }
         
    }
}
