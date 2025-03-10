

import SwiftUI

final class Router: ObservableObject {
//    This are for navigating using router
    public enum Destination: Hashable {
        case start
        case edit(image: UIImage)
    }
    
    @Published var navPath = NavigationPath()
    
    func navigate(to destination: Destination) {
        navPath.append(destination)
    }
    
    func navigateBack() {
        if navPath.count > 0 {
            navPath.removeLast()
        } else {
            navigate(to: .start)
        }
    }
    
    func navigateToRoot() {
        navPath.removeLast(navPath.count - 1)
    }
}

