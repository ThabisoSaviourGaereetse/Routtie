import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @StateObject private var viewModel = RoutineViewModel()
    @EnvironmentObject private var appearanceManager: AppearanceManager
    @State private var showingAddRoutineView = false
    @State private var notificationsEnabled = true
    @Environment(\.presentationMode) var presentationMode

    @State private var dragOffset = CGSize.zero
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false // New state to track loading status

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image("SplashScreenLogo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding(.bottom)
                Spacer()
                Text("Log in or sign up")
                    .fontWeight(.medium)
                    .font(.system(size: 30))
                    .padding(.vertical, -15)
                    .foregroundColor(Color(.label))
                    .padding(.bottom, 20)

                TextField("Username or email address", text: $email)
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(50)
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical, 15)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(50)
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .multilineTextAlignment(.leading)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Button(action: {
                    signIn()
                }) {
                    RoundedRectangle(cornerRadius: 50)
                        .foregroundStyle(Color(.blue))
                        .frame(height: 50)
                        .padding(.horizontal, 10)
                        .overlay(
                            HStack {
                                Text("Log In")
                                    .foregroundStyle(Color(.white))
                                    .fontWeight(.medium)
                            }
                        )
                }
                .padding(.vertical, 10)

                HStack {
                    VStack {
                        Divider()
                    }
                    Text("or")
                    VStack {
                        Divider()
                    }
                }
                .padding(.bottom)

                Button(action: {
                    signUp()
                }) {
                    RoundedRectangle(cornerRadius: 50)
                        .foregroundColor(Color(.tertiarySystemBackground))
                        .frame(height: 50)
                        .padding(.horizontal, 10)
                        .overlay(
                            HStack {
                                Text("Sign Up")
                                    .foregroundStyle(Color(.label))
                            }
                        )
                }

                Spacer()

                
            }
            .overlay(
                VStack {
                    if isLoading { // Show loading GIF if isLoading is true
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("SystemBackground1").opacity(0.8))
                            .frame(width: 150, height: 150)
                            .overlay(
                                VStack {
                                    GIFView(name: "loading")
                                        .frame(width: 50, height: 50)
                                    Text("Loading")
                                        .foregroundColor(appearanceManager.isDarkMode ? .white : .black)
                                        .font(.headline)
                                        .padding(.top, 10)
                                }
                            )
                            .padding(.top, 20)
                    }
                }
            )
            .padding(.top, 20)
            .padding(.horizontal, 10)
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
                .background(Color(appearanceManager.isDarkMode ? .black : .systemBackground1))
            )
            .navigationBarHidden(true)
            .offset(y: dragOffset.height)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.height > 0 {
                            dragOffset = gesture.translation
                        }
                    }
                    .onEnded { _ in
                        if dragOffset.height > 100 {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            dragOffset = .zero
                        }
                    }
            )
            .preferredColorScheme(appearanceManager.isDarkMode ? .dark : .light)
        }
    }

    private func signIn() {
        isLoading = true // Start loading
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false // Stop loading
            
            if let error = error {
                errorMessage = "Wrong email or password. Please try again."
                return
            }
            // Handle successful sign in
            print("Successfully signed in")
            isLoggedIn = true
            saveLoginDate()
            presentationMode.wrappedValue.dismiss() // Dismiss LoginView
        }
    }

    private func signUp() {
        isLoading = true // Start loading
        errorMessage = ""

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isLoading = false // Stop loading
            
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            // Handle successful sign up
            print("Successfully signed in")
            isLoggedIn = true
            saveLoginDate()
            presentationMode.wrappedValue.dismiss() // Dismiss LoginView
        }
    }

    private func saveLoginDate() {
        // Save the current date as the last login date
        UserDefaults.standard.set(Date(), forKey: "lastLoginDate")
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedIn: .constant(false)).environmentObject(AppearanceManager())
    }
}
