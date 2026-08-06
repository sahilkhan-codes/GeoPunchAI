//
//   BottomNavigationView.swift
//  GeoPunchAI
//
//  Created by Student on 04/08/26.
import SwiftUI

struct BottomNavigationView: View {

    var body: some View {

        HStack {

            Spacer()

            VStack {

                Image(systemName: "house.fill")
                    .font(.title2)

                Text("Home")
                    .font(.caption)

            }

            Spacer()

            VStack {

                Image(systemName: "calendar")
                    .font(.title2)

                Text("History")
                    .font(.caption)

            }

            Spacer()

            VStack {

                Image(systemName: "person.fill")
                    .font(.title2)

                Text("Profile")
                    .font(.caption)

            }

            Spacer()

        }
        .padding(.vertical,12)
        .background(.ultraThinMaterial)

    }

}

#Preview {
    BottomNavigationView()
}
