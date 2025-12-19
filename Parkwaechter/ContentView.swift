//
//  ContentView.swift
//  Parkwaechter
//
//  Created by Benjamin Bartels on 16.12.25.
//

import SwiftUI
import SwiftData
import MapKit

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
    
    @State private var showExportSheet = false
    @State private var csv: CSV = CSV("")
    
    @State private var kennung: [String] = []
    @State private var date = Date()
    @State private var abgeschalteteWEA: [String] = []

    @State private var gemarkung = ""
    @State private var flur = ""
    @State private var bezeichnung = ""
    
    //map
    @State private var mapCameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 54.149686, longitude: 10.924739), // Schlag hinter Hof Körnick
            span: MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)// Zoom-Level
            )
        )

    var body: some View{
        TabView{
            Tab("Eingaben",systemImage: "square.and.pencil"){
                InputView(gemarkung: $gemarkung, flur: $flur, bezeichnung: $bezeichnung, kennung: $kennung, date: $date,abgeschalteteWEA:$abgeschalteteWEA, context: context, mapCameraPosition: $mapCameraPosition)
            }
            Tab("Protokoll",systemImage: "book"){
                ProtocolView(datapoints: datapoints, context: context, dataSelection: $dataSelection, datapointsToDelete: $datapointsToDelete, showDeleteAlert: $showDeleteAlert, datapointsToEdit: $datapointsToEdit, showEditSheet: $showEditSheet,showExportSheet: $showExportSheet,csv: $csv)
            }
        }
    }
}
#Preview {
    ContentView()
        //.modelContainer(for: Datapoint.self, inMemory: true)
}
