//
//  Prospect.swift
//  HotProspects
//
//  Created by Henrieke Baunack on 2/3/24.
//

import SwiftData

// defining data model for one prospect

@Model
class Prospect {
    var name: String
    var emailAddress: String
    var isContacted: Bool
    
    init(name: String, emailAddress: String, isContacted: Bool) {
        self.name = name
        self.emailAddress = emailAddress
        self.isContacted = isContacted
    }
}
