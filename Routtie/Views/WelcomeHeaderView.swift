import SwiftUI

struct WelcomeHeaderView: View {
    @Binding var showingAddRoutineView: Bool
    @State private var showingProfileView = false

    var body: some View {
        HStack {
            
            VStack(alignment: .leading) {
                Text("Today")
                    .fontWeight(.medium)
                    .font(.system(size: 45))
            }
            .padding(.leading)
            
            Spacer()
            
            Button(action: {
                showingAddRoutineView.toggle()
            }, label: {
                Image(systemName: "plus.circle")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(Color(.label))
                    .padding(.trailing, 5)
                    .padding(.vertical, 8)
            })
            
            Button(action: {
                showingProfileView = true
            }, label: {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(Color(.label))
                    .padding(.trailing)
            })
            .fullScreenCover(isPresented: $showingProfileView) {
                ProfileView()
                    .transition(.move(edge: .leading)) // Custom transition from the right
            }
        }
        .padding(.top, 20)
    }
}

struct WelcomeHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
