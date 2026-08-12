//
//  RegisterView.swift
//  GeoPunchAI
//
import SwiftUI

struct RegisterView: View {

    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {

        VStack(spacing: 20) {

            Spacer()

            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Email", text: $viewModel.email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

            SecureField("Confirm Password", text: $viewModel.confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

            if !viewModel.errorMessage.isEmpty {

                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {

                viewModel.register()

            } label: {

                if viewModel.isLoading {

                    ProgressView()
                        .tint(.white)

                } else {

                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
            .disabled(viewModel.isLoading)

            Button("Already have an account? Login") {

                dismiss()

            }

            Spacer()
        }
        .padding()

        // Dashboard opens after successful registration
        .fullScreenCover(isPresented: $viewModel.registerSuccess) {
            DashboardView()
        }
    }
}

#Preview {
    RegisterView()
}
