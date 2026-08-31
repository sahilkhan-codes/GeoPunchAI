import Foundation
import Combine

class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var selectedRole: UserRole = .employee
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    func register(completion: @escaping (Bool) -> Void) {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter all details."
            completion(false)
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // Added 'name: name' parameter here
        AuthManager.shared.register(name: name, email: email, password: password, role: selectedRole) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
}
