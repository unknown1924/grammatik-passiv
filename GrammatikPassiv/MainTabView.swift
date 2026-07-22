//
//  HomeView.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 17/04/26.
//

import SwiftUI
import SwiftData
import FirebaseAuthSwiftUI
import FirebaseGoogleSwiftUI

struct MainTabView: View {
    let authService: AuthService
    init() {
        // Configure it to support Email/Password
        let configuration = AuthConfiguration()
        authService = AuthService(configuration: configuration)
            .withEmailSignIn()
            .withGoogleSignIn()
    }
    
    @State var path = NavigationPath()

    var body: some View {
        AuthPickerView {
            // TODO: create a new View/swift file for authentication. Keep authentication logic separate.
            authenticatedContent
        }
        .environment(authService)
    }
    
    var tabview: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            
            Tab("All Levels", systemImage: "chart.bar") {
                LevelView()
            }
            
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                SearchView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
    
    var authenticatedContent: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if authService.authenticationState == .authenticated {
                    Text("Authenticated")
                    
                    Button("Manage Account") {
                        authService.isPresented = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Sign Out") {
                        Task {
                            try? await authService.signOut()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    tabview
                } else {
                    Text("Not Authenticated")
                    
                    Button("Sign In") {
                        authService.isPresented = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("My App")
        }
        .onChange(of: authService.authenticationState) { _, newValue in
            // Automatically show auth UI when not authenticated
            if newValue != .authenticating {
                authService.isPresented = (newValue == .unauthenticated)
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [LevelsModel.self, TopicModel.self, ExerciseModel.self, ExamModel.self])
}
