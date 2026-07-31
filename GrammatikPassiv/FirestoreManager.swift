//
//  FirestoreManager.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 23/07/26.
//

import SwiftUI
import Foundation
import FirebaseFirestore
import SwiftData

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Generic Write
    /// Saves any Codable object to a specific collection.
    func saveDocument<T: Encodable>(data: T, collection: String, id: String? = nil) throws {
        let collectionRef = db.collection(collection)
        let documentRef = id != nil ? collectionRef.document(id!) : collectionRef.document()
        
        try documentRef.setData(from: data)
    }
    
    // MARK: - Generic Read (Fetch All)
    /// Fetches all documents from a collection and decodes them into the requested type.
    func fetchDocuments<T: Decodable>(collection: String) async throws -> [T] {
        let snapshot = try await db.collection(collection).getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: T.self)
        }
    }
    
    // MARK: - Generic Read (Fetch Single)
    /// Fetches a single document by its ID.
    func fetchDocument<T: Decodable>(collection: String, id: String) async throws -> T {
        let document = try await db.collection(collection).document(id).getDocument()
        return try document.data(as: T.self)
    }
}

@Observable
@MainActor
class ExerciseProgressManager {
    
    var exerciseProgress: [Exercise] = []
    var dailyActivity: [DailyActivity] = []
    // TODO: looks ugly - can something be done about this
    var streakSummary: StreakSummary = StreakSummary(id: 0, currentStreak: 0, longestStreak: 0, lastActivityDateKey: "2026-07-29", freezesAvailable: 0, updatedAt: .now)
    
    let exerciseProgressCollectionName = "exerciseProgress"
    let dailyActivityCollectionName = "dailyActivity"
    let streakSummaryCollectionName = "streakSummary"

    let formatter = DateFormatter()
    
    func fetchExerciseProgress(context: ModelContext) {
        Task {
            do {
                // fetch progress from Firestore
                self.exerciseProgress = try await FirestoreManager.shared.fetchDocuments(collection: exerciseProgressCollectionName)
            } catch {
                print("Failed to fetch progress from Firestore: \(error.localizedDescription)")
            }
            
            // TODO: Move this update swiftdata
            do {
                for progress in exerciseProgress {
                    let model = ExerciseModel(from: progress)
                    context.insert(model)
                }
                try context.save()
            } catch {
                print("Failed to update exercise swiftdata: \(error.localizedDescription)")
            }
        }
    }
    
    func updateExerciseProgress(exercise: Exercise) {
        do {
            try FirestoreManager.shared.saveDocument(data: exercise, collection: exerciseProgressCollectionName, id: String(exercise.id))
        } catch {
            print("Failed to save progress: \(error.localizedDescription)")
        }
    }
    
    func fetchDailyActivityProgress(context: ModelContext) {
        formatter.dateFormat = "yyyy-MM-dd"
        Task {
            do {
                self.dailyActivity = try await FirestoreManager.shared.fetchDocuments(collection: dailyActivityCollectionName)
            } catch {
                print(error)
            }
            
            do {
                for activity in dailyActivity {
                    let model = DailyActivityModel(date: activity.date, completedQuizCount: activity.completedQuizCount, isFreezeUsed: activity.isFreezeUsed)
                    context.insert(model)
                }
                try context.save()
            } catch {
                print("Failed to update exercise swiftdata: \(error.localizedDescription)")
            }
        }
    }
    
    func updateDailyActivityProgress(activity: DailyActivity) {
        formatter.dateFormat = "yyyy-MM-dd"
        
        do {
            try FirestoreManager.shared.saveDocument(data: activity, collection: dailyActivityCollectionName, id: formatter.string(from: activity.date))
        } catch {
            print("Failed to update daily activity progress - firestore: \(error.localizedDescription)")
        }
        
    }

    func fetchStreakSummary(context: ModelContext) {
        Task {
            do {
                streakSummary = try await FirestoreManager.shared.fetchDocument(collection: streakSummaryCollectionName, id: "current")
            } catch {
                print("Failed to fetch streak summary - firestore: \(error.localizedDescription)")
            }
            
            do {
                let streakModel = StreakSummaryModel(currentStreak: streakSummary.currentStreak, longestStreak: streakSummary.longestStreak, freezesAvailable: streakSummary.freezesAvailable)
                context.insert(streakModel)
                try context.save()
            } catch {
                print("Failed to save streak summary - swiftdata: \(error.localizedDescription)")
            }
        }
    }
    
    func updateStreakSummary(streak: StreakSummary) {
        do {
            try FirestoreManager.shared.saveDocument(data: streak, collection: streakSummaryCollectionName, id: "current")
        } catch {
            print("Failed to update streak summary - firestore: \(error.localizedDescription)")
        }
    }
}
