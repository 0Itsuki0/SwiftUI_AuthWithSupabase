//
//  SupabaseManager.swift
//  SupabaseAuth
//
//  Created by Itsuki on 2025/12/29.
//

import Supabase
import SwiftUI

@Observable
class SupabaseManager {
    var showResetPasswordView: Bool = false

    var session: Session?

    private var loginRedirect: URL? = RedirectRoute.login.url

    // using a different one so that we can show the reset password view accordingly
    private var resetRedirect: URL? = RedirectRoute.reset.url

    private let supabase: SupabaseClient

    @ObservationIgnored
    private var authStateChangeTask: Task<Void, Error>?

    init() throws {
        guard let urlString = SupabaseConfig["SUPABASE_URL"],
            let url = URL(string: urlString),
            let key = SupabaseConfig["SUPABASE_ANON_KEY"]
        else {
            throw SupabaseError.missingSupabaseConfig
        }

        self.supabase = SupabaseClient(
            supabaseURL: url,
            supabaseKey: key,
            //    Initial session emitted after attempting to refresh the local stored session.
            //    This is incorrect behavior and will be fixed in the next major release since it's a breaking change.
            //    To opt-in to the new behavior now, set `emitLocalSessionAsInitialSession: true` in your AuthClient configuration.
            //    The new behavior ensures that the locally stored session is always emitted, regardless of its validity or expiration.
            //    If you rely on the initial session to opt users in, you need to add an additional check for `session.isExpired` in the session.
            options: .init(auth: .init(emitLocalSessionAsInitialSession: true))
        )

        self.setupListener()
    }

    deinit {
        self.authStateChangeTask?.cancel()
    }

    // set up auth state change listener to listen for any session updates.
    func setupListener() {
        self.authStateChangeTask = Task {
            // alternative with callback
            // await self.supabase.auth.onAuthStateChange({ event, session in   })

            for await (event, session) in self.supabase.auth.authStateChanges {
                guard !Task.isCancelled else {
                    break
                }
                print("auth state change for event: \(event)")

                // Note:
                // The session emitted in the `AuthChangeEvent/initialSession` event may have been expired since last launch, consider checking for `Session/isExpired`. If this is the case, then expect a `AuthChangeEvent/tokenRefreshed` after.
                if session?.isExpired == true {
                    continue
                }

                self.session = session

            }

        }
    }

    func onOpenURL(_ url: URL) async throws {
        guard let route = RedirectRoute(url: url) else {
            return
        }
        try await supabase.auth.session(from: url)

        switch route {
        case .login:
            break
        case .reset:
            // a little wait before session updated through the async sequence
            try? await Task.sleep(for: .milliseconds(10))
            self.showResetPasswordView = true
        }
    }

    func signUp(email: String, password: String) async throws {
        guard self.session == nil else { return }

        let response = try await supabase.auth.signUp(
            email: email,
            password: password,
            // By default, the redirect URL will be localhost:3000
            // make sure to set the redirect URL used here in the dashboard: https://supabase.com/dashboard/project/_/auth/url-configuration
            // reference:  https://supabase.com/docs/guides/auth/passwords?queryGroups=language&language=swift&queryGroups=flow&flow=implicit#signing-up-with-an-email-and-password
            redirectTo: self.loginRedirect
        )

        switch response {
        case .session(let session):
            print("sign up with success. \(session.user.id)")
        // we don't have to set session here because we have register for the listener
        // self.session = session
        case .user(let user):
            print("user created: \(user.id)")
            print("email confirmation needed")
        }
    }

    func resendConfirmationEmail(email: String) async throws {
        guard self.session == nil else { return }

        try await supabase.auth.resend(email: email, type: .signup)
    }

    func signIn(email: String, password: String) async throws {
        guard self.session == nil else { return }
        try await supabase.auth.signIn(
            email: email,
            password: password
        )
    }

    func signInWithMagicLink(email: String) async throws {
        guard self.session == nil else { return }

        try await supabase.auth.signInWithOTP(
            email: email,
            redirectTo: self.loginRedirect
        )
    }

    func sendResetPasswordEmail(email: String) async throws {
        guard self.session == nil else { return }

        try await supabase.auth.resetPasswordForEmail(
            email,
            redirectTo: self.resetRedirect
        )
    }

    func updatePassword(newPassword: String) async throws {
        guard self.session != nil else { return }

        let _ = try await supabase.auth.update(
            user: UserAttributes(password: newPassword)
        )
    }

    func signOut() async throws {
        guard self.session != nil else { return }

        try await supabase.auth.signOut()
    }
}
