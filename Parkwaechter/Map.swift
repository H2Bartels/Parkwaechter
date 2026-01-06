//
//  Map.swift
//  Parkwaechter
//
//  Created by Benjamin Bartels on 19.12.25.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: View {
    @Binding var mapCameraPosition: MapCameraPosition
    @Binding var kennung: [String]

    private let flurstuecke: [FlurstueckPolygon] = loadFlurstueckeGeoJSON(named: "Baltic_Wind_Flurstuecke")
    private let weaArray = loadWEA(fromGeoJSON: "Baltic_Wind_WEA")
    let previewKennung: String?
    
    var body: some View {
        Map(position: $mapCameraPosition, interactionModes: [.all]) {

            let polygonsToDraw = flurstuecke
                           .flatMap { flurstueck -> [(coords: [CLLocationCoordinate2D], key: String)] in
                               let key = "\(flurstueck.gemarkung) \(flurstueck.flur) \(flurstueck.bezeichnung)"
                               return flurstueck.polygons.map { ($0, key) }
                           }
            

           // Polygone rendern
            ForEach(Array(polygonsToDraw.enumerated()), id: \.0) { _, poly in
               if poly.key == previewKennung {
                   // Aktuell ausgewählt: nur blauer Rand
                   MapPolygon(coordinates: poly.coords)
                       .foregroundStyle(Color.clear)
                       .stroke(Color.blue, lineWidth: 2)
               } else if kennung.contains(poly.key) {
                   // Gespeichert: blau gefüllt, Rand schwarz
                   MapPolygon(coordinates: poly.coords)
                       .foregroundStyle(Color.blue.opacity(0.3))
                       .stroke(Color.black, lineWidth: 1)
               } else {
                   // Normalzustand
                   MapPolygon(coordinates: poly.coords)
                       .foregroundStyle(Color.clear)
                       .stroke(Color.black, lineWidth: 1)
               }
            }

            // Labels
            ForEach(flurstuecke) { flurstueck in
                Annotation(flurstueck.bezeichnung, coordinate: flurstueck.center, anchor: .center) {
                        
                }
            }
            //WEAs
            ForEach(weaArray) { wea in
                Annotation("", coordinate: wea.coordinate, anchor: .center){
                    WEAAnnotationView(wea:wea)
                }
            }
        }
        .mapStyle(.imagery)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(15)
    }
}

struct WEAAnnotationView: View {
    let wea: WEA // dein Modell mit Name, Hersteller, Typ, etc.
    
    @State private var hovering = false
    
    var body: some View {
        ZStack {
            Image("wea_icon")
                .resizable()
                .foregroundColor(.white)
                .frame(width: 50, height: 70)
                .onHover { inside in
                    hovering = inside
                }
            
            if hovering {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Name: \(wea.name)")
                    Text("Hersteller: \(wea.hersteller)")
                    Text("Typ: \(wea.typ)")
                    Text("Nennleistung: \(String(format: "%.0f",wea.nennleistung)) kW")
                    Text("Nabenhöhe: \(String(format: "%.1f",wea.nabenhoehe))m")
                    Text("Rotordurchmesser: \(String(format: "%.1f",wea.rotordurchmesser))m")
                }
                .font(.caption2) // kleiner Schriftgrad
                    .padding(6)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .offset(x: 60, y: -20)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: 120)

            }
        }
    }
}

struct FlurstueckPolygon: Identifiable {
    let id = UUID()
    let polygons: [[CLLocationCoordinate2D]]  // Alle Teile eines Flurstücks
    let gemarkung: String
    let flur: String
    let bezeichnung: String

    /// Berechnet das Zentrum des Flurstücks (über alle Polygon-Teile)
    var center: CLLocationCoordinate2D {
        guard let largest = polygons.max(by: { polygonArea($0) < polygonArea($1) }) else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        return boundingBoxCenter(largest)
    }

    // Hilfsfunktionen
    private func polygonArea(_ coords: [CLLocationCoordinate2D]) -> Double {
        guard coords.count > 2 else { return 0 }
        var area = 0.0
        for i in 0..<coords.count {
            let j = (i + 1) % coords.count
            area += coords[i].longitude * coords[j].latitude
            area -= coords[j].longitude * coords[i].latitude
        }
        return abs(area) / 2.0
    }

    private func boundingBoxCenter(_ coords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        let lats = coords.map(\.latitude)
        let lons = coords.map(\.longitude)
        return CLLocationCoordinate2D(
            latitude: (lats.min()! + lats.max()!) / 2,
            longitude: (lons.min()! + lons.max()!) / 2
        )
    }
}

struct WEA: Identifiable {
    let id = UUID()
    let name: String
    let hersteller: String
    let typ: String
    let nennleistung: Double
    let nabenhoehe: Double
    let rotordurchmesser: Double
    let coordinate: CLLocationCoordinate2D
}

