//
//  SplashView.swift
//  SynthesiaAI
//
//  Created by b on 23.01.2026.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var progress: CGFloat = 0
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image(.splashIcon)
                
                Spacer()
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "346AEA").opacity(0.2))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "346AEA"))
                            .frame(width: geo.size.width * progress, height: 6)
                    }
                }
                .frame(width: 220, height: 6)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                withAnimation(.linear(duration: 2.0)) {
                    progress = 1.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                isActive = true
            }
        }
    }
}
