//
//  ProfileView.swift
//  GrammatikPassiv
//
//  Created by Debasis Mandal on 20/08/26.
//

import SwiftUI
import FirebaseAuthSwiftUI
import FirebaseGoogleSwiftUI

struct ProfileView: View {
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
            VStack {
                Button("Manage Account") { authService.isPresented = true }
                Button("Sign Out") { Task { try? await authService.signOut() } }
            }
        }
        .environment(authService)
    }
}

#Preview {
    ProfileView()
        .environment(ExerciseProgressManager())
}
