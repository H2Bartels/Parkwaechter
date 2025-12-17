//
//  weaFinder.swift
//  Parkwaechter
//
//  Created by Benjamin Bartels on 16.12.25.
//
func weaFuerKennung(_ kennungString: String) -> String? {
    // Aufteilen in Bestandteile: gemarkung, flur, bezeichnung
    let teile = kennungString.split(separator: " ").map { String($0) }
    guard teile.count == 3 else { return nil }
    
    let gemarkung = teile[0]
    let flur = teile[1]
    let bezeichnung = teile[2]
    
    // In abschaltRegeln nach dem passenden Flurstueck suchen
    if let flurstueck = abschaltRegeln.first(where: {
        $0.gemarkung == gemarkung &&
        $0.flur == flur &&
        $0.bezeichnung == bezeichnung
    }) {
        return flurstueck.wea
    } else {
        return nil
    }
}


