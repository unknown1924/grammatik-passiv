//
//  StreakView.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 22/04/26.
//

import SwiftUI

// TODO: storing all the streak dates is a bit too complex, instead just store the current streak, one INT
struct StreakView: View {
    @State var dates: Set<DateComponents> = []
    @State var userStreakDates: [Int] = [19,21,28]
    @State var enableUserInteraction: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            MultiDatePicker("My Streak", selection: $dates)
                .tint(.orange)
                .padding(.horizontal)
                .overlay {
                    if !enableUserInteraction {
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            .background(Color.green.opacity(0.05))
                            .cornerRadius(26)
                            .offset(y: 25)
                            .frame(maxHeight: 280)
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
            let dateComponent = DateComponents(year: 2026, month: 6, day: streakDay)
            range.insert(dateComponent)
        }
        return range
    }
}

#Preview {
    StreakView()
}
