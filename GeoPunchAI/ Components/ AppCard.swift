//
//   AppCard.swift
//  GeoPunchAI
//
//  Created by Student on 04/08/26.
//
import SwiftUI

struct AppCard<Content: View>: View {

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {

        content
            .padding(Theme.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.surface)
            .cornerRadius(Theme.cardRadius)
            .shadow(
                color: .black.opacity(Theme.shadowOpacity),
                radius: Theme.shadowRadius,
                x: 0,
                y: 4
            )
    }
}

#Preview {

    AppCard {

        Text("GeoPunch AI")
            .font(AppFonts.title)

    }

}
