//
//  RouttieApp.swift
//  Routtie
//
//  Created by Thabiso Gaereetse on 2024/08/13.
//

import SwiftUI
import Firebase

@main
struct RouttieApp: App {
    @StateObject private var viewModel = SplashViewModel()
    @StateObject private var appearanceManager = AppearanceManager()
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(appearanceManager)
                .onAppear {
                    viewModel.startSplashScreenTimer()
                }
        }
    }
}
