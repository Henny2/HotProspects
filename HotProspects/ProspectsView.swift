//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Henrieke Baunack on 2/3/24.
//
import CodeScanner
import SwiftData
import SwiftUI

struct ProspectsView: View {
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Prospect.name) var prospects: [Prospect]
    @State private var isShowingScanner = false
    @State private var selectedProspects = Set<Prospect>()
    let filter: FilterType
    var title: String {
        switch filter {
        case .none:
            "Everyone"
        case .contacted:
            "Contacted people"
        case .uncontacted:
            "Uncontacted people"
        }
    }
    var body: some View {
        NavigationStack{
            List(prospects, selection: $selectedProspects){ prospect in
                VStack(alignment:.leading){
                    Text(prospect.name)
                        .font(.headline)
                    
                    Text(prospect.emailAddress)
                        .foregroundStyle(.secondary)
                }
                .swipeActions{
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        modelContext.delete(prospect)
                    }
                    if prospect.isContacted {
                        Button("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark"){
                            prospect.isContacted.toggle()
                        }
                        .tint(.blue)
                    } else {
                        Button("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark"){
                            prospect.isContacted.toggle()
                        }
                    }
                }
                .tag(prospect) // making sure that this whole thing is being recognized as the prospect
            }
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing){
                        Button("Scan", systemImage: "qrcode.viewfinder"){
                            isShowingScanner = true
                        }
                    }
                    ToolbarItem(placement: .topBarLeading){
                        EditButton()
                    }
                    if selectedProspects.isEmpty == false {
                        ToolbarItem(placement: .bottomBar){
                            Button("Delete Selected", action: delete)
                        }
                    }
                }
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson \n paul@hackingWithSwift.com", completion: handleScan)
                }
        }
    }
    
    init(filter: FilterType){
        self.filter = filter
        
        if filter != .none {
            let showdContactedOnly = filter == .contacted
            
            _prospects = Query(filter: #Predicate{
                $0.isContacted == showdContactedOnly
            }, sort: [SortDescriptor(\Prospect.name)])
        }
    }
    
    func handleScan(result : Result<ScanResult, ScanError>){
        isShowingScanner = false
        // handling the data we found
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n") // string = what is inside the QR code
            guard details.count == 2 else {
                return // only proceed if you got two pieces of information here
            }
            let person = Prospect(name: details[0], emailAddress: details[1], isContacted: false)
            modelContext.insert(person)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func delete() {
        // loop over all prospects in the selected prospects and delete them
        for prospect in selectedProspects {
            modelContext.delete(prospect)
        }
    }
}

#Preview {
    ProspectsView(filter: .none)
        .modelContainer(for: Prospect.self)
}
