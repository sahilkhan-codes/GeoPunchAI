//
//   RegisterViewModel.swift
//  GeoPunchAI
//
//  Created by Student on 06/08/26.
//
import Foundation
import SwiftUI
import FirebaseFirestore

final class RegisterViewModel: ObservableObject {

    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var registerSuccess = false

    private let db = Firestore.firestore()

    func register() {

        errorMessage = ""

        let cleanEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if cleanEmail.isEmpty {
            errorMessage = "Please enter your email."
            return
        }

        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        if password != confirmPassword {
            errorMessage = "Passwords do not match."
            return
        }

        isLoading = true

        AuthManager.shared.register(
            email: cleanEmail,
            password: password
        ) { [weak self] result in

            guard let self = self else { return }

            switch result {

            case .success(let user):

                // Save user profile in Firestore
                let userData: [String: Any] = [
                    "uid": user.uid,
                    "email": cleanEmail,
                    "role": "employee",
                    "createdAt": Timestamp(date: Date())
                ]

                self.db
                    .collection("users")
                    .document(user.uid)
                    .setData(userData) { error in

                        if let error = error {
                            print("⚠️ Firestore error: \(error.localizedDescription)")
                        } else {
                            print("✅ Firestore user profile saved")
                        }
                    }

                // IMPORTANT:
                // Open Dashboard immediately after Firebase Auth succeeds.
                DispatchQueue.main.async {

                    self.isLoading = false
                    self.registerSuccess = true

                    print("🚀 registerSuccess = TRUE")
                }

            case .failure(let error):

                DispatchQueue.main.async {

                    self.isLoading = false
                    self.errorMessage = error.localizedDescription

                    print("❌ Registration error: \(error.localizedDescription)")
                }
            }
        }
    }
}
