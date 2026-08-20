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
    @State var skipSignIn: Bool = false
    
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
                if authService.authenticationState == .authenticated || skipSignIn {
                    MainTabView()
                } else {
                    Button("Sign In / Sign up") { authService.isPresented = true }
                    Button("Skip Sign In") { skipSignIn = true }
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
        .environment(ExerciseProgressManager())
        .modelContainer(previewContainer)
}
