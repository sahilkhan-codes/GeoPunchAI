//
//   LoginFooterView.swift
//  GeoPunchAI
//
//  Created by Student on 04/08/26.
import SwiftUI

struct LoginFooterView: View {

    var body: some View {

        VStack(spacing: 24) {

            HStack {

                Rectangle()
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 1)

                Text("OR")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)

                Rectangle()
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 1)

            }

            VStack(spacing: 10) {

                Image(systemName: "faceid")
                    .font(.system(size: 36))
                    .foregroundColor(AppColors.primary)

                Text("Face Verification")
                    .font(AppFonts.bodyBold)

                Text("Coming Soon")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)

            }

            Text("GeoPunch AI v1.0")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)

        }
        .padding(.top, 20)

    }

}

#Preview {
    LoginFooterView()
}
