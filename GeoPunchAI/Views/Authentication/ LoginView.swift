import SwiftUI

struct LoginView: View {
    @ObservedObject var authManager = AuthManager.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole: UserRole = .employee
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showRegister = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "location.shield.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                
                Text("GeoPunch AI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Production Attendance System")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Select Role", selection: $selectedRole) {
                    Text("Employee").tag(UserRole.employee)
                    Text("Admin Access").tag(UserRole.admin)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 10)
                
                VStack(spacing: 14) {
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Button(action: handleLogin) {
                    HStack {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(selectedRole == .admin ? "Login as Admin" : "Login as Employee")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isLoading)
                .padding(.horizontal)
                
                Button("Create New Account") {
                    showRegister = true
                }
                .font(.footnote)
                .padding(.top, 8)
                
                Spacer()
            }
            .padding()
            .sheet(isPresented: $showRegister) {
                RegisterView(selectedRole: selectedRole)
            }
        }
    }
    
    private func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        authManager.login(email: email, password: password) { result in
            isLoading = false
            switch result {
            case .success:
                break
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}
