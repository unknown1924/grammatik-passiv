//
//  StreakView.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 22/04/26.
//

import SwiftUI

// TODO: depricated - remove this streak view - use StreakCalendarView
// MARK: storing all the streak dates is a bit too complex, instead just store the current streak, one INT
struct StreakView: View {
    @State var dates: Set<DateComponents> = []
    @State var userStreakDates: [Int] = [19,20, 21, 22, 23, 24, 25,26,28]
    @State var enableUserInteraction: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            MultiDatePicker("My Streak", selection: $dates)
                .tint(.green)
                .padding(.horizontal)
                .overlay {
                    if !enableUserInteraction {
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            .background(Color.green.opacity(0.05))
//                            .cornerRadius(26)
//                            .offset(y: 15)
//                            .frame(maxHeight: 280)
                    }
                }
            Spacer()
        }
        .frame(maxHeight: 350)
        .onAppear {
            dates = generateStreakRange(streakDays: userStreakDates)
        }
    }
    
    func generateStreakRange(streakDays: [Int]) -> Set<DateComponents> {
        var range: Set<DateComponents> = []
        for streakDay in streakDays {
            let dateComponent = DateComponents(year: 2026, month: 7, day: streakDay)
            range.insert(dateComponent)
        }
        return range
    }
}

#Preview {
    StreakView()
}
