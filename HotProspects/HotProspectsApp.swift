//
//  HotProspectsApp.swift
//  HotProspects
//
//  Created by Henrieke Baunack on 1/31/24.
//

import SwiftUI
import SwiftData

@main
struct HotProspectsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(for: Prospect.self)
    }
}
