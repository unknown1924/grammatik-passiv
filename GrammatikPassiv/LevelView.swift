//
//  ContentView.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 06/03/26.
//

import SwiftUI
import SwiftData


struct LevelView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \LevelsModel.id) var levels: [LevelsModel]

    @State var presentedLevels: [Levels] = []
    @State var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List(levels) { level in
                NavigationLink(value: level) {
                    VStack(alignment: .leading) {
                        Text(level.name)
                            .font(.title3)
                            .bold()
                        Text(level.levelDescription)
                    }
                }
            }
            .navigationTitle("Grammatik Passiv")
            .onAppear { DatabaseManager.seedLevelData(context: context) }
            .navigationDestination(for: LevelsModel.self) { level in
                TopicView(currentLevelId: level.id, currentLevelName: level.name)
            }
            .navigationDestination(for: TopicModel.self) { topic in
                ExerciseView(currentTopicId: topic.id, currentTopicName: topic.name)
            }
            .navigationDestination(for: ExerciseModel.self) { exercise in
                ExamQuestionView(currentTopicId: exercise.id)
            }
        }
    }
}

#Preview {
    LevelView()
        .modelContainer(for: [LevelsModel.self, TopicModel.self, ExerciseModel.self, ExamModel.self])
}
