//import SwiftUI
//
//struct UsernameInputView: View {
//    @Binding var userName: String
//    @Binding var isPresented: Bool
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Change Username")
//                .font(.headline)
//                .padding()
//
//            TextField("Enter new username", text: $userName)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//
//            HStack {
//                Button("Cancel") {
//                    isPresented = false
//                }
//                .foregroundColor(.red)
//                .padding()
//
//                Spacer()
//
//                Button("Update") {
//                    isPresented = false
//                }
//                .padding()
//            }
//        }
//        .padding()
//        .background(Color(.clear))
//        .cornerRadius(10)
//        .shadow(radius: 10)
//        .padding()
//    }
//}
