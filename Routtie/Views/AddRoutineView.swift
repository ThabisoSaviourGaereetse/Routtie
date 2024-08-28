import SwiftUI
import UIKit

struct AddRoutineView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RoutineViewModel
    
    @Binding var routine: Routine?
    
    @State private var title: String = ""
    @State private var selectedDays: [String] = []
    @State private var selectedTimes: [Date] = []
    @State private var selectedTime = Date()
    
    @State private var showAlert = false
    @State private var alertMessage = ""

    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Add your title here...", text: $title)
                .padding(.top, 25)
                .padding(.leading, 35)
            Divider()
                .padding(.horizontal, 35)
            
            Text("Select Day(s)")
                .fontWeight(.light)
                .font(.system(size: 12))
                .padding(.horizontal, 35)
            HStack(spacing: 10) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .fontWeight(.light)
                        .font(.system(size: 15))
                        .frame(width: 40, height: 40)
                        .background(selectedDays.contains(day) ? Color.blue.opacity(0.5) : Color.gray.opacity(0.2))
                        .foregroundColor(selectedDays.contains(day) ? Color.white : Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .onTapGesture {
                            if selectedDays.contains(day) {
                                selectedDays.removeAll { $0 == day }
                            } else {
                                selectedDays.append(day)
                            }
                        }
                }
            }
            .padding(.horizontal, 35)
            
            Divider()
                .padding(.horizontal, 35)
            
            VStack(alignment: .leading) {
                Text("Select Time(s)")
                    .fontWeight(.light)
                    .font(.system(size: 12))
                    .padding(.horizontal, 5)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(selectedTimes, id: \.self) { time in
                            Text(formattedTime(time))
                                .fontWeight(.medium)
                                .font(.system(size: 15))
                                .padding(5)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .onLongPressGesture(minimumDuration: 0.5) {
                                    if let index = selectedTimes.firstIndex(of: time) {
                                        selectedTimes.remove(at: index)
                                        let generator = UIImpactFeedbackGenerator(style: .medium)
                                        generator.impactOccurred()
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 5)
                
                Divider()
                    .padding(.horizontal, 5)
                
                HStack {
                    DatePicker(
                        "Select Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .frame(height: 180)
                    .frame(minWidth: 250)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.leading, 5)
                    
                    Button(action: {
                        selectedTimes.append(selectedTime)
                    }) {
                        Image(systemName: "plus.circle")
                            .frame(width: 50, height: 180)
                            .background(Color.blue.opacity(0.5))
                            .foregroundColor(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .padding(.trailing, 2)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 35)
            
            Button(action: {
                if title.isEmpty {
                    alertMessage = "Title is required."
                    showAlert = true
                } else if selectedDays.isEmpty {
                    alertMessage = "Please select at least one day."
                    showAlert = true
                } else if selectedTimes.isEmpty {
                    alertMessage = "Please select at least one time."
                    showAlert = true
                } else {
                    if let routine = routine {
                        // Update existing routine
                        viewModel.updateRoutine(routine: routine, title: title, days: selectedDays, times: selectedTimes)
                    } else {
                        // Add new routine
                        viewModel.addRoutine(title: title, days: selectedDays, times: selectedTimes)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Save")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 35)
            }
            .padding(.top, 20)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Missing Information"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            
            Spacer()
        }
        .onAppear {
            if let routine = routine {
                // Populate fields with routine data
                title = routine.title
                selectedDays = routine.days
                selectedTimes = routine.times
            }
        }
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}


struct AddRoutineView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
