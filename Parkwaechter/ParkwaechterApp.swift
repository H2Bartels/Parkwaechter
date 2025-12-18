//
//  ParkwaechterApp.swift
//  Parkwaechter
//
//  Created by Benjamin Bartels on 16.12.25.
//

import SwiftUI
import SwiftData
@main
struct ParkwaechterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for:Datapoint.self)
        //.defaultSize(width: 800, height: 800)
    }
}
