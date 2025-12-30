//
//  LoginView.swift
//  SupabaseAuth
//
//  Created by Itsuki on 2025/12/30.
//

import SwiftUI

struct LoginView: View {
    @Environment(SupabaseManager.self) private var supabaseManager

    @State private var error: Error?
    @State private var confirmationNeededMessage: String? = nil

    @State private var loadingMessage: String? = nil
    @State private var entrySheetConfig: EmailPasswordEntrySheet.Config? = nil

    var body: some View {
        @Bindable var supabaseManager = supabaseManager

        List {
            if let confirmationNeededMessage {
                Text(confirmationNeededMessage)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.secondary)
                    .task {
                        try? await Task.sleep(for: .seconds(2))
                        self.confirmationNeededMessage = nil
                    }
            }

            Section {
                Button(
                    action: {
                        self.entrySheetConfig = .init(
                            title: "Sign Up",
                            button: "Sign Up",
                            showPasswordEntry: true,
                            onConfirm: { email, password in
                                try await supabaseManager.signUp(
                                    email: email,
                                    password: password
                                )
                                try? await Task.sleep(for: .milliseconds(10))
                                // session is nil -> email confirmation needed
                                if self.supabaseManager.session == nil {
                                    self.confirmationNeededMessage =
                                        "Please confirm your email to finish sign up."
                                }
                            }
                        )
                    },
                    label: {
                        Text("Sign up")
                    }
                )

                Button(
                    action: {
                        self.entrySheetConfig = .init(
                            title: "Resend Confirmation Email",
                            button: "Resend Confirmation Email",
                            showPasswordEntry: false,
                            onConfirm: { email, _ in
                                try await supabaseManager
                                    .resendConfirmationEmail(email: email)
                                if self.supabaseManager.session == nil {
                                    self.confirmationNeededMessage =
                                        "Email resend successfully. Please confirm your email to finish sign up."
                                }

                            }
                        )

                    },
                    label: {
                        Text("Resend confirmation email")
                    }
                )

            }
            Section {
                Button(
                    action: {
                        self.entrySheetConfig = .init(
                            title: "Sign In",
                            button: "Sign In",
                            showPasswordEntry: true,
                            onConfirm: { email, password in
                                try await supabaseManager.signIn(
                                    email: email,
                                    password: password
                                )
                            }
                        )
                    },
                    label: {
                        Text("Sign in with password")
                    }
                )

                Button(
                    action: {
                        self.entrySheetConfig = .init(
                            title: "Sign In",
                            button: "Sign In With Magic Link",
                            showPasswordEntry: false,
                            onConfirm: { email, _ in
                                try await supabaseManager.signInWithMagicLink(
                                    email: email
                                )
                            }
                        )

                    },
                    label: {
                        Text("Sign in with magic link")
                    }
                )
            }

            Section {
                Button(
                    action: {
                        self.entrySheetConfig = .init(
                            title: "Reset Password",
                            button: "Send Reset Password Email",
                            showPasswordEntry: false,
                            onConfirm: { email, _ in
                                try await supabaseManager.sendResetPasswordEmail(
                                    email: email
                                )
                                self.confirmationNeededMessage =
                                    "Password reset email sent successfully. Please Check your email for the reset link"
                            }
                        )
                    },
                    label: {
                        Text("Send reset password mail")
                    }
                )
            }

        }
        .contentMargins(.top, 16)
        .navigationTitle("Auth Yourself")
        #if !os(macOS)
            .navigationBarTitleDisplayMode(.large)
        #endif
        .onOpenURL(perform: { url in
            Task {
                self.loadingMessage = "Processing Callback..."
                do {
                    try await supabaseManager.onOpenURL(url)
                } catch (let error) {
                    self.error = error
                }
                self.loadingMessage = nil
            }
        })
        .navigationDestination(
            item: $supabaseManager.session,
            destination: { session in
                PrivateView(session: session)
                    .environment(supabaseManager)
            }
        )
        .sheet(
            item: $entrySheetConfig,
            content: { config in
                EmailPasswordEntrySheet(config: config)
            }
        )
        .overlay {
            if let loadingMessage {
                ProgressView(loadingMessage)
                    .controlSize(.extraLarge)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.gray.opacity(0.7))
            }
        }

    }

}
