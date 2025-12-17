//
//  weaFinder.swift
//  Parkwaechter
//
//  Created by Benjamin Bartels on 16.12.25.
//
func weaFuerKennung(_ kennungString: String) -> [String] {
    // Aufteilen in Bestandteile: gemarkung, flur, bezeichnung
    let teile = kennungString.split(separator: " ").map { String($0) }
    guard teile.count == 3 else { return [] }
    
    let gemarkung = teile[0]
    let flur = teile[1]
    let bezeichnung = teile[2]
    
    return abschaltRegeln.filter {
        
        $0.gemarkung == gemarkung &&
        $0.flur == flur &&
        $0.bezeichnung == bezeichnung
    }.map{$0.wea}
}


