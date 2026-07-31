//
//  SearchView.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 17/04/26.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @State private var searchText = ""
    
    @Query var topics: [TopicModel]
    
    var filteredItems: [TopicModel] {
        if searchText.isEmpty {
            return topics
        } else {
            let cleanSearchText = searchText.alphanumericOnly
            return topics.filter { $0.name.alphanumericOnly.contains(cleanSearchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredItems, id: \.id) { topic in
                NavigationLink(value: topic) {
                    HStack {
                        // MARK: change to struct var body: View
                        Text(topic.name)
                        Spacer()
                        searchRow(id: topic.levelID)
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search items...")
            .navigationDestination(for: TopicModel.self) { topic in
                ExerciseView(currentTopicId: topic.id, currentTopicName: topic.name)
            }
            .navigationDestination(for: ExerciseModel.self) { exercise in
                ExamQuestionView(currentTopicId: exercise.id)
            }
        }
    }
}

func searchRow(id: Int) -> some View {
    if id == 5 {
        Text(Image(systemName: "star.fill"))
    } else {
        Text(idToLevelConvert(id))
    }
}

func idToLevelConvert(_ id: Int) -> String {
    switch id {
    case 1:
        return "A1"
    case 2:
        return "A2"
    case 3:
        return "B1"
    case 4:
        return "B2"
    default :
        return "-"
    }
}

extension String {
    var alphanumericOnly: String {
        return self.components(separatedBy: CharacterSet.alphanumerics.inverted).joined().lowercased()
    }
}

#Preview {
    SearchView()
        .environment(ExerciseProgressManager())
        .modelContainer(previewContainer)
}
