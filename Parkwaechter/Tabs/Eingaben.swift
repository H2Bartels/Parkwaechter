//
//  Eingaben.swift
//  Parkwaechter
//
//  Created by Benjamin Bartels on 18.12.25.
//
import Foundation
import SwiftUI
import SwiftData

struct InputView: View
{
    @Binding var gemarkung: String
    @Binding var flur: String
    @Binding var bezeichnung: String
    @Binding var kennung: [String]
    @Binding var date: Date
    @Binding var abgeschalteteWEA: [String]
    var context: ModelContext
    
    
    let gemarkungen = Array(Set(abschaltRegeln.map({$0.gemarkung}))).sorted()
    let fluren = Array(Set(abschaltRegeln.map({$0.flur}))).sorted()
    let bezeichnungen = Array(Set(abschaltRegeln.map({$0.bezeichnung}))).sorted()



    var body: some View {
        HStack(alignment: .top, spacing: 10){
            VStack(alignment: .leading,spacing: 20){
                Grid(horizontalSpacing: 15, verticalSpacing: 12) {
                    GridRow {
                        Text("Gemarkung:")
                            .frame(maxWidth: 100,alignment: .leading)
                        HStack{
                            Picker("", selection: $gemarkung) {
                                ForEach(gemarkungen, id: \.self) { Text($0) }
                            }
                            .pickerStyle(.menu)
                            Spacer()
                        }
                    }
                    GridRow {
                        Text("Flur:")
                            .frame(maxWidth: 100, alignment: .leading)
                        HStack{
                            Picker("", selection: $flur) {
                                ForEach( gefilterteFluren(gemarkung: gemarkung, bezeichnung: bezeichnung), id: \.self) { Text($0) }
                            }
                            .pickerStyle(.menu)
                            Spacer()
                        }
                    }
                    GridRow {
                        Text("Flurstück:")
                            .frame(maxWidth: 100,alignment: .leading)
                        HStack{
                            Picker("", selection: $bezeichnung) {
                                ForEach(gefilterteBezeichnungen(gemarkung: gemarkung, flur: flur), id: \.self) { Text($0) }
                            }
                            .pickerStyle(.menu)
                            Spacer()
                        }
                    }
                }
                HStack{
                    Button("Hinzufügen"){
                        let current_kennung = "\(gemarkung) \(flur) \(bezeichnung)"
                        kennung.append(current_kennung)
                        abgeschalteteWEA = Array(abgeschalteteWEA+weaFuerKennung(current_kennung)).sorted()
                    }
                    .disabled(
                        kennung.contains("\(gemarkung) \(flur) \(bezeichnung)") ||
                        gemarkung.isEmpty ||
                        flur.isEmpty ||
                        bezeichnung.isEmpty
                    )
                    Button("Rückgängig"){
                        let removedKennung = kennung.removeLast()
                        let zuEntfernen = weaFuerKennung(removedKennung)
                        for wea in zuEntfernen {
                            if let index = abgeschalteteWEA.lastIndex(of: wea) {
                                abgeschalteteWEA.remove(at: index)
                            }
                        }
                    }
                    .disabled(kennung.isEmpty)
                }
                .padding(.top,10)
                Text("Ausgewählte Flurstücke:")
                ScrollView{
                    VStack(alignment: .leading, spacing: 0){
                        ForEach(Array(kennung.enumerated()), id: \.1) { index, entry in
                            Text(entry)
                                .padding(.leading, 15)
                                .padding(.top, index == 0 ? 5 : 0)
                        }
                    }
                }
                .frame(maxWidth: 250,minHeight: 100,maxHeight: 100, alignment: .leading)
                .background(Color.gray.opacity(0.2))
                .mask(Rectangle().cornerRadius(15).frame(height: 100))
                
                
                
                Grid(horizontalSpacing: 15, verticalSpacing: 12){
                    GridRow{
                        Text("Uhrzeit:")
                            .frame(maxWidth: 100,alignment: .leading)
                        HStack {
                            DatePicker(
                                "",
                                selection: $date,
                                displayedComponents: [.hourAndMinute]
                            )
                            .frame(width: 250, alignment: .leading) // unbedingt alignment setzen
                            
                            Spacer() // schiebt den Rest nach rechts, Picker bleibt links
                        }
                    }
                    GridRow{
                        Text("Datum:")
                            .frame(maxWidth: 100,alignment: .leading)
                        HStack {
                            DatePicker(
                                "",
                                selection: $date,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.compact) // oder .graphical
                            .frame(width: 250, alignment: .leading) // unbedingt alignment setzen
                            
                            Spacer() // schiebt den Rest nach rechts, Picker bleibt links
                        }
                    }
                }
                Button("Speichern") {
                    addDatapoint(date: date, time: date,relevantFlurstuecke: kennung, turnedOffWea: Array(Set(abgeschalteteWEA)).sorted())
                }
                /* VStack(alignment: .leading, spacing: 0) {
                 ForEach(kennung, id: \.self) { entry in
                 if let wea = weaFuerKennung(entry) {
                 Text("WEA: \(wea) – \(entry)")
                 } else {
                 Text("Keine WEA gefunden für \(entry)")
                 }
                 }
                 }*/
            }
            VStack{
                let alleWEA = ["T12", "T13", "K16", "K17", "K18"]
                HStack(spacing: 20) {
                    ForEach(alleWEA, id: \.self) { wea in
                        VStack (spacing: 30){
                            Text(wea)
                                .frame(width: 40, height: 20)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                            
                            // Platzhalter für die Lampe (später)
                            Circle()
                                .fill(Set(abgeschalteteWEA).contains(wea)
                                 ? Color.red : Color.green)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    func addDatapoint(date: Date,time:Date,relevantFlurstuecke: [String],turnedOffWea:[String]){
        let datapoint = Datapoint(date:date,time:time,relevantFlurstuecke:relevantFlurstuecke,turnedOffWea:turnedOffWea)
        context.insert(datapoint)
    }
}
