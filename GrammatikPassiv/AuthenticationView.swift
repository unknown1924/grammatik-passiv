//
//  AuthenticationView.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 23/07/26.
//

import FirebaseAuthSwiftUI
import FirebaseGoogleSwiftUI
import SwiftData
import SwiftUI

struct AuthenticationView: View {
    let authService: AuthService
    init() {
        // Configure it to support Email/Password
        let configuration = AuthConfiguration()
        authService = AuthService(configuration: configuration)
            .withEmailSignIn()
            .withGoogleSignIn()
    }

    var body: some View {
        AuthPickerView {
            // TODO: create a new View/swift file for authentication. Keep authentication logic separate.
            authenticatedContent
        }
        .environment(authService)
    }

    var authenticatedContent: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if authService.authenticationState == .authenticated {

                    // TODO: Move this account management to a profiles page
                    HStack {
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
                    }

                    MainTabView()
                } else {
                    Button("Sign In") {
                        authService.isPresented = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Grammatik Passiv")
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
    AuthenticationView()
        .modelContainer(
            for: [
                TopicModel.self,
                LevelsModel.self,
                ExerciseModel.self,
                ExamModel.self,
            ]
        )
}
