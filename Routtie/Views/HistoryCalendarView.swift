import SwiftUI

struct HistoryCalendarView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Calendar History")
                .fontWeight(.medium)
                .font(.system(size: 25))
            
            Spacer()
            
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
    }
}

#Preview {
    HistoryCalendarView()
}
