import SwiftUI

class AppearanceManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            savePreferences()
        }
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
    
    private func savePreferences() {
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
    }
}
