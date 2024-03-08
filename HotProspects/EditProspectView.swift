//
//  EditProspect.swift
//  HotProspects
//
//  Created by Henrieke Baunack on 3/7/24.
//

import SwiftUI

struct EditProspectView: View {
    @Bindable var prospect: Prospect
    var body: some View {
        Form {
            TextField("Name", text: $prospect.name)
            TextField("Email Address", text: $prospect.emailAddress)
        }
        Text(prospect.name)
    }
}

#Preview {
    EditProspectView(prospect: Prospect(name: "Henny", emailAddress: "Henny@something.com", isContacted: true))
}
