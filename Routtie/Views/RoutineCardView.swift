//import SwiftUI
//
//struct RoutineCardView: View {
//    let routine: Routine
//    @ObservedObject var viewModel: RoutineViewModel
//    
//    var body: some View {
//        RoundedRectangle(cornerRadius: 25.0)
//            .foregroundStyle(LinearGradient(
//                gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.blue.opacity(0.2)]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            ))
//            .frame(height: 200)
//            .padding(.horizontal, 20)
//            .padding(.top, 5)
//            .overlay {
//                VStack(alignment: .leading) {
//                    HStack {
//                        Text(routine.title)
//                            .padding(.top, 25)
//                            .padding(.leading, 35)
//                    }
//                    Divider()
//                    .padding(.horizontal, 35)
//                    
//                    Text("Repeating Day(s)")
//                        .fontWeight(.light)
//                        .font(.system(size: 12))
//                        .padding(.horizontal, 35)
//                    
//                    HStack(spacing: 10) {
//                        ForEach(routine.days, id: \.self) { day in
//                            Text(day)
//                                .fontWeight(.light)
//                                .font(.system(size: 15))
//                                .frame(width: 40, height: 40)
//                                .background(Color.gray.opacity(0.2))
//                                .foregroundColor(Color.black)
//                                .clipShape(RoundedRectangle(cornerRadius: 20))
//                        }
//                    }
//                    .padding(.horizontal, 35)
//                    
//                    Divider()
//                        .padding(.horizontal, 35)
//                    
//                    VStack(alignment: .leading) {
//                        Text("Repeating Time(s)")
//                            .fontWeight(.light)
//                            .font(.system(size: 12))
//                            .padding(.horizontal, 35)
//                        
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack {
//                                ForEach(routine.times, id: \.self) { time in
//                                    TimeSelectionView(time: time, routine: routine, viewModel: viewModel)
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 35)
//                    }
//                    
//                }
//                .padding(.bottom, 15)
//                Spacer()
//            }
//    }
//}
//
//struct RoutineCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
