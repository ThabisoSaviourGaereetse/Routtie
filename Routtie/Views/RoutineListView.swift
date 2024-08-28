import SwiftUI
import UserNotifications

struct RoutineListView: View {
    @ObservedObject var viewModel: RoutineViewModel
    @Binding var showingAddRoutineView: Bool
    @State private var selectedRoutine: Routine?
    @State private var showingActionSheet = false
    @State private var selectedSegment = 0
    @State private var isLoggedIn = false
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    HStack {
                        Text("Daily")
                            .fontWeight(.medium)
                            .font(.system(size: 15))
                            .frame(width: 70, height: 25)
                            .background(selectedSegment == 0 ? Color.blue : Color.clear)
                            .foregroundColor(selectedSegment == 0 ? Color.white : Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .onTapGesture {
                                selectedSegment = 0
                            }
                        
                        Text("Other")
                            .fontWeight(.medium)
                            .font(.system(size: 15))
                            .frame(width: 70, height: 25)
                            .background(selectedSegment == 1 ? Color.blue : Color.clear)
                            .foregroundColor(selectedSegment == 1 ? Color.white : Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .onTapGesture {
                                selectedSegment = 1
                            }
                    }
                    .padding(3)
                    .background(Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25.0)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 15)
                
                if selectedSegment == 0 {
                    RoutineList(routines: viewModel.routinesForToday(),
                                viewModel: viewModel,
                                showingAddRoutineView: $showingAddRoutineView,
                                showingActionSheet: $showingActionSheet,
                                selectedRoutine: $selectedRoutine)
                } else {
                    RoutineList(routines: viewModel.otherRoutines(),
                                viewModel: viewModel,
                                showingAddRoutineView: $showingAddRoutineView,
                                showingActionSheet: $showingActionSheet,
                                selectedRoutine: $selectedRoutine)
                }
            }
            .onAppear {
                viewModel.requestNotificationPermission()
            }
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(
                    title: Text("Edit or Delete Routine"),
                    buttons: [
                        .default(Text("Edit")) {
                            showingAddRoutineView = true
                        },
                        .destructive(Text("Delete")) {
                            if let routine = selectedRoutine {
                                viewModel.deleteRoutine(routine)
                            }
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showingAddRoutineView) {
                AddRoutineView(viewModel: viewModel, routine: $selectedRoutine)
            }
            .navigationBarHidden(true)
        }
    }
}

struct RoutineListView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineListView(viewModel: RoutineViewModel(), showingAddRoutineView: .constant(false))
    }
}
