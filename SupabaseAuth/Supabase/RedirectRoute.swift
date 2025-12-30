//
//  RedirectRoute.swift
//  SupabaseAuth
//
//  Created by Itsuki on 2025/12/30.
//

import Foundation

enum RedirectRoute: String {
    case login
    case reset

    private static let baseURL =
        "\(Bundle.main.bundleIdentifier, default: "itsuki.enjoy.SupabaseAuth")://"

    var url: URL? {
        return URL(string: "\(Self.baseURL)\(self.rawValue)")
    }

    init?(url: URL) {
        guard let host = url.host() else {
            return nil
        }
        guard let route = Self.init(rawValue: host) else {
            return nil
        }

        self = route
    }
}
