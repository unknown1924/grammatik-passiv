//
//  ExamQuestionView.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 05/04/26.
//

import SwiftUI
import SwiftData

// MARK: - Main Exam View
struct ExamQuestionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    
    @State var currentTopicName: String = "Questions"
    @State var currentTopicId: Int = 0
    @Query(sort: \ExamModel.id) var exams: [ExamModel]
    @Query var exercise: [ExerciseModel]
    @State var correctStatus: Bool = false
    @State var answerStatus: Bool = false

    // Internal state
    @State private var currentIndex: Int = 0
    @State private var selectedOption: Int? = nil
    @State private var showSheet: Bool = false

    init(currentTopicId: Int) {
        _currentTopicId = State(initialValue: currentTopicId)
        
        let filter = #Predicate<ExamModel> { exam in
            exam.examId == currentTopicId
        }
        
        let exfilter = #Predicate<ExerciseModel> { ex in
            ex.id == currentTopicId
        }
        
        _exams = Query(filter: filter, sort: \ExamModel.id)
        _exercise = Query(filter: exfilter)
    }
    
    private var currentExam: ExamModel? {
        guard currentIndex < exams.count else { return nil }
        return exams[currentIndex]
    }

    private var progress: Double {
        guard !exams.isEmpty else { return 0 }
        return Double(currentIndex) / Double(exams.count)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            // MARK: Main Content
            VStack(spacing: 0) {
                // Top bar
                topBar

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        if let exam = currentExam {
                            if let desc = exam.questionDescription, !desc.isEmpty {
                                Text(desc)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 20)
                            }

                            // Question card
                            questionCard(exam: exam)

                            // Options
                            optionsGrid(exam: exam)
                        } else {
                            completionView
                        }
                    }
                    .padding(.top, 24)
                    .padding(.bottom, showSheet ? 280 : 40)
                }
            }

            // MARK: Answer Bottom Sheet
            if showSheet, let exam = currentExam {
                answerSheet(exam: exam)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.82), value: showSheet)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: selectedOption)
        .navigationBarHidden(true)
        .onAppear {
            Task {
                // MARK: Implement Loading spinner
                DatabaseManager.seedExamData(context: context)
            }
        }
    }

    private var topBar: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 36, height: 36)
                        .background(Color(.systemGray5), in: Circle())
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemGray5))
                            .frame(height: 10)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.green, Color.green.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(10, geo.size.width * progress), height: 10)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                    }
                }
                .frame(height: 10)

                // Counter
                Text("\(currentIndex)/\(exams.count)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Question Card
    private func questionCard(exam: ExamModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if exam.status {
                Text("You've already attempted this question.")
            }
            if exercise.count >= 1 {
                Text("Exercise ID: \(exercise[0].id)")
            }
            Label("\(currentIndex + 1)", systemImage: "questionmark.circle.fill")
//            Text("Question \(currentIndex + 1)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 5)
                .padding(.vertical, 5)
                .padding(.trailing, 5)
                .background(Color.indigo, in: Capsule())

            Text(exam.question)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }

    private func optionsGrid(exam: ExamModel) -> some View {
        let options = buildOptions(exam)
        // show here 1 column immer
        let columns = options.count == 5
            ? [GridItem(.flexible()), GridItem(.flexible())]
            : [GridItem(.flexible())]

        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                OptionCell(
                    text: option,
                    optionIndex: index + 1,
                    selectedOption: selectedOption,
                    correctAnswer: exam.answer,
                    isRevealed: showSheet
                ) {
                    guard !showSheet else { return }
                    selectedOption = index + 1
                    let isCorrect = (index + 1) == exam.answer
                    correctStatus = isCorrect
                    answerStatus = true
                    withAnimation { showSheet = true }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func buildOptions(_ exam: ExamModel) -> [String] {
        var opts = [exam.option1, exam.option2]
        if let o3 = exam.option3 { opts.append(o3) }
        if let o4 = exam.option4 { opts.append(o4) }
        return opts
    }

    // MARK: - Answer Sheet
    private func answerSheet(exam: ExamModel) -> some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 16)

            VStack(alignment: .leading, spacing: 16) {
                // Result header
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(correctStatus ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: correctStatus ? "checkmark" : "xmark")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(correctStatus ? .green : .red)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(correctStatus ? "Richtig!" : "Falsch")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(correctStatus ? .green : .red)
                        if !correctStatus, let answer = optionText(exam: exam, for: exam.answer) {
                            Text("Richtige Antwort: \(answer)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }

                // Explanation
                if let explanation = exam.explanation, !explanation.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Erklärung")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .kerning(0.5)

                        Text(explanation)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.primary.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.systemGray6))
                    )
                }

                // Action buttons
                HStack(spacing: 12) {
                    if !correctStatus {
                        Button {
                            withAnimation {
                                showSheet = false
                                selectedOption = nil
                                answerStatus = false
                                correctStatus = false
                            }
                        } label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.red.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .strokeBorder(Color.red.opacity(0.25), lineWidth: 1.5)
                                        )
                                )
                        }
                    }

                    Button {
                        advanceToNext()
                        exam.status = true
                    } label: {
                        Text(correctStatus ? "Continue" : "Skip")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(correctStatus ? Color.green : Color.indigo)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.12), radius: 24, x: 0, y: -8)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var completionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)
                .symbolEffect(.bounce, value: currentIndex)

            Text("All Done!")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("You've completed all questions in \(currentTopicName).")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.glassProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .onAppear {
            if exercise.count >= 1 {
                exercise[0].status = true
            }
        }
    }

    // MARK: - Helpers
    private func optionText(exam: ExamModel, for index: Int) -> String? {
        switch index {
        case 1: return exam.option1
        case 2: return exam.option2
        case 3: return exam.option3
        case 4: return exam.option4
        default: return nil
        }
    }

    private func advanceToNext() {
        withAnimation {
            showSheet = false
            selectedOption = nil
            answerStatus = false
            correctStatus = false
            if currentIndex < exams.count {
                currentIndex += 1
            }
        }
    }
}

