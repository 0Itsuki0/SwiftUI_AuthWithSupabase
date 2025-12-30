//
//  PrivateView.swift
//  SupabaseAuth
//
//  Created by Itsuki on 2025/12/30.
//

import SwiftUI
import Supabase


struct PrivateView: View {
    @Environment(SupabaseManager.self) private var supabaseManager

    var session: Session

    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false

    var body: some View {
        @Bindable var supabaseManager = supabaseManager
        let user = session.user

        List {

            Section("User Info") {
                row("ID", user.id.uuidString)
                if let email = user.email {
                    row("Email", email)
                }
                row("Create At", user.createdAt.formatted())
                if let lastSignInAt = user.lastSignInAt {
                    row("Last Sign In At", lastSignInAt.formatted())
                }
            }

            Section {

                Button(
                    action: {
                        supabaseManager.showResetPasswordView = true
                    },
                    label: {
                        Text("Change Password")
                    }
                )

                Button(
                    action: {
                        Task {
                            self.isLoading = true
                            do {
                                try await supabaseManager.signOut()
                            } catch (let error) {
                                self.errorMessage = error.localizedDescription
                            }
                            self.isLoading = false
                        }
                    },
                    label: {
                        Text("Sign Out")
                    }
                )

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .listRowBackground(Color.clear)
                }

            }
        }
        .navigationTitle("Your Private World!")
        .navigationBarBackButtonHidden()
        .sheet(
            isPresented: $supabaseManager.showResetPasswordView,
            content: {
                EmailPasswordEntrySheet(
                    config: .init(
                        title: "Update Password",
                        button: "Update Password",
                        showPasswordEntry: true,
                        onConfirm: { _, password in
                            try await self.supabaseManager.updatePassword(
                                newPassword: password
                            )
                        }
                    )
                )
            }
        )
        .overlay {
            if self.isLoading {
                ProgressView()
                    .controlSize(.extraLarge)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.gray.opacity(0.7))
            }
        }

    }

    @ViewBuilder
    private func row(_ left: String, _ right: String) -> some View {
        HStack {
            Text(left)
                .fontWeight(.semibold)
                .lineLimit(1)

            Spacer()

            Text(right)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

        }
    }
}
