//
//   CustomTextField.swift
//  GeoPunchAI
//
//  Created by Student on 04/08/26.
//
import SwiftUI

struct CustomTextField: View {

    let title: String
    @Binding var text: String

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.textSecondary)

            TextField("Enter \(title)", text: $text)
                .padding()
                .background(AppColors.surface)
                .cornerRadius(Theme.textFieldRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.textFieldRadius)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )

        }

    }

}

#Preview {

    CustomTextField(
        title: "Email",
        text: .constant("")
    )

}
