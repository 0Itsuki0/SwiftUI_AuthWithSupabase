//
//  SupabaseAuthApp.swift
//  SupabaseAuth
//
//  Created by Itsuki on 2025/12/29.
//

import SwiftUI

@main
struct SupabaseAuthApp: App {
    var body: some Scene {
        
        #if os(macOS)
        Window("contentView", id: "contentView", content: {
            ContentView()
        })
        #else
        
        WindowGroup {
            ContentView()
        }
        #endif
        
        
    }
}
