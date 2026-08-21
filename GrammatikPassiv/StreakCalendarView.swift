//
//  StreakCalendarView.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 26/07/26.
//

import SwiftUI
import SwiftData
import FirebaseFirestore

// MARK: - Streak Calendar View

struct StreakCalendarView: View {
    @Environment(\.modelContext) private var context
    @Environment(ExerciseProgressManager.self) var progressManager
    @Query(sort: \DailyActivityModel.dateKey) var dailyActivity: [DailyActivityModel]
    @Query(sort: \StreakSummaryModel.currentStreak) var streakSummary: [StreakSummaryModel]
    /// Any date within the month you want to display (day component is ignored).
    let month: Date = .now
    /// Set of "yyyy-MM-dd" keys that had activity — O(1) lookup per cell.
    var activityDates: Set<String> = Set<String>()
    
    @State var enteredDate: String = "1"

    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1 // 1 = Sunday. Set to 2 for Monday-first if you prefer.
        return cal
    }()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            summary
            
            monthHeader

            weekdayHeader

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(daysInMonth().enumerated()), id: \.offset) { _, day in
                    dayCell(for: day)
                }
            }
        }
        .padding()
        .task {
            progressManager.fetchDailyActivityProgress(context: context)
            progressManager.fetchStreakSummary(context: context)
        }
    }

    // MARK: Header

    private var monthHeader: some View {
        Text(month, format: .dateTime.month(.wide).year())
            .font(.title3.bold())
    }

    private var weekdayHeader: some View {
        let symbols = calendar.veryShortWeekdaySymbols // e.g. ["S","M","T","W","T","F","S"]
        // Rotate the symbols to match firstWeekday, same as we do for the day grid.
        let rotated = rotate(symbols, by: calendar.firstWeekday - 1)
        return HStack {
            ForEach(rotated, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: Day cell

    @ViewBuilder
    private func dayCell(for date: Date?) -> some View {
        if let date {
            // DailyActivityModel.formatter is a static property, so this call is
            // identical whether DailyActivityModel is a struct or a class — no
            // change needed here even though the model type changed above.
            let key = DailyActivityModel.formatter.string(from: date)
            @State var isActive = Set(dailyActivity.map(\.dateKey)).contains(key)
            let isToday = calendar.isDateInToday(date)

            VStack(spacing: 4) {
                Text(date, format: .dateTime.day())
                    .font(.caption2)
                    .foregroundStyle(isToday ? Color.orange : .secondary)

                ZStack {
                    Circle()
                        .fill(isActive ? Color.orange.opacity(0.15) : Color.clear)
                        .frame(width: 30, height: 30)

                    Image(systemName: isActive ? "flame.fill" : "circle.fill")
                        .font(.system(size: isActive ? 15 : 6))
                        .foregroundStyle(isActive ? Color.orange : Color.gray.opacity(0.3))
                }
                .overlay(
                    Circle()
                        .stroke(isToday ? Color.orange : Color.clear, lineWidth: 1.5)
                        .frame(width: 30, height: 30)
                )
            }
            .frame(maxWidth: .infinity)
        } else {
            // Empty leading/trailing cell to keep grid alignment
            Color.clear
                .frame(maxWidth: .infinity, minHeight: 44)
        }
    }
    
    private var summary: some View {
        VStack {
            HStack {
                
                Label("Current", systemImage: "bolt.circle")
                Text(String(streakSummary.first?.currentStreak ?? 0))
                
                Spacer()
                
                Label("Longest", systemImage: "trophy.circle")
                Text(String(streakSummary.first?.longestStreak ?? 0))
                
//                Text("updated:")
//                Text(String(streakSummary.first?.updatedAt.formatted() ?? "Never"))
            }
            // TODO: Clean up
//            HStack {
//                TextField("enter date", text: $enteredDate)
//                Button("add") {
//                    guard let firstOfMonth = calendar.dateInterval(of: .month, for: .now)?.start else { return }
//                    context.insert(DailyActivityModel(date: calendar.date(byAdding: .day, value: (Int(enteredDate) ?? -1) - 1, to: firstOfMonth)!))
//                    do {
//                        try context.save()
//                    } catch {
//                        print(error)
//                    }
//                }
//                Button("reset") {
//                    try? context.delete(model: DailyActivityModel.self)
//                    try? context.delete(model: StreakSummaryModel.self)
////                    try? context.save()
//                }
//            }
        }
    }

    // MARK: - daysInMonth()

    /// Returns an array representing every cell in the calendar grid for `month`,
    /// including leading `nil`s so the 1st lands on the correct weekday column,
    /// and trailing `nil`s to complete the final week row.
    private func daysInMonth() -> [Date?] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: month),
            let firstDayRange = calendar.range(of: .day, in: .month, for: month)
        else {
            return []
        }

        let firstOfMonth = monthInterval.start
        let numberOfDaysInMonth = firstDayRange.count

        // weekday of the 1st: 1...7 depending on calendar (Sunday = 1 by default)
        let firstWeekdayOfMonth = calendar.component(.weekday, from: firstOfMonth)

        // How many empty cells to pad before day 1, adjusted for calendar.firstWeekday
        let leadingEmptyCells = (firstWeekdayOfMonth - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: leadingEmptyCells)

        for dayOffset in 0..<numberOfDaysInMonth {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: firstOfMonth) {
                days.append(date)
            }
        }

        // Pad trailing cells so the grid always completes full weeks (multiple of 7)
        let remainder = days.count % 7
        if remainder != 0 {
            days.append(contentsOf: Array(repeating: nil, count: 7 - remainder))
        }

        return days
    }

    private func rotate<T>(_ array: [T], by offset: Int) -> [T] {
        guard !array.isEmpty else { return array }
        let normalizedOffset = ((offset % array.count) + array.count) % array.count
        return Array(array[normalizedOffset...] + array[..<normalizedOffset])
    }
}

#Preview("Current streak: 12 days") {
    StreakCalendarView()
    .environment(ExerciseProgressManager())
    .modelContainer(previewContainer)
}
