//import SwiftUI
//
//struct TimeSelectionView: View {
//    let time: Date
//    let routine: Routine
//    @ObservedObject var viewModel: RoutineViewModel
//    
//    var body: some View {
//        let isSelected = routine.selectedTimes.contains(time)
//        
//        Text(viewModel.formattedTime(time))
//            .fontWeight(.medium)
//            .font(.system(size: 15))
//            .padding(5)
//            .background(isSelected ? Color.blue.opacity(0.6) : Color.gray.opacity(0.2))
//            .foregroundColor(isSelected ? Color.white : Color.black)
//            .clipShape(RoundedRectangle(cornerRadius: 20))
//            .onTapGesture {
//                viewModel.toggleTimeSelection(for: routine, time: time)
//                if isSelected {
//                    viewModel.scheduleNotification(for: routine, at: time)
//                }
//            }
//    }
//}
//
//struct TimeSelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
