//
//  SliderComponent.swift
//  AliColorTemp
//
//  Created by Ali Haidar on 3/9/25.
//

import SwiftUI

// This are for the custom button with slider (When user editing image)
struct SliderComponent: View {
    var title: String
    var iconName: String
    @Binding var value: Float
    var id: Int
//    This make sure only one expanded and the other colapsed
    @Binding var selectedSlider: Int?
    var minValue: Float
    var maxValue: Float
    var step: Float
    var onChange: ((Float) -> Void)?
    
    var body: some View {
        VStack {
            HStack {
                if selectedSlider != id {
                    Spacer()
                }
                Image(systemName: iconName)
                Text(title)
                Spacer()
                if selectedSlider == id {
                    Text(String(format: "%.2f", value))
                        .padding()
                }
            }
            
//            Show Slider only when on the current selected one
            if selectedSlider == id {
                withAnimation(.bouncy) {
                    Slider(value: $value, in: minValue...maxValue, step: step)
                        .accentColor(.white)
                        .cornerRadius(10)
                        .padding()
                        .onChange(of: value) { newValue in
                            onChange?(newValue)
                        }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(.thinMaterial))
        .shadow(radius: 0.5)
        .onTapGesture {
            withAnimation(.bouncy) {
                if selectedSlider == id {
                    selectedSlider = nil
                } else {
                    selectedSlider = id
                }
            }
        }
    }
}
