//
//   OnboardingCardView.swift
//  GeoPunchAI
//
import SwiftUI

struct OnboardingCardView: View {

    let item: OnboardingItem
    let isLastPage: Bool
    let action: () -> Void

    var body: some View {

        VStack(spacing: 30) {

            Spacer()

            Image(systemName: item.image)
                .font(.system(size: 90))
                .foregroundColor(.blue)

            Text(item.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(item.subtitle)
                .font(.title3)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            if isLastPage {

                Button(action: action) {

                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)

                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
}

#Preview {
    OnboardingCardView(
        item: onboardingItems[0],
        isLastPage: false,
        action: {}
    )
}
