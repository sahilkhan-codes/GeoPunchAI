//
//   OnboardingView.swift
//  GeoPunchAI
import SwiftUI

struct OnboardingView: View {

    @State private var currentPage = 0
    @State private var showLogin = false

    var body: some View {

        TabView(selection: $currentPage) {

            ForEach(Array(onboardingItems.enumerated()), id: \.element.id) { index, item in

                OnboardingCardView(
                    item: item,
                    isLastPage: index == onboardingItems.count - 1,
                    action: {
                        showLogin = true
                    }
                )
                .tag(index)

            }

        }
        .tabViewStyle(.page)
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
        }

    }
}

#Preview {
    OnboardingView()
}
