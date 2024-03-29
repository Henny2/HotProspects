//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Henrieke Baunack on 2/3/24.
//
import CodeScanner
import SwiftData
import SwiftUI
import UserNotifications

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
                NavigationLink {
                    EditProspectView(prospect: prospect)
                } label: {
                    HStack{
                        VStack(alignment:.leading){
                            Text(prospect.name)
                                .font(.headline)
                            
                            Text(prospect.emailAddress)
                                .foregroundStyle(.secondary)
                            HStack{
                                Text((prospect.lastContacted != nil) ? "last contacted: \(prospect.lastContacted?.formatted() ?? "")" : "")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        if(filter == .none && prospect.isContacted){
                            Image(systemName: "person.crop.circle.fill.badge.checkmark")
                        }
                    }
                }
                .swipeActions{
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        modelContext.delete(prospect)
                    }
                    if prospect.isContacted {
                        Button("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark"){
                            prospect.isContacted.toggle()
                            prospect.lastContacted = nil
                        }
                        .tint(.blue)
                    } else {
                        Button("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark"){
                            prospect.isContacted.toggle()
                            prospect.lastContacted = Date()
                        }
                        .tint(.green)
                        
                        Button("Remind me", systemImage:"bell") {
                            addNotification(for: prospect)
                        }
                        .tint(.orange)
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
                    CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson \npaul@hackingWithSwift.com", completion: handleScan)
                }
        }
    }
    
    init(filter: FilterType, sortOrder: [SortDescriptor<Prospect>]){
        self.filter = filter
        
        if filter != .none {
            let showdContactedOnly = filter == .contacted
            
            _prospects = Query(filter: #Predicate{
                $0.isContacted == showdContactedOnly
            }, sort: sortOrder)
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
            let person = Prospect(name: details[0], emailAddress: details[1], isContacted: false, lastContacted: nil)
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
    
    func addNotification(for prospect: Prospect){
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
//            var dateComponents = DateComponents()
//            dateComponents.hour = 9
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else if let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

#Preview {
    ProspectsView(filter: .none, sortOrder: [SortDescriptor(\Prospect.name)])
        .modelContainer(for: Prospect.self)
}
