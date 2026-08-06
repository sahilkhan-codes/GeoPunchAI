//
//   LoginFormView.swift
//  GeoPunchAI
//
import SwiftUI

struct LoginFormView: View {

    @ObservedObject var viewModel: LoginViewModel

    var body: some View {

        AppCard {

            VStack(spacing: 24) {

                CustomTextField(
                    title: "Email",
                    text: $viewModel.email
                )

                SecureTextField(
                    title: "Password",
                    text: $viewModel.password
                )

                HStack {

                    Spacer()

                    Button("Forgot Password?") {

                    }
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.primary)

                }

                PrimaryButton(title: "Login") {

                    viewModel.login()

                }

            }

        }

    }

}

#Preview {
    LoginFormView(viewModel: LoginViewModel())
}
