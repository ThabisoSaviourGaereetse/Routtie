import SwiftUI

struct RoutineList: View {
    let routines: [Routine]
    @ObservedObject var viewModel: RoutineViewModel
    @Binding var showingAddRoutineView: Bool
    @Binding var showingActionSheet: Bool
    @Binding var selectedRoutine: Routine?

    var body: some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundStyle(Color(.tertiarySystemBackground))
                .padding(.horizontal, 10)
                .overlay(
                    VStack(alignment: .leading) {
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Tasks List")
                                        .padding(.leading, 30)
                                        .padding(.top, 20)
                                        .fontWeight(.light)
                                        .font(.system(size: 15))
                                    Spacer()
                                }
                                ForEach(routines) { routine in
                                    RoutineCardView(routine: routine, viewModel: viewModel, isCompleted: false)
                                        .overlay(
                                            Button(action: {
                                                selectedRoutine = routine
                                                showingActionSheet = true
                                            }, label: {
                                                Image(systemName: "ellipsis.circle")
                                                    .padding()
                                                    .padding(.top, 25)
                                            })
                                            .position(x: UIScreen.main.bounds.width - 50, y: 20)
                                        )
                                }
                                Spacer()
                                
                                // Only show completed routines if any exist
                                if viewModel.getCompletedRoutines().count > 0 {
                                    Text("Completed")
                                        .padding(.leading, 30)
                                        .padding(.top, 25)
                                        .fontWeight(.light)
                                        .font(.system(size: 15))
                                    
                                    ForEach(viewModel.getCompletedRoutines()) { routine in
                                        RoutineCardView(routine: routine, viewModel: viewModel, isCompleted: true)
                                            .overlay(
                                                Button(action: {
                                                    selectedRoutine = routine
                                                    showingActionSheet = true
                                                }, label: {
                                                    Image(systemName: "ellipsis.circle")
                                                        .padding()
                                                        .padding(.top, 25)
                                                })
                                                .position(x: UIScreen.main.bounds.width - 50, y: 20)
                                            )
                                    }
                                }
                                Spacer()
                            }
                            .padding(.bottom)
                        }
                        
                        .padding(.vertical, 13)
                    }
                )
                .onAppear {
                    viewModel.refreshRoutineSorting()
                }
        }
    }
}

struct RoutineList_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct RoutineCardView: View {
    let routine: Routine
    @ObservedObject var viewModel: RoutineViewModel
    var isCompleted: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 25.0)
            .foregroundStyle(isCompleted ? LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.3), Color.black.opacity(0.09)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ) : LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .frame(height: 200)
            .padding(.horizontal, 20)
            .padding(.top, 5)
            .overlay {
                VStack(alignment: .leading) {
                    HStack {
                        Text(routine.title)
                            .padding(.top, 25)
                            .padding(.leading, 35)
                    }
                    Divider()
                        .padding(.horizontal, 35)
                    
                    VStack(alignment: .leading) {
                        Text("Repeating Time(s)")
                            .fontWeight(.light)
                            .font(.system(size: 12))
                            .padding(.horizontal, 35)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(routine.times, id: \.self) { time in
                                    HStack {
                                        TimeSelectionView(time: time, routine: routine, viewModel: viewModel, isCompleted: isCompleted)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 0.5)
                                            .padding(.leading, 3)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 35)
                    }

                    Divider()
                        .padding(.horizontal, 35)
                    
                    Text("Repeating Day(s)")
                        .fontWeight(.light)
                        .font(.system(size: 12))
                        .padding(.horizontal, 35)
                    
                    HStack(spacing: 10) {
                        ForEach(routine.days, id: \.self) { day in
                            Text(day)
                                .fontWeight(.light)
                                .font(.system(size: 15))
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.9))
                                .foregroundColor(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .padding(.horizontal, 35)
                }
                .padding(.bottom, 15)
                Spacer()
            }
    }
}

struct TimeSelectionView: View {
    let time: Date
    let routine: Routine
    @ObservedObject var viewModel: RoutineViewModel
    var isCompleted: Bool

    var body: some View {
        let isSelected = routine.selectedTimes.contains(time)
        
        Text(viewModel.formattedTime(time))
            .fontWeight(.medium)
            .font(.system(size: 15))
            .padding(5)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.9))
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 2)
                            .padding(-3) // Adjust the padding to control the space between the stroke and the background
                    }
                }
            )
            .foregroundColor(isSelected ? Color.black : Color.black)
            .onTapGesture {
                if !isCompleted {
                    viewModel.toggleTimeSelection(for: routine, time: time)
                    if isSelected {
                        viewModel.scheduleNotification(for: routine, at: time)
                    }
                }
            }
    }
}
