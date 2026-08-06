//
//  LoginViewModel.swift
//  GeoPunchAI
//

import Foundation
import SwiftUI

final class LoginViewModel: ObservableObject {

    @Published var email = ""
    @Published var password = ""

    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var loginSuccess = false

    func login() {

        errorMessage = ""

        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter your email."
            return
        }

        if password.isEmpty {
            errorMessage = "Please enter your password."
            return
        }

        isLoading = true

        AuthManager.shared.login(email: email, password: password) { [weak self] result in

            DispatchQueue.main.async {

                guard let self = self else { return }

                self.isLoading = false

                switch result {

                case .success(_):
                    self.loginSuccess = true

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
