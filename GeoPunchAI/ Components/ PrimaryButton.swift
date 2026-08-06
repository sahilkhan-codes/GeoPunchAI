//
//   PrimaryButton.swift
//  GeoPunchAI
//
//  Created by Student on 04/08/26.
//
import SwiftUI

struct PrimaryButton: View {

    let title: String
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            Text(title)
                .font(AppFonts.bodyBold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.buttonHeight)
                .background(AppColors.primary)
                .cornerRadius(Theme.buttonRadius)

        }

    }

}

#Preview {

    PrimaryButton(title: "Continue") {

    }

}
