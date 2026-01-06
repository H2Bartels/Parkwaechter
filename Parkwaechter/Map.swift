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
        }
        .mapStyle(.imagery)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(15)
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

