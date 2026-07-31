//
//  DatabaseManager.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 06/04/26.
//

import Foundation
import SwiftData


@MainActor
class DatabaseManager {
    
//    static let shared = DatabaseManager()
//    let container: ModelContainer
//    var context: ModelContext { container.mainContext }
//    
//    private init() {
//        do {
//            container = try ModelContainer(for: ExamModel.self)
//        } catch {
//            fatalError("Failed to initialize SwiftData container.")
//        }
//    }
    
    static func seedTopicData(context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<TopicModel>()
        let existingCount = (try? context.fetchCount(fetchDescriptor)) ?? 0
        
        guard existingCount == 0 else { return }
        guard let url = Bundle.main.url(forResource: "topics", withExtension: "json") else {
            print("JSON file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedTopics = try JSONDecoder().decode([Topic].self, from: data)
            
            for topic in decodedTopics {
                let newTopic = TopicModel(from: topic)
                context.insert(newTopic)
            }
            try context.save()
            print("Successfully seeded Topic database.")
        } catch {
            print("Failed to decode and seed topic JSON: \(error)")
        }
    }

    static func seedLevelData(context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<LevelsModel>()
        let existingCount = (try? context.fetchCount(fetchDescriptor)) ?? 0
        
        guard existingCount == 0 else { return }
        guard let url = Bundle.main.url(forResource: "levels", withExtension: "json") else {
            print("JSON file not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decodedTopics = try JSONDecoder().decode([Levels].self, from: data)
            
            for topic in decodedTopics {
                let newTopic = LevelsModel(from: topic)
                context.insert(newTopic)
            }
            try context.save()
            print("Successfully seeded Level database.")
        } catch {
            print("Failed to decode and seed level JSON: \(error)")
        }
    }

    static func seedExerciseData(context: ModelContext, _ progressManager: ExerciseProgressManager) {
        let fetchDescriptor = FetchDescriptor<ExerciseModel>()
        let existingCount = (try? context.fetchCount(fetchDescriptor)) ?? 0
        
        guard existingCount == 0 else { return }
        guard let url = Bundle.main.url(forResource: "exercise", withExtension: "json") else {
            print("JSON file not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decodedTopics = try JSONDecoder().decode([Exercise].self, from: data)
            
            for topic in decodedTopics {
                let newTopic = ExerciseModel(from: topic)
                context.insert(newTopic)
            }
            try context.save()
            print("Successfully seeded Exercise database.")
        } catch {
            print("Failed to decode and seed exerise JSON: \(error)")
        }
        progressManager.fetchExerciseProgress(context: context)
    }
    
    static func seedExamData(context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<ExamModel>()
        let existingCount = (try? context.fetchCount(fetchDescriptor)) ?? 0
        
        guard existingCount == 0 else { return }
        guard let url = Bundle.main.url(forResource: "exam", withExtension: "json") else {
            print("JSON file not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decodedTopics = try JSONDecoder().decode([Exam].self, from: data)
            
            for topic in decodedTopics {
                let newTopic = ExamModel(from: topic)
                context.insert(newTopic)
            }
            try context.save()
            print("Successfully seeded Exam database.")
        } catch {
            print("Failed to decode and seed exam JSON: \(error)")
        }
    }
    
    // MARK: READ (Manual Fetch)
    func fetchAllTopics(context: ModelContext) -> [ExamModel] {
        let descriptor = FetchDescriptor<ExamModel>(sortBy: [SortDescriptor(\.id)])
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: UPDATE
    func toggleStatus(for topic: ExamModel, context: ModelContext) {
        topic.status.toggle()
        try? context.save()
    }
    
    // MARK: DELETE
    func delete(topic: ExamModel, context: ModelContext) {
        context.delete(topic)
        try? context.save()
    }
    
    // TODO: Do i need this?
    static func fetchDailyActivityAndStreak(context: ModelContext) {
        ExerciseProgressManager().fetchDailyActivityProgress(context: context)
        ExerciseProgressManager().fetchStreakSummary(context: context)
    }
    
    static func recordActivity(context: ModelContext) {
        let today = Calendar.current.startOfDay(for: .now)
        let todayKey = DailyActivityModel.formatter.string(from: today)

        // Avoid duplicate entries for the same day
        let descriptor = FetchDescriptor<DailyActivityModel>(
            predicate: #Predicate { $0.dateKey == todayKey }
        )
        if let existing = try? context.fetch(descriptor), !existing.isEmpty {
            return // already logged today
        }

        do {
            let activity = DailyActivityModel(date: today)
            context.insert(activity)
            try context.save()
        } catch {
            print(error)
        }

        let progressManager = ExerciseProgressManager()
        progressManager.fetchDailyActivityProgress(context: context)
        updateStreak(context: context, today: today)
    }

    static func updateStreak(context: ModelContext, today: Date) {
        let summaryDescriptor = FetchDescriptor<StreakSummaryModel>()
        let summary = (try? context.fetch(summaryDescriptor))?.first ?? {
            let s = StreakSummaryModel()
            context.insert(s)
            return s
        }()
        
        do {
            try context.save()
        } catch {
            print(error)
        }

        let calendar = Calendar.current
        if let lastKey = summary.lastActivityDateKey,
           let lastDate = DailyActivityModel.formatter.date(from: lastKey) {
            let daysBetween = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
            if daysBetween == 1 {
                summary.currentStreak += 1
            } else if daysBetween == 0 {
                // same day, no-op
            } else {
                summary.currentStreak = 1 // streak broken, restart
            }
        } else {
            summary.currentStreak = 1
        }

        summary.longestStreak = max(summary.longestStreak, summary.currentStreak)
        summary.lastActivityDateKey = DailyActivityModel.formatter.string(from: today)
        summary.updatedAt = .now
        
        // TODO: streakSummary saving to swiftdata then fetching from firestore - is this right?
        ExerciseProgressManager().fetchStreakSummary(context: context)
    }
}
