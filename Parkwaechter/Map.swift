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
    private let flurstuecke: [FlurstueckPolygon] = loadFlurstueckeGeoJSON(named: "Baltic_Wind_Flurstuecke")

    var body: some View{
        
        
        Map(position: $mapCameraPosition) {
            ForEach(flurstuecke,id: \.id) { flurstueck in
                MapPolygon(coordinates: flurstueck.coordinates)
                    .foregroundStyle(Color.white.opacity(0))
                    .stroke(Color.black, lineWidth: 1)
                
                Annotation(flurstueck.label, coordinate: flurstueck.center, anchor: .center)
                {
                    
                }
                
            }
        }
            
                .mapStyle(.imagery)
                .frame(width: 300,height: 250)
                .cornerRadius(15)
                
    }
}

struct FlurstueckPolygon: Identifiable {
    let id = UUID()
    let coordinates: [CLLocationCoordinate2D]
    let label: String

    /// Berechnet den Mittelpunkt des Polygons für Annotationen
    var center: CLLocationCoordinate2D {
        guard !coordinates.isEmpty else { return CLLocationCoordinate2D(latitude: 0, longitude: 0) }
        
        // Bounding Box Methode
        let lats = coordinates.map(\.latitude)
        let lons = coordinates.map(\.longitude)
        let minLat = lats.min() ?? 0
        let maxLat = lats.max() ?? 0
        let minLon = lons.min() ?? 0
        let maxLon = lons.max() ?? 0
        
        return CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
    }
}

func loadFlurstueckeGeoJSON(named fileName: String) -> [FlurstueckPolygon] {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "geojson") else { return [] }
    
    do {
        let data = try Data(contentsOf: url)
        let decoder = MKGeoJSONDecoder()
        let objects = try decoder.decode(data)
        
        var polygons: [FlurstueckPolygon] = []
        
        for object in objects {
            guard let feature = object as? MKGeoJSONFeature else { continue }
            var label = ""
                     if let jsonData = feature.properties {
                         let dict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
                         label = dict?["label"] as? String ?? "unbekannt"
                     }
            for geometry in feature.geometry {
                if let polygon = geometry as? MKPolygon {
                    polygons.append(FlurstueckPolygon(coordinates: polygon.coordinatesArray, label: label))
                } else if let multi = geometry as? MKMultiPolygon {
                    for i in 0..<multi.polygons.count {
                        polygons.append(FlurstueckPolygon(coordinates: multi.polygons[i].coordinatesArray, label: label))
                    }
                }
            }
        }
        return polygons
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