func loadFlurstueckeGeoJSON(named fileName: String) -> [FlurstueckPolygon] {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "geojson") else { return [] }

    do {
        let data = try Data(contentsOf: url)
        let decoder = MKGeoJSONDecoder()
        let geoObjects = try decoder.decode(data)
        var flurstueckeDict: [String: [[CLLocationCoordinate2D]]] = [:] // flurstueck → Polygon-Teile
        var flurstueckeProps: [String: (gemarkung: String, flur: String, bezeichnung: String)] = [:]

        for object in geoObjects {
            guard let feature = object as? MKGeoJSONFeature else { continue }

            // Daten aus Properties
            var gemarkung = ""
            var flur = ""
            var bezeichnung = ""
            var flurstueckKey = "unbekannt"

            if let jsonData = feature.properties,
               let dict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {

                gemarkung = "\(dict["gemarkungsnummer"] ?? "")"
                flur = "\(dict["flurnummer"] ?? "")"
                bezeichnung = dict["label"] as? String
                ?? dict["flurstueck"] as? String
                ?? "unbekannt"
                flurstueckKey = "\(gemarkung) \(flur) \(bezeichnung)"
            }
            


            // Geometrien
            for geometry in feature.geometry {
                if let polygon = geometry as? MKPolygon {
                    flurstueckeDict[flurstueckKey, default: []].append(polygon.coordinatesArray)
                } else if let multi = geometry as? MKMultiPolygon {
                    for i in 0..<multi.polygons.count {
                        flurstueckeDict[flurstueckKey, default: []].append(multi.polygons[i].coordinatesArray)
                    }
                }
            }

            // Properties zwischenspeichern
            flurstueckeProps[flurstueckKey] = (gemarkung, flur, bezeichnung)
        }

        // Dictionary → Array von Flurstuecken
        return flurstueckeDict.map { key, polygons in
            let props = flurstueckeProps[key] ?? ("", "", "")
            return FlurstueckPolygon(
                polygons: polygons,
                gemarkung: props.gemarkung,
                flur: props.flur,
                bezeichnung: props.bezeichnung
            )
        }

    } catch {
        print("Fehler beim Parsen: \(error)")
        return []
    }
}
func loadWEA(fromGeoJSON fileName: String) -> [WEA] {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "geojson") else {
        print("Datei \(fileName).geojson nicht gefunden")
        return []
    }

    do {
        let data = try Data(contentsOf: url)
        let decoder = MKGeoJSONDecoder()
        let geoObjects = try decoder.decode(data)
        var weaList: [WEA] = []

        for object in geoObjects {
            guard let feature = object as? MKGeoJSONFeature else { continue }

            // Properties parsen
            var name = "unbekannt"
            var hersteller = ""
            var typ = ""
            var nennleistung: Double = 0
            var nabenhoehe: Double = 0
            var rotordurchmesser: Double = 0

            if let jsonData = feature.properties,
               let dict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {

                name = dict["Name"] as? String ?? name
                hersteller = dict["Herstellerin"] as? String ?? ""
                typ = dict["Typ"] as? String ?? ""
                nennleistung = dict["Nennleistung (kW)"] as? Double ?? 0
                nabenhoehe = dict["Nabenhöhe (m)"] as? Double ?? 0
                rotordurchmesser = dict["Rotordurchmesser (m)"] as? Double ?? 0
            }

            // Koordinaten extrahieren (nur Point)
            for geometry in feature.geometry {
                if let point = geometry as? MKPointAnnotation {
                    let wea = WEA(
                        name: name,
                        hersteller: hersteller,
                        typ: typ,
                        nennleistung: nennleistung,
                        nabenhoehe: nabenhoehe,
                        rotordurchmesser: rotordurchmesser,
                        coordinate: point.coordinate
                    )
                    weaList.append(wea)
                }
                // GeoJSON MKPoint wird als MKMultiPoint mit 1 Punkt geliefert
                else if let mp = geometry as? MKMultiPoint {
                    if mp.pointCount > 0 {
                        let coord = mp.points()[0].coordinate
                        let wea = WEA(
                            name: name,
                            hersteller: hersteller,
                            typ: typ,
                            nennleistung: nennleistung,
                            nabenhoehe: nabenhoehe,
                            rotordurchmesser: rotordurchmesser,
                            coordinate: coord
                        )
                        weaList.append(wea)
                    }
                }
            }
        }

        return weaList
    } catch {
        print("Fehler beim Parsen der GeoJSON: \(error)")
        return []
    }
}



extension MKPolygon {
    var coordinatesArray: [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = []
        let count = self.pointCount
        let points = self.points()
        for i in 0..<count {
            coords.append(points[i].coordinate)
        }
        return coords
    }
}

