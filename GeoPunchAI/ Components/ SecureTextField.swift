//
//   SecureTextField.swift
//  GeoPunchAI
//
import SwiftUI

struct SecureTextField: View {

    let title: String
    @Binding var text: String

    @State private var isSecure = true

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.textSecondary)

            HStack {

                Group {

                    if isSecure {

                        SecureField("Enter \(title)", text: $text)

                    } else {

                        TextField("Enter \(title)", text: $text)

                    }

                }

                Button {

                    isSecure.toggle()

                } label: {

                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundColor(.gray)

                }

            }
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

    SecureTextField(
        title: "Password",
        text: .constant("")
    )

}
