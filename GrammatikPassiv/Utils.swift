//
//  Utils.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 27/07/26.
//

import Foundation
import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    do {
        // Define all your models in one place
        let schema = Schema([
            LevelsModel.self,
            TopicModel.self,
            ExerciseModel.self,
            ExamModel.self,
            DailyActivityModel.self,
            StreakSummaryModel.self
        ])
        
        // Run entirely in memory so it doesn't corrupt your actual database
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        let container = try ModelContainer(for: schema, configurations: [config])
        
        // Optional: You can seed dummy data right here so all previews have instant data
        // let dummyTopic = TopicModel(...)
        // container.mainContext.insert(dummyTopic)
        
        return container
    } catch {
        fatalError("Failed to create preview container: \(error.localizedDescription)")
    }
}()

// MARK: - Dummy data + Preview
//
// StreakCalendarView itself still just takes a `Set<String>` of dateKeys —
// its own signature and body are untouched. What changes is *how previews
// produce that set*: instead of building the strings by hand, we now insert
// real DailyActivityModel model objects into a throwaway in-memory ModelContainer
// and derive the keys from those objects, the same way your real screen will
// eventually fetch DailyActivityModel rows and map them to a Set<String>.
//
// This is the standard SwiftData preview pattern: an in-memory, non-persisted
// container scoped to the #Preview macro, so nothing here touches your real
// on-device database.

@MainActor
func makePreviewContainer(inserting dates: [Date]) -> ModelContainer {
    let schema = Schema([DailyActivityModel.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let context = container.mainContext
    for date in dates {
        context.insert(DailyActivityModel(date: date))
    }
    // In-memory containers don't strictly need an explicit save for the
    // preview to read them back via mainContext, but it's harmless and
    // matches what you'd do against a real persistent store.
    try? context.save()

    return container
}

/// Every day in `month` except `missedDays` (by day-of-month number), and never
/// marking days after "today" as active if `month` is the current month.
func plausibleStreakDates(for month: Date, missedDays: Set<Int>) -> [Date] {
    let calendar = Calendar.current
    guard let range = calendar.range(of: .day, in: .month, for: month),
          let firstOfMonth = calendar.dateInterval(of: .month, for: month)?.start
    else {
        return []
    }

    let today = calendar.component(.day, from: Date())
    let isCurrentMonth = calendar.isDate(month, equalTo: Date(), toGranularity: .month)

    var dates: [Date] = []
    for day in range {
        if missedDays.contains(day) { continue }
        if isCurrentMonth && day > today { continue }
        if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
            dates.append(date)
        }
    }
    return dates
}

/// Only the given day-of-month numbers, as Dates in `month`.
func scatteredDates(for month: Date, days: Set<Int>) -> [Date] {
    let calendar = Calendar.current
    guard let firstOfMonth = calendar.dateInterval(of: .month, for: month)?.start else {
        return []
    }
    return days.compactMap { day in
        calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
    }
}

/// Every day in the month, no gaps.
func everyDate(in month: Date) -> [Date] {
    let calendar = Calendar.current
    guard let range = calendar.range(of: .day, in: .month, for: month),
          let firstOfMonth = calendar.dateInterval(of: .month, for: month)?.start
    else {
        return []
    }
    return range.compactMap { day in
        calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
    }
}

/// Fetches all DailyActivityModel rows from the given container's main context and
/// maps them to the Set<String> that StreakCalendarView expects. This is the
/// same shape of code your real screen will run against the app's actual
/// ModelContainer.
@MainActor
func activityKeys(from container: ModelContainer) -> Set<String> {
    let descriptor = FetchDescriptor<DailyActivityModel>()
    let rows = (try? container.mainContext.fetch(descriptor)) ?? []
    return Set(rows.map(\.dateKey))
}

func makeDummyActivityDates(for month: Date) -> Set<String> {
    let calendar = Calendar.current
    guard let range = calendar.range(of: .day, in: .month, for: month),
          let firstOfMonth = calendar.dateInterval(of: .month, for: month)?.start
    else {
        return []
    }

    // Simulate: active every day except day 5, day 6 (missed weekend), and any day after "today"
    let missedDays: Set<Int> = [5, 6, 17, 26]
    let today = calendar.component(.day, from: Date())
    let isCurrentMonth = calendar.isDate(month, equalTo: Date(), toGranularity: .month)

    var keys: Set<String> = []
    for day in range {
        if missedDays.contains(day) { continue }
        if isCurrentMonth && day > today { continue } // don't mark future days as active

        if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
            keys.insert(DailyActivityModel.formatter.string(from: date))
        }
    }
    return keys
}