struct OptionCell: View {
    let text: String
    let optionIndex: Int
    let selectedOption: Int?
    let correctAnswer: Int
    let isRevealed: Bool
    let onTap: () -> Void

    private var isSelected: Bool { selectedOption == optionIndex }

    private var cellState: CellState {
        if !isRevealed || selectedOption == nil { return isSelected ? .selected : .idle }
        if optionIndex == correctAnswer { return .correct }
        if isSelected { return .wrong }
        return .idle
    }

    enum CellState {
        case idle, selected, correct, wrong
    }

    private var backgroundColor: Color {
        switch cellState {
        case .idle:     return Color(.systemBackground)
        case .selected: return Color.indigo.opacity(0.1)
        case .correct:  return Color.green.opacity(0.1)
        case .wrong:    return Color.red.opacity(0.1)
        }
    }

    private var borderColor: Color {
        switch cellState {
        case .idle:     return Color(.systemGray4)
        case .selected: return Color.indigo
        case .correct:  return Color.green
        case .wrong:    return Color.red
        }
    }

    private var labelColors: (bg: Color, fg: Color) {
        switch cellState {
        case .idle:     return (Color(.systemGray5), Color.secondary)
        case .selected: return (Color.indigo, .white)
        case .correct:  return (Color.green, .white)
        case .wrong:    return (Color.red, .white)
        }
    }

    private var optionLabel: String {
        ["A", "B", "C", "D"][optionIndex - 1]
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Letter badge
                Text(optionLabel)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(labelColors.fg)
                    .frame(width: 28, height: 28)
                    .background(labelColors.bg, in: Circle())

                Text(text)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

                if isRevealed {
                    if cellState == .correct {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.green)
                    } else if cellState == .wrong {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.red)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: isSelected || isRevealed ? 2 : 1.5)
            )
            .shadow(
                color: isSelected ? borderColor.opacity(0.2) : .clear,
                radius: 8, x: 0, y: 4
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 0.97 : 1.0)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ExamQuestionView(currentTopicId: 7)
    }
    .modelContainer(for: [ExamModel.self])
}
