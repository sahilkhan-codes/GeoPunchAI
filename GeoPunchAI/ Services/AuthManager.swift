import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthManager: ObservableObject {
    
    static let shared = AuthManager()
    
    @Published var currentUserRole: UserRole = .employee
    @Published var currentUserData: AppUser?
    @Published var userSession: FirebaseAuth.User?
    
    private var db = Firestore.firestore()
    
    private init() {
        self.userSession = Auth.auth().currentUser
        if self.userSession != nil {
            fetchUserRole()
        }
    }
    
    // Login Implementation
    func login(email: String,
               password: String,
               completion: @escaping (Result<User, Error>) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let user = result?.user else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User session invalid."])))
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.userSession = user
                self?.fetchUserRole()
            }
            
            completion(.success(user))
        }
    }
    
    // Register Implementation (Production Firestore Schema)
    func register(name: String,
                  email: String,
                  password: String,
                  role: UserRole = .employee,
                  completion: @escaping (Result<User, Error>) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let user = result?.user else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create user."])))
                }
                return
            }
            
            let userData: [String: Any] = [
                "id": user.uid,
                "name": name,
                "email": email,
                "role": role.rawValue,
                "geofenceId": NSNull(),
                "faceEmbedding": NSNull()
            ]
            
            self?.db.collection("users").document(user.uid).setData(userData) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        let appUser = AppUser(
                            id: user.uid,
                            name: name,
                            email: email,
                            role: role,
                            geofenceId: nil,
                            faceEmbedding: nil
                        )
                        self?.userSession = user
                        self?.currentUserRole = role
                        self?.currentUserData = appUser
                        completion(.success(user))
                    }
                }
            }
        }
    }
    
    // Fetch User Role from Firestore
    func fetchUserRole() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).getDocument { [weak self] snapshot, _ in
            guard let snapshot = snapshot, snapshot.exists else { return }
            
            if let user = try? snapshot.data(as: AppUser.self) {
                DispatchQueue.main.async {
                    self?.currentUserData = user
                    self?.currentUserRole = user.role
                }
            }
        }
    }
    
    // Logout Implementation
    func logout() throws {
        try Auth.auth().signOut()
        DispatchQueue.main.async {
            self.userSession = nil
            self.currentUserData = nil
            self.currentUserRole = .employee
        }
    }
    
    var currentUser: User? {
        Auth.auth().currentUser
    }
}
