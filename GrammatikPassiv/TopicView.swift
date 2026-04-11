//
//  TopicView.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 03/04/26.
//

import SwiftUI
import SwiftData

struct TopicView: View {
    
    @Environment(\.modelContext) private var context
    @Query var topics: [TopicModel]
    
    @State var currentLevelId: Int = 1
    @State var currentLevelName: String = ""
    
    init(currentLevelId: Int, currentLevelName: String) {
        let filter = #Predicate<TopicModel> { topic in
            topic.levelID == currentLevelId
        }

        _topics = Query(filter: filter, sort: \TopicModel.id)
        _currentLevelId = State(initialValue: currentLevelId)
        _currentLevelName = State(initialValue: currentLevelName)
    }
    
    var body: some View {
        List(topics) { topic in
            NavigationLink(value: topic) {
                Text(topic.name)
                    .font(.title3)
            }
        }
        .navigationTitle(currentLevelName)
        .onAppear { DatabaseManager.seedTopicData(context: context) }
    }
}

#Preview {
    NavigationStack {
        TopicView(currentLevelId: 1, currentLevelName: "Level A1")
            .navigationDestination(for: TopicModel.self) { topic in
                ExerciseView(currentTopicId: topic.id, currentTopicName: topic.name)
            }
    }
    .modelContainer(for: [TopicModel.self, ExerciseModel.self])
}
