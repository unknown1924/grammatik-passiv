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
    var progress: [Exercise] = []
    
    let collectionName = "questions"

    func loadProgressContext(context: ModelContext) {
        Task {
            do {
                // fetch progress from Firestore
                self.progress = try await FirestoreManager.shared.fetchDocuments(collection: collectionName)
            } catch {
                print("Failed to fetch progress from Firestore: \(error.localizedDescription)")
            }
            
            // TODO: Move this update swiftdata
            // update local swiftdata using progress data
            do {
                for p in progress {
                    let temp = ExerciseModel(from: p)
                    context.insert(temp)
                }
                try context.save()
            } catch {
                print("Failed to update exercise swiftdata: \(error.localizedDescription)")
            }
        }
    }
    
    func updateExerciseProgress(exercise: Exercise) {
        do {
            try FirestoreManager.shared.saveDocument(data: exercise, collection: collectionName, id: String(exercise.id))
        } catch {
            print("Failed to save progress: \(error.localizedDescription)")
        }
    }
}
