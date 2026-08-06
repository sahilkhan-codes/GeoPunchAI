//
//   DashboardView.swift
//  GeoPunchAI
//
//  Created by Student on 04/08/26.
import SwiftUI

struct DashboardView: View {

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(alignment: .leading, spacing: 20) {

                    // MARK: Header

                    VStack(alignment: .leading, spacing: 8) {

                        Text("Good Morning 👋")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Sahil Khan")
                            .font(.title2)

                        Text("Employee ID: EMP001")
                            .foregroundColor(.gray)

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // MARK: Office Status Card

                    StatusCardView()
                    PunchCardView()
                    BottomNavigationView()
                    
                }
                .padding()

            }
            .navigationBarHidden(true)

        }

    }
}

#Preview {
    DashboardView()
}
