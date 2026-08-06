//
//   StatusCardView.swift
//  GeoPunchAI
//
//  Created by Student on 04/08/26.
import SwiftUI

struct StatusCardView: View {

    var body: some View {

        VStack(alignment: .leading, spacing: 15) {

            Text("Office Status")
                .font(.headline)

            HStack {

                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)

                Text("Inside Office Geofence")
                    .fontWeight(.semibold)

            }

            Text("You can punch your attendance.")
                .foregroundColor(.gray)

            Divider()

            HStack {

                VStack(alignment: .leading) {

                    Text("Accuracy")
                        .foregroundColor(.gray)

                    Text("98%")
                        .fontWeight(.bold)

                }

                Spacer()

                VStack(alignment: .leading) {

                    Text("Radius")
                        .foregroundColor(.gray)

                    Text("100 m")
                        .fontWeight(.bold)

                }

            }

        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(18)

    }
}

#Preview {
    StatusCardView()
}
