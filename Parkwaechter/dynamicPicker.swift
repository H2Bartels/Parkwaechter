//
//  dynamicPicker.swift
//  Parkwaechter
//
//  Created by Benjamin Bartels on 16.12.25.
//

import Foundation

func gefilterteGemarkungen(
    flur: String,
    bezeichnung: String
) -> [String] {
    Array(Set(
        abschaltRegeln
            .filter {
                (flur.isEmpty || String($0.flur) == flur) &&
                (bezeichnung.isEmpty || $0.bezeichnung == bezeichnung)
            }
            .map { String($0.gemarkung) }
    )).sorted()
}

func gefilterteFluren(
    gemarkung: String,
    bezeichnung: String
) -> [String] {
    let result =  Array(Set(
        abschaltRegeln
            .filter {
                (gemarkung.isEmpty || String($0.gemarkung) == gemarkung) &&
                (bezeichnung.isEmpty || $0.bezeichnung == bezeichnung)
            }
            .map { String($0.flur) }
    )).sorted()
    if result.isEmpty{
        return Array(Set(abschaltRegeln.filter{String($0.gemarkung) == gemarkung}.map{String($0.flur)})).sorted()
    }
    else {
        return result
    }
}

func gefilterteBezeichnungen(
    gemarkung: String,
    flur: String
) -> [String] {
    let result = Array(Set(
        abschaltRegeln
            .filter {
                (gemarkung.isEmpty || String($0.gemarkung) == gemarkung) &&
                (flur.isEmpty || String($0.flur) == flur)
            }
            .map { $0.bezeichnung }
    )).sorted()
    if result.isEmpty{
        return Array(Set(abschaltRegeln.filter{String($0.gemarkung) == gemarkung}.map{String($0.bezeichnung)})).sorted()
    }
    else {
        return result
    }
}
