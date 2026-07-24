//
//  GrammatikPassivApp.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 06/03/26.
//

import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}


@main
struct GrammatikPassivApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var progressManager = ExerciseProgressManager()
    
    var body: some Scene {
        WindowGroup {
            AuthenticationView()
        }
        .environment(progressManager)
        .modelContainer(for: [TopicModel.self, LevelsModel.self, ExerciseModel.self, ExamModel.self])
    }
}
