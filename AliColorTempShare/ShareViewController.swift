//
//  ShareViewController.swift
//  AliColorTempShare
//
//  Created by Ali Haidar on 3/10/25.
//

import UIKit
import SwiftUI

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isModalInPresentation = true
        
        if let itemProviders = (extensionContext!.inputItems.first as? NSExtensionItem)?.attachments {
            let hostingView = UIHostingController(rootView: ShareView(itemProviders: itemProviders, extensionContext: self.extensionContext))
            hostingView.view.frame = view.frame
            view.addSubview(hostingView.view)
        }
    }
}

fileprivate struct ShareView: View {
    var itemProviders: [NSItemProvider]
    var extensionContext: NSExtensionContext?
    @State private var items: [ImageItem] = []
    @State private var alertMessage: String?
    @State private var showAlert: Bool = false
    
    var body: some View {
        ZStack{
            ForEach(items) { item in
                Image(uiImage: item.previewImage)
                    .resizable()
                    .ignoresSafeArea()
                    .zIndex(0)
                    .blur(radius: 50, opaque: true)
            }
            GeometryReader { geometry in
                let size = geometry.size
                
                VStack {
                    Text("Edit Image")
                        .frame(maxWidth: .infinity)
                        .overlay(alignment: .leading) {
                            Button("Cancel", action: dismiss).tint(.red)
                                .bold().shadow(radius: 5)
                        }
                        .padding(.bottom, 15)
                    
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 15) {
                            ForEach(items) { item in
                                Image(uiImage: item.previewImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .frame(width: size.width - 30)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .frame(height: 300)
                    
                    
                    if showAlert, let alertMessage = alertMessage {
                        Text(alertMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        // Create a deep link with the original image data (not the preview)
                        if let encodedImageLink = generateDeepLink(with: items.first?.imageData) {
                            Link("Edit on Ubersnap", destination: encodedImageLink)
                                .foregroundColor(.white)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 20).fill(.thinMaterial))
                                .shadow(radius: 0.5)
                                .padding(.top, 30)
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
                .padding(15)
                .onAppear {
                    extractImage(size: size)
                }
            }
        }
    }
    
    func extractImage(size: CGSize) {
        guard items.isEmpty else { return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            for provider in itemProviders {
                provider.loadDataRepresentation(for: .image) { data, error in
                    guard let data = data else { return }
                    
                    if let image = UIImage(data: data) {
                        // Check if image is JPEG format by typeIdentifiers
                        if let typeIdentifier = provider.registeredTypeIdentifiers.first {
                            // Check if the type is either "public.jpeg" or "public.jpg"
                            if typeIdentifier == "public.jpeg" || typeIdentifier == "public.jpg" {
                                // JPEG image, add to items
                                DispatchQueue.main.async {
                                    items.append(.init(imageData: data, previewImage: image))
                                }
                            } else {
                                // Not a JPEG image
                                DispatchQueue.main.async {
                                    alertMessage = "Only JPEG images are supported. Please select a JPEG file."
                                    showAlert = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func dismiss() {
        // Ensure that the extensionContext is available and complete the request
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    private struct ImageItem: Identifiable {
        let id: UUID = .init()
        var imageData: Data  // Store original image data
        var previewImage: UIImage
    }
    
    // Function to generate deep link URL with base64 encoded image data (original image)
    func generateDeepLink(with imageData: Data?) -> URL? {
        guard let imageData = imageData else { return nil }
        
        // Convert the image data to base64
        let base64String = imageData.base64EncodedString()
        
        var components = URLComponents()
        components.scheme = "aliccolortemp"
        components.host = "edit"
        components.queryItems = [
            URLQueryItem(name: "imageData", value: base64String)
        ]
        
        return components.url
    }
}
