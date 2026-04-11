//
//  ExamView.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 05/04/26.
//

import SwiftUI
import SwiftData

struct ExamView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ExamModel.id) var exams: [ExamModel]
    
    @State var currentTopicName: String
    @State var currentTopicId: Int = 0
    @State var presentedExams: [Levels] = []

    var body: some View {
        NavigationStack(path: $presentedExams) {
            List(exams) { exam in
                NavigationLink {
                    Text("Great!")
                } label: {
                    Section {
                        VStack(alignment: .leading) {
                            Text(exam.question)
                            Text(exam.option1)
                            Text(exam.option2)
                        }
                    }
                }
            }
            .navigationTitle(currentTopicName)
        }
        .onAppear { DatabaseManager.seedExamData(context: context) }
    }
}

#Preview {
    ExamView(currentTopicName: "Übung 1")
        .modelContainer(for: ExamModel.self)
}
