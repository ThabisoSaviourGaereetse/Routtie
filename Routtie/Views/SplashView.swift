import SwiftUI
import Firebase
import FirebaseAuth

struct SplashView: View {
    @EnvironmentObject private var appearanceManager: AppearanceManager
    @State private var isLoggedIn = false
    @State private var showLoginView = false
    @State private var navigateToContent = false
    @State private var showLoginAfterDismiss = false // Track if login should be shown after dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image("SplashScreenLogo")
                    .resizable()
                    .frame(width: 200, height: 200)
                
                Text("Routtie")
                    .fontWeight(.medium)
                    .font(.system(size: 65))
                    .padding(.vertical, -15)
                    .foregroundColor(appearanceManager.isDarkMode ? .white : .black)
                
                Text("Your favourite routine and habit tracker.")
                    .fontWeight(.medium)
                    .font(.system(size: 10))
                    .padding(.top, 1)
                    .foregroundColor(appearanceManager.isDarkMode ? .white : .black)
                
                Spacer()
                Spacer()
                
                GIFView(name: "loading")
                    .frame(width: 25, height: 25)
                
                Text("Loading")
                    .fontWeight(.medium)
                    .font(.system(size: 10))
                    .padding(.top, 1)
                    .foregroundColor(appearanceManager.isDarkMode ? .white : .black)
            }
            .frame(minWidth: 400)
            .background(
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .blur(radius: 50)
                        .frame(width: 300, height: 300)
                        .position(x: UIScreen.main.bounds.width / 4, y: 0)
                        .zIndex(0)
                    
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .blur(radius: 50)
                        .frame(width: 300, height: 300)
                        .position(x: UIScreen.main.bounds.width * 3 / 4, y: UIScreen.main.bounds.height)
                        .zIndex(0)
                }
                .background(Color(appearanceManager.isDarkMode ? .black : .white))
            )
            .onAppear {
                // Add a delay of 3 seconds before checking login status
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    checkLoginStatus()
                }
            }
            .popover(isPresented: $showLoginView) {
                LoginView(isLoggedIn: $isLoggedIn)
                    .onDisappear {
                        if !isLoggedIn {
                            startReappearLoginTimer()
                        }
                    }
            }
            .fullScreenCover(isPresented: $navigateToContent) {
                ContentView() // Replace with your actual ContentView
            }
            .onChange(of: isLoggedIn) { loggedIn in
                if loggedIn {
                    navigateToContentView()
                }
            }
            .onChange(of: showLoginAfterDismiss) { value in
                if value && !isLoggedIn {
                    showLoginView = true
                }
            }
        }
    }
    
    private func checkLoginStatus() {
        if !didUserLogInEver() {
            // User has never logged in
            showLoginView = true
        } else {
            // User has logged in at least once
            navigateToContentView()
        }
    }
    
    private func didUserLogInEver() -> Bool {
        // Check if a login date exists in UserDefaults
        if let _ = UserDefaults.standard.object(forKey: "lastLoginDate") as? Date {
            return true
        }
        return false
    }
    
    private func navigateToContentView() {
        // Trigger navigation to ContentView
        navigateToContent = true
    }
    
    private func startReappearLoginTimer() {
        // Schedule login view to reappear after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            if !isLoggedIn {
                showLoginAfterDismiss = true
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .environmentObject(AppearanceManager())  // Add this line to preview with AppearanceManager
    }
}
