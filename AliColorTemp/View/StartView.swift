//
//  StartView.swift
//  AliColorTemp
//
//  Created by Ali Haidar on 3/9/25.
//

import SwiftUI
import PhotosUI
import UIKit
import SpriteKit

struct StartView: View {
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var image: Image? = nil
    @State private var uiImage: UIImage? = nil
    @State private var temperatureAdjustment: Float = 0
    @State private var permissionGranted: Bool = false
    @State private var isImageSaved: Bool = false
    
    @EnvironmentObject var router: Router
    
    @State private var buttonOffset: CGFloat = 200
    @State private var secondButtonOffset: CGFloat = 200
    @State private var gradientRotation: Double = 0
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let scene: LetterScene = {
        let scene = LetterScene()
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        return scene
    }()
    
    var body: some View {
        ZStack{
            
            PhotoEditingIconsView()
            
            VStack{
                
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged { gesture in
                                scene.handleTouch(at: gesture.location)
                            }
                    )
                    .onAppear {
                        // Start gradient animation
                        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                            gradientRotation = 360
                        }
                        
                        // Wait for initial delay (2s) + assembly time (3s) before showing button
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            withAnimation(.spring(duration: 0.6)) {
                                buttonOffset = 0
                            }
                        }
                        
                        // Add delay for second button appearance
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                            withAnimation(.spring(duration: 0.6)) {
                                secondButtonOffset = 0
                            }
                        }
                    }
                
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Text("Pick Image")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 240, height: 60)
                            .background(Color(hex: 0x262626))
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(
                                        AngularGradient(
                                            gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple, .red]),
                                            center: .center,
                                            startAngle: .degrees(gradientRotation),
                                            endAngle: .degrees(gradientRotation + 360)
                                        ),
                                        lineWidth: 5
                                    )
                            )
                            .cornerRadius(30)
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let selectedItem,
                               let data = try? await selectedItem.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                
                                if let imageType = selectedItem.supportedContentTypes.first?.identifier,
                                   imageType == "public.jpeg" || imageType == "public.jpg" {
                                    // Move to next view if the image is JPEG
                                    self.uiImage = uiImage
                                    self.image = Image(uiImage: uiImage)
                                    router.navigate(to: .edit(image: uiImage))
                                } else {
                                    // Show error if not JPEG
                                    print("Error: Selected file is not a JPEG image.")
                                    alertMessage = "Only JPEG images are supported. Please select a JPEG file."
                                    showAlert = true
                                }
                            }
                        }
                    }
                
                    .offset(y: buttonOffset)
                    .padding(.bottom, 20)
                
            }
            
        }
        .onAppear {
            selectedItem = nil
            checkPhotoLibraryPermission()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Invalid Image Format"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
            
        }
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            permissionGranted = true
        case .denied, .restricted:
            permissionGranted = false
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized || status == .limited {
                        permissionGranted = true
                    } else {
                        permissionGranted = false
                    }
                }
            }
        @unknown default:
            permissionGranted = false
        }
    }
}
