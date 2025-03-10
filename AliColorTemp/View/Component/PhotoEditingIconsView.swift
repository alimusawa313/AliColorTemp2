//
//  PhotoEditingIconsView.swift
//  AliColorTemp
//
//  Created by Ali Haidar on 3/10/25.
//

import SwiftUI

struct PhotoEditingIconsView: View {
    let symbols = [
        "photo", "pencil", "wand.and.stars", "crop", "flip.horizontal",
        "star.fill", "rectangle.and.pencil.and.ellipsis", "slider.horizontal.3",
        "camera", "square.and.pencil", "paintbrush", "lightbulb", "rectangle.compress.vertical",
        "camera.filters", "app.badge.fill", "circle.grid.2x2"
    ]
    
    @State private var appear = false
    
    var body: some View {
        ZStack {
            ForEach(0..<symbols.count, id: \.self) { index in
                Image(systemName: self.symbols[index])
                    .resizable()
                    .frame(width: self.randomSize(), height: self.randomSize())
                    .foregroundColor(self.randomColor())
                    .rotationEffect(.degrees(self.randomRotation()))
                    .opacity(self.randomOpacity())
                    .position(self.randomPosition())
                    .scaleEffect(appear ? 1 : 0)
                    .animation(
                        .easeInOut(duration: 1.0).delay(Double(index) * 0.05),
                        value: appear
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            appear = true
        }
    }
    
    func randomColor() -> Color {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
        return colors.randomElement() ?? .black
    }
    
    func randomRotation() -> Double {
        return Double.random(in: 0..<360)
    }
    
    func randomOpacity() -> Double {
        return Double.random(in: 0.3..<1.0)
    }
    
    func randomPosition() -> CGPoint {
        return CGPoint(x: CGFloat.random(in: 50...350), y: CGFloat.random(in: 100...700))
    }

    func randomSize() -> CGFloat {
        return CGFloat.random(in: 30...80) 
    }
}

