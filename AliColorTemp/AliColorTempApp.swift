//
//  AliColorTempApp.swift
//  AliColorTemp
//
//  Created by Ali Haidar on 3/9/25.
//

import SwiftUI

@main
struct AliColorTempApp: App {
    
    @StateObject var router = Router()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.navPath) {
                ContentView()
                    .navigationDestination(for: Router.Destination.self) { destination in
                        switch destination {
                        case .start:
                            StartView()
                                .environmentObject(router)
                        case .edit(image: let image):
                            EditView(image: image)
                                .environmentObject(router)
                        }
                    }
                    .environmentObject(router)
                    .onOpenURL { url in
                        handleDeepLink(url: url)
                    }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    // Handle the deep link URL
    func handleDeepLink(url: URL) {
            if url.scheme == "aliccolortemp" {
                // Extract the path and query parameters from the URL
                if let host = url.host, host == "edit", let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
                    if let imageDataString = queryItems.first(where: { $0.name == "imageData" })?.value,
                       let imageData = Data(base64Encoded: imageDataString),
                       let image = UIImage(data: imageData) {
                        // Pass the decoded image to the EditView
                        router.navPath.append(Router.Destination.edit(image: image))
                    } else {
                        // Handle invalid image data or fallback
                        print("Invalid image data")
                    }
                }
            }
        }
}
