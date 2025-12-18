//
//  Protokoll.swift
//  Parkwaechter
//
//  Created by Benjamin Bartels on 18.12.25.
//

import Foundation
import SwiftData
import SwiftUI

struct ProtocolView: View
{
    var datapoints: [Datapoint]
    var context: ModelContext
    @Binding var dataSelection: Set<Datapoint.ID>
    @Binding var datapointsToDelete: [Datapoint]
    @Binding var showDeleteAlert: Bool
    @Binding var datapointsToEdit: [Datapoint]
    @Binding var showEditSheet: Bool
    
    var body: some View {
        List(selection: $dataSelection){
                ForEach(datapoints, id: \.id){ datapoint in
                    Text( "\(datapoint.date.formatted(date: .numeric, time:.omitted)) | \(datapoint.time.formatted(date: .omitted, time:.shortened)) |\(datapoint.relevantFlurstuecke)|\(datapoint.turnedOffWea)"
                    )
                    .contextMenu {
                        Button("Löschen") {
                            // alle ausgewählten IDs durchgehen
                            datapointsToDelete = datapoints.filter { dataSelection.contains($0.id) }
                            showDeleteAlert = true
                        }
                        .disabled(dataSelection.isEmpty) // optional: Button nur aktiv, wenn etwas ausgewählt ist
                        /*Button("Bearbeiten"){
                            datapointsToEdit = datapoints.filter { dataSelection.contains($0.id) }
                            showEditSheet = true
                        }*/
                    }
                }
            }
            .padding()
            .focusable()
            .onDeleteCommand{
                datapointsToDelete = datapoints.filter { dataSelection.contains($0.id) }
                showDeleteAlert = true
            }
            .alert("Datapoints löschen?", isPresented: $showDeleteAlert, actions: {
                Button("Abbrechen", role: .cancel) { }
                Button("Löschen", role: .destructive) {
                    for dp in datapointsToDelete {
                        deleteDatapoint(dp)
                    }
                    dataSelection.removeAll()
                    datapointsToDelete.removeAll()
                    showDeleteAlert = false
                }
            }, message: {
                Text("Willst du wirklich \(datapointsToDelete.count) Datapoint(s) löschen?")
            })
            .sheet(isPresented: $showEditSheet) {
                VStack(spacing: 20) {
                    Text("Bearbeite ausgewählte Datapoints")
                        .font(.headline)

                    List {
                        ForEach($datapointsToEdit, id: \.id) { $dp in
                            TextField("Flurstücke", text: Binding(
                                get: { dp.relevantFlurstuecke.joined(separator: ", ") },
                                set: { dp.relevantFlurstuecke = $0.components(separatedBy: ", ") }
                            ))
                        }
                    }
                    HStack {
                        Button("Abbrechen") { showEditSheet = false }
                        Button("Speichern") {
                            for dp in datapointsToEdit {
                                context.insert(dp) // oder einfach Context speichert Änderungen automatisch
                            }
                            showEditSheet = false
                            datapointsToEdit.removeAll()
                        }
                    }
                    .padding()
                }
                .frame(width: 400, height: 300)
                
            }
            
        }
        
        func deleteDatapoint(_ datapoint: Datapoint){
        context.delete(datapoint)
        }
    }
          

