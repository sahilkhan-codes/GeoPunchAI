//
//   LoginHeaderView.swift
//  GeoPunchAI
//
//  Created by Student on 04/08/26.
//
import SwiftUI

struct LoginHeaderView: View {

    var body: some View {

        VStack(spacing: 16) {

            Image(systemName: "location.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(AppColors.primary)

            Text("GeoPunch AI")
                .font(AppFonts.largeTitle)
                .foregroundColor(AppColors.textPrimary)

            Text("Smart Attendance with AI & Geofencing")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)

        }
        .padding(.bottom, 20)

    }
}

#Preview {
    LoginHeaderView()
}
