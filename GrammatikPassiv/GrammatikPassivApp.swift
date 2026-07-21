//
//  GrammatikPassivApp.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 06/03/26.
//

import SwiftUI
import SwiftData

@main
struct GrammatikPassivApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [TopicModel.self, LevelsModel.self, ExerciseModel.self, ExamModel.self])
    }
}
