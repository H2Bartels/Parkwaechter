//
//  ContentView.swift
//  Parkwaechter
//
//  Created by Benjamin Bartels on 16.12.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query private var datapoints: [Datapoint]
    @State private var dataSelection = Set<Datapoint.ID>()
    //delete
    @State private var showDeleteAlert = false
    @State private var datapointsToDelete: [Datapoint] = []
    //edit
    @State private var showEditSheet = false
    @State private var datapointsToEdit: [Datapoint] = []

    @State private var kennung: [String] = []
    @State private var date = Date()

    @State private var gemarkung = ""
    @State private var flur = ""
    @State private var bezeichnung = ""
    
    var body: some View{
        TabView{
            Tab("Eingaben",systemImage: "square.and.pencil"){
                InputView(gemarkung: $gemarkung, flur: $flur, bezeichnung: $bezeichnung, kennung: $kennung, date: $date, context: context)
            }
            Tab("Protokoll",systemImage: "book"){
                ProtocolView(datapoints: datapoints, context: context, dataSelection: $dataSelection, datapointsToDelete: $datapointsToDelete, showDeleteAlert: $showDeleteAlert, datapointsToEdit: $datapointsToEdit, showEditSheet: $showEditSheet)
            }
        }
    }
}
#Preview {
    ContentView()
        //.modelContainer(for: Datapoint.self, inMemory: true)
}
