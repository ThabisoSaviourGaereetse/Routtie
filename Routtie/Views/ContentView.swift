import SwiftUI
//import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = RoutineViewModel()
    @State private var selectedRoutine: Routine?
    @State private var showingAddRoutineView = false
    @EnvironmentObject private var appearanceManager: AppearanceManager
    @State private var navigateToLogin = false // Add this state variable
    @State private var isLoggedIn = false
    
    var body: some View {
        NavigationView {
            VStack {
                WelcomeHeaderView(showingAddRoutineView: $showingAddRoutineView)
                    .sheet(isPresented: $showingAddRoutineView) {
                        AddRoutineView(viewModel: viewModel, routine: $selectedRoutine)
                            .presentationDetents([.fraction(0.6)])
                        
                    }
                    .padding(.bottom, 2)
                
                CalendarView(viewModel: viewModel)
                
                RoutineListView(viewModel: viewModel, showingAddRoutineView: $showingAddRoutineView)
                
                Spacer()
            }
            .onChange(of: viewModel.isLoggedIn) { isLoggedIn in
                if !isLoggedIn {
                    // Handle user logout state change
                    navigateToLogin = true
                }
            }
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
                    .background(Color("SystemBackground1"))
            )
            .navigationBarHidden(true)
            .sheet(isPresented: $navigateToLogin) {
                LoginView(isLoggedIn: $isLoggedIn) // Present the LoginView as a sheet
                    .presentationDetents([.fraction(0.7)])
            }
        }
        .preferredColorScheme(appearanceManager.isDarkMode ? .dark : .light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
