//
//  ContentView.swift
//  HotProspects
//
//  Created by Henrieke Baunack on 1/31/24.
//

import SwiftUI

// here we are gonna store out tabView that is referencing our other views
struct ContentView: View {
    @State var sortOrder = [SortDescriptor(\Prospect.name)]
    var body: some View {
        TabView{
            ProspectsView(filter: .none, sortOrder: [SortDescriptor(\Prospect.name)])
                .tabItem {
                    Label("Everyone", systemImage: "person.3")
                }
            NavigationStack{
                ProspectsView(filter: .contacted, sortOrder: sortOrder)
                    .toolbar {
                        Menu("Filter", systemImage: "arrow.up.arrow.down"){
                            Picker("Pick filter", selection: $sortOrder){
                                Text("By Name")
                                    .tag([SortDescriptor(\Prospect.name)])
                                Text("By Last Contacted")
                                    .tag([SortDescriptor(\Prospect.lastContacted)])
                                
                            }
                        }
                    }
            }.tabItem {
                Label("Contacted", systemImage: "checkmark.circle")
            }
            ProspectsView(filter: .uncontacted, sortOrder: [SortDescriptor(\Prospect.name)])
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
