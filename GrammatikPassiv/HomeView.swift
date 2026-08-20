//
//  HomeView.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 17/04/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    // Automatically persists the user's first-time state
    @AppStorage("hasSelectedLevel") var hasSelectedLevel: Bool = true
    @AppStorage("userLevel") private var userLevel: String = ""
    @AppStorage("lastSavedExercise") var lastSavedExercise: String?
    
    @Query(sort: [SortDescriptor(\LevelsModel.id)]) var levels: [LevelsModel]
                                                                                          
    // TODO: Refactor this
    var body: some View {
        VStack {
            let _ = print("HomeView ---- App storage \\(hasSelectedLevel)")
            if !hasSelectedLevel {
                LevelSelectionView(hasSelectedLevel: $hasSelectedLevel, userLevel: $userLevel)
            } else {
                MainContentView(userLevel: userLevel)
                let _ = print("HomeView ---- App storage -- true \\(hasSelectedLevel)")
            }
        }
    }
}

// MARK: - Main Dashboard
struct MainContentView: View {
    var userLevel: String
    
    init(userLevel: String) {
        self.userLevel = userLevel
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // TODO: Remove StreakView()
//                    StreakView()
//                        .padding(.horizontal) // Add padding for better layout
                    StreakCalendarView()
                    
                    Divider()
                        .padding(.horizontal) // Add padding for better layout
                    
                    ContinueLearningCard(userLevel: userLevel)
                        .padding(.horizontal) // Add padding for better layout
                }
            }
            .navigationTitle("My Learning") // Changed title to be more general
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: TopicModel.self) { topic in
                ExerciseView(currentTopicId: topic.id, currentTopicName: topic.name)
            }
            .navigationDestination(for: ExerciseModel.self) { exercise in
                ExamQuestionView(currentTopicId: exercise.id)
            }
        }
    }
}

// MARK: - Continue Learning Card
struct ContinueLearningCard: View {
    var userLevel: String
    @AppStorage("lastSavedTopicName") private var lastSavedTopicName: String = "Introduction"
    @AppStorage("lastSavedExerciseNumber") private var lastSavedExerciseNumber: Int = 1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pick up where you left off")
                .font(.title2)
                .fontWeight(.semibold)
            
            NavigationLink(value: TopicModel(from: Topic(id: 1, name: lastSavedTopicName, status: false, levelID: 1, topicTheory: "Some theory"))) { // Placeholder TopicModel
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(lastSavedTopicName) • Exercise \(lastSavedExerciseNumber)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        Text("Continue Learning")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.forward.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.accentColor) // Using accentColor for Apple-like feel
                }
                .padding()
                .background(Color.accentColor.opacity(0.1)) // Using accentColor for Apple-like feel
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}


// MARK: - First Time Level Selection
struct LevelSelectionView: View {
    @State var path = NavigationPath()
    @Binding var hasSelectedLevel: Bool
    @Binding var userLevel: String
    
    let levels = ["A1", "A2", "B1", "B2"]
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 24) {
                Text("Willkommen!")
                    .font(.largeTitle)
                    .bold()
                
                Text("Choose your current German level to get started.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                ForEach(levels, id: \.self) { level in
                    NavigationLink(value: level) {
                        Button(action: {
                            userLevel = level
                            // Trigger the UI change to the dashboard
                            withAnimation {
                                hasSelectedLevel = true
                            }
                        }) {
                            Text(level)
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding(32)
                                .background(Color(.systemGray6))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 40)
        }
    }
}

#Preview {
    HomeView()
        .environment(ExerciseProgressManager())
        .modelContainer(previewContainer)
}
