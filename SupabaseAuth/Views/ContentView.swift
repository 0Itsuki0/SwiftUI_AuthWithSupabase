//
//  ContentView.swift
//  SupabaseAuth
//
//  Created by Itsuki on 2025/12/29.
//

import SwiftUI

struct ContentView: View {
    @State private var supabaseManager: SupabaseManager? =
        try? SupabaseManager()

    var body: some View {
        NavigationStack {
            Group {
                if let supabaseManager = self.supabaseManager {
                    LoginView()
                        .environment(supabaseManager)
                } else {
                    ContentUnavailableView(
                        "Supabase Config Missing",
                        systemImage: "slash.circle",
                        description: Text(
                            "Make sure to have `Supabase.plist` set up correctly."
                        )
                    )
                }
            }
        }
    }
}
