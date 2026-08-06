//
//   LoginView.swift
//  GeoPunchAI
import SwiftUI

struct LoginView: View {

    @StateObject private var viewModel = LoginViewModel()

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 32) {

                    LoginHeaderView()

                    LoginFormView(viewModel: viewModel)

                    LoginFooterView()

                }
                .padding(Theme.screenPadding)

            }
            .background(AppColors.background)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $viewModel.loginSuccess) {
                DashboardView()
            }

        }

    }

}

#Preview {
    LoginView()
}
