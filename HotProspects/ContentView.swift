//
//  ContentView.swift
//  HotProspects
//
//  Created by Henrieke Baunack on 1/31/24.
//

import SwiftUI

// here we are gonna store out tabView that is referencing our other views
struct ContentView: View {
    var body: some View {
        TabView{
            ProspectsView(filter: .none)
                .tabItem {
                    Label("Everyone", systemImage: "person.3")
                }
            ProspectsView(filter: .contacted)
                .tabItem {
                    Label("Contacted", systemImage: "checkmark.circle")
                }
            ProspectsView(filter: .uncontacted)
                .tabItem {
                    Label("Uncontacted", systemImage: "questionmark.diamond")
                }
            MeView()
                .tabItem {
                    Label("Me", systemImage: "person.crop.square")
                }
        }
    }
}

#Preview {
    ContentView()
}
