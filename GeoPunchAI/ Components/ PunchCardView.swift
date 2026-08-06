//
//   PunchCardView.swift
//  GeoPunchAI
//
import SwiftUI

struct PunchCardView: View {

    var body: some View {

        VStack(spacing: 20) {

            Text("Today's Attendance")
                .font(.headline)

            Text("--:--")
                .font(.system(size: 40, weight: .bold))

            Text("Working Time")
                .foregroundColor(.gray)

            Text("00:00:00")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(spacing: 15) {

                Button {

                } label: {

                    Text("Punch In")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)

                }

                Button {

                } label: {

                    Text("Punch Out")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)

                }

            }

        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(18)

    }
}

#Preview {
    PunchCardView()
}
