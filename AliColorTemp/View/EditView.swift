//
//  EditView.swift
//  AliColorTemp
//
//  Created by Ali Haidar on 3/9/25.
//

import SwiftUI

// this are the view when you edit the image
struct EditView: View {
    @EnvironmentObject var router: Router
    
    var image: UIImage?
    @State private var temperatureAdjustment: Float = 0
    @State private var brightnessAdjustment: Float = 0
    @State private var contrastAdjustment: Float = 1
    @State private var adjustedImage: UIImage?
    @State private var isImageSaved: Bool = false
    
    @State private var selectedSlider: Int? = nil
    
//    for fancy fliping animation
    @State var flip = false
    @State var flip2 = false
    
    // Add a debounce time to throttle the updates
    @State private var isUpdating: Bool = false
    
    
    var body: some View {
        ZStack {
            
//            Make the background match the image (Make it look like Apple Invites LOL)
            Image(uiImage: image!)
                .resizable()
                .ignoresSafeArea()
                .zIndex(0)
                .blur(radius: 50, opaque: true)
            
            ScrollView(.vertical) {
                VStack {
                    
                    ZStack {
                        // Before Image
                        Image(uiImage: image!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 400)
                            .clipped()
                            .zIndex(flip2 ? 1 : 0)
                        
                        // After Image
                        if let adjustedImage = adjustedImage {
                            Image(uiImage: adjustedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .background(Color.white)
                                .frame(width: 300, height: 400)
                                .clipped()
                                .animation(.easeInOut(duration: 0.2))
                        }
                    }
                    .clipShape(.rect(cornerRadius: 24))
                    .rotation3DEffect(.degrees(flip ? 180 : 0 ), axis: (x: 0, y: 1, z: 0))
                    .onTapGesture {
                        if adjustedImage != nil {
                            withAnimation(.spring(duration: 1)) { flip.toggle() }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
                                withAnimation(.spring(duration: 1)) { flip2.toggle() }
                            }
                        }
                    }

                    Spacer()
                    
                    SliderComponent(
                        title: "Temperature",
                        iconName: "thermometer.sun.fill",
                        value: $temperatureAdjustment,
                        id: 1,
                        selectedSlider: $selectedSlider,
                        minValue: -100,
                        maxValue: 100,
                        step: 1,
                        onChange: { _ in
                            if !isUpdating {
                                isUpdating = true
                                // Wait a bit before updating the image to prevent choppy performance
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    updateAdjustedImage()
                                    isUpdating = false
                                }
                            }
                        })
                    
                    SliderComponent(
                        title: "Brightness",
                        iconName: "sun.max.fill",
                        value: $brightnessAdjustment,
                        id: 2,
                        selectedSlider: $selectedSlider,
                        minValue: -100,
                        maxValue: 100,
                        step: 1,
                        onChange: { _ in
                            if !isUpdating {
                                isUpdating = true
                                // Wait a bit before updating the image to prevent choppy performance
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    updateAdjustedImage()
                                    isUpdating = false
                                }
                            }
                        })
                    
                    SliderComponent(
                        title: "Contrast",
                        iconName: "circle.righthalf.filled",
                        value: $contrastAdjustment,
                        id: 3,
                        selectedSlider: $selectedSlider,
                        minValue: 0.5,
                        maxValue: 3,
                        step: 0.1,
                        onChange: { _ in
                            if !isUpdating {
                                isUpdating = true
                                // Wait a bit before updating the image to prevent choppy performance
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    updateAdjustedImage()
                                    isUpdating = false
                                }
                            }
                        })
                    
                    Spacer()
                }
                .padding(.top, 50)
                .padding()
            }
            
            VStack {
                HStack {
                    Button {
                        showBackConfirmation()
                    } label: {
                        Image(systemName: "xmark")
                            .bold()
                            .foregroundStyle(.white)
                            .shadow(radius: 5)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(radius: 0.5)
                    }
                    
                    Spacer()
                    
                    if let adjustedImage = adjustedImage {
                        Button {
                                saveImageToGallery(image: adjustedImage)
                        } label: {
                            Text("Save")
                                .bold()
                                .foregroundStyle(.white)
                                .shadow(radius: 5)
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(radius: 0.5)
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden()
    }
    
    // this to update the adjusted image when any sliders change
    private func updateAdjustedImage() {
        if let image = image {
            // Apply all transformations in sequence: Temperature -> Brightness & Contrast
            let tempImage = OpenCVWrapper.adjustImageTemperature(image, withAdjustment: temperatureAdjustment)
            let brightAndContrastImage = OpenCVWrapper.adjustBrightnessAndContrast(tempImage, brightness: brightnessAdjustment, contrast: contrastAdjustment)
            adjustedImage = brightAndContrastImage
        }
    }
    
    // Save the adjusted image to  gallery
    private func saveImageToGallery(image: UIImage) {
        // Ensure the image is properly converted to its final form before saving
        let finalImage = image
        UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
        isImageSaved = true
        showSaveSuccessAlert()
    }
    
    // show the success alert after saving
    private func showSaveSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "Image saved to gallery!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
    
    // show alert confirmation when back is pressed
    private func showBackConfirmation() {
            let alert = UIAlertController(title: "Are you sure?", message: "Any unsaved changes will be lost.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                router.navigateBack()
            }))

            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {
                window.rootViewController?.present(alert, animated: true)
            }
        }
}

