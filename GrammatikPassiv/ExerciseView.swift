//
//  ExerciseView.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 03/04/26.
//

import SwiftUI
import SwiftData

struct ExerciseView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ExerciseModel.id) var exercises: [ExerciseModel]

    @State var currentTopicId: Int
    @State var currentTopicName: String
    
    init(currentTopicId: Int, currentTopicName: String) {
        let filter = #Predicate<ExerciseModel> { exercise in
            exercise.topicId == currentTopicId
        }

        _exercises = Query(filter: filter, sort: \ExerciseModel.id)
        _currentTopicId = State(initialValue: currentTopicId)
        _currentTopicName = State(initialValue: currentTopicName)
    }

    var body: some View {
        List(exercises.indices, id: \.self) { index in
            NavigationLink(value: exercises[index]) {
                Text("Übung \(index+1)")
                    .font(.title3)
            }
        }
        .navigationTitle(currentTopicName)
        .onAppear { DatabaseManager.seedExerciseData(context: context) }
    }
}

#Preview {
    NavigationStack {
        ExerciseView(currentTopicId: 1, currentTopicName: "Fragesätze")
            .navigationDestination(for: ExerciseModel.self) { exercise in
                ExamQuestionView(currentTopicId: exercise.id)
            }
    }
    .modelContainer(for: [ExerciseModel.self, ExamModel.self])
}
