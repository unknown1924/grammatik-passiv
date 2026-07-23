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
            VStack {
                if authService.authenticationState == .authenticated {
                    MainTabView()
                } else {
                    Button("Sign In") { authService.isPresented = true }
                }
            }
            .onChange(of: authService.authenticationState) { _, newValue in
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
