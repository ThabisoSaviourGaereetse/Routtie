import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: RoutineViewModel
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10.0)
                .frame(width: 65, height: 65)
                .foregroundColor(Color.clear)
                .overlay(
                    VStack {
                        Button(action: {
                            
                        }, label: {
                            VStack {
                                Image(systemName: "calendar")
                                    .resizable()
                                    .frame(width: 30, height: 28)
                                Text("History")
                                    .fontWeight(.light)
                                    .font(.system(size: 12))
                                    .padding(.top, -1)
                            }
                            .foregroundColor(Color(.label))
                        })
                    }
                )
                
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.getUpcomingDates(count: 30), id: \.self) { date in
                        VStack {
                            Text(viewModel.formatDate(date))
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(viewModel.formatMonth(date))
                                .font(.caption)
                                .foregroundColor(viewModel.isToday(date) ? Color.white : Color(.label))
                        }
                        .padding()
                        .frame(width: 65, height: 65)
                        .background(
                            ZStack {
                                if viewModel.isToday(date) {
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.5)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                } else {
                                    Color(.tertiarySystemBackground)
                                }
                            }
                        )
                        .foregroundColor(viewModel.isToday(date) ? Color.white : Color(.label))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.trailing)
            }
            .frame(height: 80)
        }
        .padding(.leading, 15)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
