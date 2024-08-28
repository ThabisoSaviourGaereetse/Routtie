import SwiftUI
import Firebase
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var viewModel = RoutineViewModel()
    @EnvironmentObject private var appearanceManager: AppearanceManager
    @State private var showingAddRoutineView = false
    @State private var notificationsEnabled = true
    @Environment(\.presentationMode) var presentationMode
    
    @State private var dragOffset = CGSize.zero
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    @State private var showingEditOptions = false
    @State private var showingImagePicker = false
    @State private var profileImage: Image? = Image(systemName: "person.circle")
    @State private var userName: String = "User Name"
    @State private var newUserName: String = ""
    @State private var showingUsernameAlert = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        // Dismiss the view
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "chevron.down")
                            .resizable()
                            .frame(width: 25, height: 15)
                            .foregroundColor(Color(.label))
                            .padding(.leading, 5)
                    })
                    Spacer()
                }
                
                profileImage?
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 120, height: 120)
                    .overlay(Circle().stroke(Color.blue.opacity(0.1), lineWidth: 4))
                    .padding(.top, 20)
                
                Text(userName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                
                HStack {
                    Spacer()
                    Button(action: {
                        showingEditOptions = true
                    }) {
                        VStack {
                            Image(systemName: "pencil.circle")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundColor(Color(.label))
                                .padding(.vertical, 8)
                            
                            Text("Edit")
                                .foregroundStyle(Color(.label))
                                .fontWeight(.light)
                                .font(.system(size: 12))
                                .padding(.top, -10)
                        }
                    }
                    .actionSheet(isPresented: $showingEditOptions) {
                        ActionSheet(title: Text("Edit Profile"), message: Text("Choose an option"), buttons: [
                            .default(Text("Change Profile Picture")) {
                                showingImagePicker = true
                            },
                            .default(Text("Remove Profile Picture")) {
                                profileImage = Image(systemName: "person.circle")
                            },
                            .default(Text("Change Username")) {
                                showingUsernameAlert = true
                            },
                            .cancel()
                        ])
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(selectedImage: $profileImage)
                    }
                    .alert("Change Username", isPresented: $showingUsernameAlert) {
                        TextField("New Username", text: $newUserName)
                        Button("Cancel", role: .cancel) {}
                        Button("Update") {
                            if !newUserName.isEmpty {
                                userName = newUserName
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        appearanceManager.isDarkMode.toggle()
                    }) {
                        VStack {
                            Image(systemName: appearanceManager.isDarkMode ? "moon.circle" : "sun.max.circle")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundColor(Color(.label))
                                .padding(.vertical, 8)
                            
                            Text("Mode")
                                .foregroundStyle(Color(.label))
                                .fontWeight(.light)
                                .font(.system(size: 12))
                                .padding(.top, -10)
                        }
                    }
                    Spacer()
                }
                .padding(.top, 20)
                Spacer()
                
                Button(action: {
                    logout()
                }) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 50)
                        .foregroundColor(Color(.tertiarySystemBackground))
                        .overlay(
                            VStack{
                                Text("Logout")
                                    .foregroundStyle(Color(.label))
                            }
                        )
                        .padding(10)
                }
            }
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

    private func logout() {
        // Sign out from Firebase
        do {
            try Auth.auth().signOut()
            // Update UserDefaults to reflect logout
            UserDefaults.standard.removeObject(forKey: "lastLoginDate")
            // Navigate back to login screen
            presentationMode.wrappedValue.dismiss()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(AppearanceManager())
    }
}
