//
//  DataModels.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 07/04/26.
//

import Foundation
import SwiftData


struct Levels: Identifiable, Hashable, Codable {
    var id: Int
    var name: String
    var status: Bool
    var levelDescription: String
    var mixedName: String
    
    enum CodingKeys: String, CodingKey {
        case id = "LevelID"
        case name = "LevelName"
        case status = "LevelStatus"
        case levelDescription = "LevelDescription"
        case mixedName = "LevelMixedName"
    }
}

@Model
final class LevelsModel {
    @Attribute(.unique) var id: Int
    var name: String
    var status: Bool
    var levelDescription: String
    var mixedName: String
    
    init(id: Int, name: String, status: Bool, levelDescription: String, mixedName: String) {
        self.id = id
        self.name = name
        self.status = status
        self.levelDescription = levelDescription
        self.mixedName = mixedName
    }
    
    convenience init(from level: Levels) {
        self.init(id: level.id, name: level.name, status: level.status, levelDescription: level.levelDescription, mixedName: level.mixedName)
    }
}

struct Topic: Identifiable, Hashable, Codable {
    var id: Int
    var name: String
    var status: Bool
    var levelID: Int
    var topicTheory: String
    
    enum CodingKeys: String, CodingKey {
        case id = "TopicID"
        case name = "TopicName"
        case status = "TopicStatus"
        case levelID = "LevelID"
        case topicTheory = "TopicTheory"
    }
}

@Model
final class TopicModel {
    @Attribute(.unique) var id: Int
    var name: String
    var status: Bool
    var levelID: Int
    var topicTheory: String
    
    init(id: Int, name: String, status: Bool, levelID: Int, topicTheory: String) {
        self.id = id
        self.name = name
        self.status = status
        self.levelID = levelID
        self.topicTheory = topicTheory
    }
    
    convenience init(from topic: Topic) {
        self.init(id: topic.id, name: topic.name, status: topic.status, levelID: topic.levelID, topicTheory: topic.topicTheory)
    }
}

struct Exercise: Identifiable, Hashable, Codable {
    var id: Int
    var name: String
    var status: Bool
    var topicId: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "ExamID"
        case name = "ExamName"
        case status = "ExamStatus"
        case topicId = "TopicID"
    }
}

@Model
final class ExerciseModel {
    @Attribute(.unique) var id: Int
    var name: String
    var status: Bool
    var topicId: Int
    
    init(id: Int, name: String, status: Bool, topicId: Int) {
        self.id = id
        self.name = name
        self.status = status
        self.topicId = topicId
    }
    
    convenience init(from exercise: Exercise) {
        self.init(id: exercise.id, name: exercise.name, status: exercise.status, topicId: exercise.topicId)
    }
}

struct Exam: Identifiable, Hashable, Codable {
    var id: Int
    var question: String
    var option1: String
    var option2: String
    var option3: String?
    var option4: String?
    var questionDescription: String?
    var explanation: String?
    var answer: Int
    var status: Bool
    var examId: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "ExerciseID"
        case question = "ExerciseQuestion"
        case option1 = "ExerciseOption1"
        case option2 = "ExerciseOption2"
        case option3 = "ExerciseOption3"
        case option4 = "ExerciseOption4"
        case questionDescription = "ExerciseRequirement"
        case explanation = "ExerciseExplanation"
        case answer = "ExerciseAnswer"
        case status = "ExerciseStatus"
        case examId = "ExamID"
    }
}

@Model
final class ExamModel {
    @Attribute(.unique) var id: Int
    var question: String
    var option1: String
    var option2: String
    var option3: String?
    var option4: String?
    var questionDescription: String?
    var explanation: String?
    var answer: Int
    var status: Bool
    var examId: Int
    
    init(id: Int, question: String, option1: String, option2: String, option3: String? = nil, option4: String? = nil, questionDescription: String? = nil, explanation: String? = nil, answer: Int, status: Bool, examId: Int) {
        self.id = id
        self.question = question
        self.option1 = option1
        self.option2 = option2
        self.option3 = option3
        self.option4 = option4
        self.questionDescription = questionDescription
        self.explanation = explanation
        self.answer = answer
        self.status = status
        self.examId = examId
    }
    
    convenience init(from data: Exam) {
        self.init(id: data.id, question: data.question, option1: data.option1, option2: data.option2, option3: data.option3, option4: data.option4, questionDescription: data.questionDescription, explanation: data.explanation, answer: data.answer, status: data.status, examId: data.examId)
    }
}

@Model
final class DailyActivityModel {
    // .unique enforces one row per calendar day at the persistence layer,
    // in addition to any "already logged today" check you do in code.
    @Attribute(.unique) var dateKey: String   // "yyyy-MM-dd", local-day-normalized
    var date: Date                             // start-of-day Date, for range queries
    var completedQuizCount: Int
    var isFreezeUsed: Bool
    var createdAt: Date

    init(date: Date, completedQuizCount: Int = 1, isFreezeUsed: Bool = false) {
        let normalized = Calendar.current.startOfDay(for: date)
        self.date = normalized
        self.dateKey = DailyActivityModel.formatter.string(from: normalized)
        self.completedQuizCount = completedQuizCount
        self.isFreezeUsed = isFreezeUsed
        self.createdAt = .now
    }

    static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.calendar = Calendar(identifier: .gregorian)
        return f
    }()
}

struct DailyActivity: Hashable, Identifiable, Codable {
    var id: Int
    var dateKey: String
    var date: Date
    var completedQuizCount: Int
    var isFreezeUsed: Bool
    var createdAt: Date
}

@Model
final class StreakSummaryModel {
    var currentStreak: Int
    var longestStreak: Int
    var lastActivityDateKey: String?
    var freezesAvailable: Int
    var updatedAt: Date

    init(currentStreak: Int = 0, longestStreak: Int = 0, freezesAvailable: Int = 0) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.freezesAvailable = freezesAvailable
        self.updatedAt = .now
    }
}

struct StreakSummary: Hashable, Identifiable, Codable {
    var id: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastActivityDateKey: String?
    var freezesAvailable: Int
    var updatedAt: Date}
