import Foundation
import SwiftUI

class SplashViewModel: ObservableObject {
    @Published var showingSplashScreen = true
    
    func startSplashScreenTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                self.showingSplashScreen = false
            }
        }
    }
}
