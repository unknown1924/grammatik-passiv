//
//  HomeView.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 17/04/26.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State var path = NavigationPath()

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            
            Tab("All Levels", systemImage: "chart.bar") {
                LevelView()
            }
            
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                SearchView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [LevelsModel.self, TopicModel.self, ExerciseModel.self, ExamModel.self])
}
