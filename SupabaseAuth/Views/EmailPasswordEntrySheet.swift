//
//  EmailPasswordEntrySheet.swift
//  SupabaseAuth
//
//  Created by Itsuki on 2025/12/30.
//

import SwiftUI

struct EmailPasswordEntrySheet: View {
    struct Config: Identifiable {
        let id: UUID = UUID()

        var title: String
        var button: String
        var showEmailEntry: Bool = true
        var showPasswordEntry: Bool
        var onConfirm:
            (_ email: String, _ password: String) async throws -> Void

    }

    var config: Config

    @State private var email: String = "itsuki.enjoy@gmail.com"
    @State private var password: String = "123456"
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let title = config.title
        let button = config.button
        let showPasswordEntry = config.showPasswordEntry
        let showEmailEntry = config.showEmailEntry
        let onConfirm = config.onConfirm

        NavigationStack {
            Form {
                Section {
                    if showEmailEntry {
                        TextField(
                            text: $email,
                            label: {
                                Text("Email")
                            }
                        )
                        .autocorrectionDisabled()
                        #if !os(macOS)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        #endif

                    }

                    if showPasswordEntry {
                        SecureField(
                            text: $password,
                            label: {
                                Text("Password")
                            }
                        )

                    }

                }

                Section {

                    Button(
                        action: {
                            Task {
                                self.isLoading = true

                                do {
                                    try await onConfirm(email, password)
                                    self.dismiss()
                                } catch (let error) {
                                    self.errorMessage =
                                        error.localizedDescription
                                }

                                self.isLoading = false
                            }

                        },
                        label: {
                            Text(button)
                                .padding(.vertical, 8)
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity
                                )
                        }
                    )
                    .buttonStyle(.borderedProminent)
                    .disabled(!enableButton)
                    .listRowBackground(Color.clear)
                    .listRowInsets(.all, 0)
                    .listRowSeparator(.hidden)

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .listRowBackground(Color.clear)
                    }

                }

            }
            .contentMargins(.top, 16)
            .navigationTitle(title)
            #if !os(macOS)
                .navigationBarTitleDisplayMode(.large)
            #endif
            .overlay(content: {
                if self.isLoading {
                    ProgressView()
                        .controlSize(.extraLarge)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.gray.opacity(0.7))
                }
            })
            .toolbar(content: {
                ToolbarItem(
                    placement: .topBarTrailing,
                    content: {
                        Button(
                            action: {
                                self.dismiss()
                            },
                            label: {
                                Image(systemName: "xmark")
                            }
                        )
                        .buttonStyle(.glassProminent)

                    }
                )
            })
            .presentationDetents([.medium])

        }

    }

    private var enableButton: Bool {
        let isEmailEmpty = email.trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
        let isPasswordEmpty = password.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty

        var enableButton = true

        switch (config.showEmailEntry, config.showPasswordEntry) {
        case (true, true):
            enableButton = !isPasswordEmpty && !isEmailEmpty

        case (false, false):
            break

        case (true, false):
            enableButton = !isEmailEmpty

        case (false, true):
            enableButton = !isPasswordEmpty
        }

        return enableButton
    }

}
