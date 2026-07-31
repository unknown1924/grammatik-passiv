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
    @Environment(ExerciseProgressManager.self) private var progressManager
    @Query(sort: \ExerciseModel.id) var exercises: [ExerciseModel]

    @State var currentTopicId: Int
    @State var currentTopicName: String
    @State var status: Bool = false

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
                Label("Übung \(index+1)", systemImage: exercises[index].status ? "checkmark.circle.fill" : "circle")
            }
        }
        .navigationTitle(currentTopicName)
        // TODO: make db seeding async op, use .task {}
        .onAppear {
            DatabaseManager.seedExerciseData(context: context, progressManager)
        }
        // TODO: toolbar here is only for testing for delete/load swiftdata
        .toolbar {
            Button("Delete", systemImage: "trash.fill") {
                do {
                    print("deleting...")
                    try context.delete(model: ExerciseModel.self)
                    try context.save()
                    print("done!")
                } catch {
                    print(error)
                }
            }
            
            Button("Load", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                DatabaseManager.seedExerciseData(context: context, progressManager)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseView(currentTopicId: 1, currentTopicName: "Fragesätze")
            .navigationDestination(for: ExerciseModel.self) { exercise in
                ExamQuestionView(currentTopicId: exercise.id)
            }
    }
    .environment(ExerciseProgressManager())
    .modelContainer(previewContainer)
}
