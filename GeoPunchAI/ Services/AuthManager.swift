//
//  AuthManager.swift
//  GeoPunchAI
//

import Foundation
import FirebaseAuth

final class AuthManager {

    static let shared = AuthManager()

    private init() {}

    func login(email: String,
               password: String,
               completion: @escaping (Result<User, Error>) -> Void) {

        Auth.auth().signIn(withEmail: email, password: password) { result, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user else {
                completion(.failure(NSError(domain: "", code: -1)))
                return
            }

            completion(.success(user))
        }
    }

    func register(email: String,
                  password: String,
                  completion: @escaping (Result<User, Error>) -> Void) {

        Auth.auth().createUser(withEmail: email, password: password) { result, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user else {
                completion(.failure(NSError(domain: "", code: -1)))
                return
            }

            completion(.success(user))
        }
    }

    func logout() throws {
        try Auth.auth().signOut()
    }

    var currentUser: User? {
        Auth.auth().currentUser
    }
}
