//
//  Protokoll.swift
//  Parkwaechter
//
//  Created by Benjamin Bartels on 18.12.25.
//

import Foundation
import SwiftData
import SwiftUI
import AppKit
import UniformTypeIdentifiers


struct ProtocolView: View
{
    var datapoints: [Datapoint]
    var context: ModelContext
    @Binding var dataSelection: Set<Datapoint.ID>
    @Binding var datapointsToDelete: [Datapoint]
    @Binding var showDeleteAlert: Bool
    @Binding var datapointsToEdit: [Datapoint]
    @Binding var showEditSheet: Bool
    @Binding var showExportSheet: Bool
    @Binding var csv: CSV
    var body: some View {
        VStack{
            Table(datapoints, selection: $dataSelection) {
                
                TableColumn("Jahr") { dp in
                    Text(dp.date.formatted(Date.FormatStyle().year()))
                }
                TableColumn("Datum") { dp in
                    Text(dp.date.formatted(Date.FormatStyle().month(.defaultDigits).day(.defaultDigits)))
                }
                TableColumn("Uhrzeit") { dp in
                    Text(dp.time.formatted(date: .omitted, time: .shortened))
                }
                TableColumn("Flurstücke") { dp in
                    Text(dp.relevantFlurstuecke.joined(separator: ", "))
                }
                TableColumn("WEA") { dp in
                    Text(dp.turnedOffWea.joined(separator: ", "))
                }
            }
            .contextMenu {
                Button("Löschen") {
                    datapointsToDelete = datapoints.filter { dataSelection.contains($0.id) }
                    showDeleteAlert = true
                }
                .disabled(dataSelection.isEmpty)
                /*Button("Bearbeiten") {
                 datapointsToEdit = datapoints.filter { dataSelection.contains($0.id) }
                 showEditSheet = true
                 }*/
            }
            .onDeleteCommand {
                datapointsToDelete = datapoints.filter { dataSelection.contains($0.id) }
                showDeleteAlert = true
            }
            .alert("Ausgewählte Datenpunkte löschen?", isPresented: $showDeleteAlert, actions: {
                Button("Abbrechen", role: .cancel) {}
                Button("Löschen", role: .destructive) {
                    for dp in datapointsToDelete {
                        deleteDatapoint(dp)
                    }
                    dataSelection.removeAll()
                    datapointsToDelete.removeAll()
                }
            }, message: {
                Text("Willst du wirklich \(datapointsToDelete.count) Datenpunnkt(e) löschen?")
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
                                context.insert(dp)
                            }
                            datapointsToEdit.removeAll()
                        }
                    }
                    .padding()
                }
                .frame(width: 400, height: 300)
            }
            HStack{
                Button("Exportiere Daten"){
                    csv = exportDatapointsAsCSV(datapoints)
                    showExportSheet = true
                    
                }
                Button("Daten abgespaced exportieren") {
                    csv = createMergedCSV(datapoints)
                    showExportSheet = true
                }
                Button("Daten löschen") {
                    showDeleteAlert = true
                }
            }
            .alert("Alle Datenpunkte löschen?", isPresented: $showDeleteAlert, actions: {
                Button("Abbrechen", role: .cancel) {}
                Button("Löschen", role: .destructive) {
                    for dp in datapoints {
                        deleteDatapoint(dp)
                    }
                }
            }, message: {
                Text("Willst du wirklich alle Datenpunnkte löschen?")
            })
            .fileExporter(
                        isPresented: $showExportSheet,
                        document: csv,
                        contentType: .text,
                        defaultFilename: "ParkwächterExport.csv"
                    ) { result in
                        switch result {
                        case .success(let url):
                            print("Saved to \(url)")
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
            
        }
        .padding()
    }
        
    func deleteDatapoint(_ datapoint: Datapoint){
        context.delete(datapoint)
    }
    func exportDatapointsAsCSV(_ datapoints: [Datapoint]) -> CSV {
        var csv = "Jahr,Datum,Uhrzeit,Flurstücke,WEA\n"

        for dp in datapoints {
            let jahr = dp.date.formatted(.dateTime.year())
            let datum = dp.date.formatted(.dateTime.day().month())
            let uhrzeit = dp.time.formatted(date: .omitted, time: .shortened)
            let flurstuecke = dp.relevantFlurstuecke.joined(separator: " | ")
            let wea = dp.turnedOffWea.joined(separator: " | ")
            
            csv += "\(jahr),\(datum),\(uhrzeit),\"\(flurstuecke)\",\"\(wea)\"\n"
        }
        return CSV(csv)
    }
    func createMergedCSV(_ datapoints: [Datapoint]) -> CSV {
        var csvText = "Jahr,Datum,Uhrzeit,Flurstücke,WEA\n"
        let calendar = Calendar.current

        // Erstellt ein Dictionary für schnellen Lookup nach Tag
        // Key: Tag + Monat + Jahr, Value: Datapoint(s) an diesem Tag
        let dpByDate: [String: [Datapoint]] = Dictionary(
            grouping: datapoints,
            by: { dp in
                let y = dp.date.formatted(.dateTime.year())
                let m = dp.date.formatted(.dateTime.month(.defaultDigits))
                let d = dp.date.formatted(.dateTime.day(.defaultDigits))
                return "\(y)-\(m)-\(d)"
            }
        )
        
        // Start- und Enddatum
        let startDateComponents = DateComponents(year: 2025, month: 5, day: 1, hour: 19, minute: 0)
        let endDateComponents = DateComponents(year: 2025, month: 8, day: 31, hour: 19, minute: 0)
        guard let startDate = calendar.date(from: startDateComponents),
              let endDate = calendar.date(from: endDateComponents) else {
            return CSV(csvText)
        }
        
        var currentDate = startDate
        while currentDate <= endDate {
            let y = currentDate.formatted(.dateTime.year())
            let datum = currentDate.formatted(.dateTime.day().month())
            let uhrzeit = currentDate.formatted(.dateTime.hour().minute())

            let key = currentDate.formatted(.dateTime.year()) + "-" +
                      currentDate.formatted(.dateTime.month(.defaultDigits)) + "-" +
                      currentDate.formatted(.dateTime.day(.defaultDigits))

            if let matches = dpByDate[key] {
                // Es gibt echte Daten für diesen Tag
                for dp in matches {
                    let flurstuecke = dp.relevantFlurstuecke.joined(separator: " | ")
                    let wea = dp.turnedOffWea.joined(separator: " | ")
                    csvText += "\(y),\(datum),\(uhrzeit),\"\(flurstuecke)\",\"\(wea)\"\n"
                }
            } else {
                // Kein Datapoint → leere Felder
                csvText += "\(y),\(datum),\(uhrzeit),\"\",\"\"\n"
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return CSV(csvText)
    }

}
          

