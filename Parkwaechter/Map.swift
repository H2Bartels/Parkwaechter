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
    
    var body: some View{
        
        Map(position: $mapCameraPosition) {
                    // Hier können Pins, Polygone, Overlays später hinzugefügt werden
                }
                .mapStyle(.imagery)           // Jetzt geht mapStyle direkt
                .frame(width: 300,height: 250)
                .cornerRadius(15)
                
    }
}

