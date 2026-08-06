//
//   SplashViews.swift
//  GeoPunchAI
//
//  Created by Student on 03/08/26.
import SwiftUI

struct SplashView: View {
    
    @State private var isActive = false
    
    var body: some View {
        
        ZStack {
            
            Color.blue
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("GeoPunch AI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Smart Attendance")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            .onAppear {

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {

                    isActive = true

                }

            }
            .fullScreenCover(isPresented: $isActive) {

                OnboardingView()

            }
            
        }
    }
}

#Preview {
    SplashView()
}
