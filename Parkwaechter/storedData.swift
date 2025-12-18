//
//  storedData.swift
//  Parkwaechter
//
//  Created by Benjamin Bartels on 17.12.25.
//

import Foundation
import SwiftData

@Model

class Datapoint: Identifiable{
    var id: String
    var date: Date
    var time: Date
    var turnedOff: Bool
    var relevantFlurstuecke: [String]
    var turnedOffWea:[String]
    
    
    init(date:Date, time:Date, turnedOff: Bool = true, relevantFlurstuecke: [String],turnedOffWea:[String]){
        self.id = UUID().uuidString
        self.date = date
        self.time = time
        self.turnedOff = turnedOff
        self.relevantFlurstuecke=relevantFlurstuecke
        self.turnedOffWea=turnedOffWea
    }
}

