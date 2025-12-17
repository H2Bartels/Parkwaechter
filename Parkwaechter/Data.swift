
//
//  Data.swift
//  Parkwaechter
//
//  Created by Benjamin Bartels on 16.12.25.
//
import Foundation

struct Flurstueck: Identifiable {
    let id = UUID()
    let wea: String        
    let gemarkung: String
    let flur: String
    let bezeichnung: String
}

let abschaltRegeln: [Flurstueck] = [

    Flurstueck(wea: "T12", gemarkung: "4021", flur: "1", bezeichnung: "13"),
    Flurstueck(wea: "T12", gemarkung: "4021", flur: "1", bezeichnung: "14"),
    Flurstueck(wea: "T12", gemarkung: "4021", flur: "1", bezeichnung: "24/1"),
    Flurstueck(wea: "T12", gemarkung: "4021", flur: "1", bezeichnung: "25"),
    Flurstueck(wea: "T12", gemarkung: "4021", flur: "1", bezeichnung: "27"),
    Flurstueck(wea: "T12", gemarkung: "4018", flur: "1", bezeichnung: "3/2"),
    Flurstueck(wea: "T12", gemarkung: "4018", flur: "2", bezeichnung: "4/1"),
    Flurstueck(wea: "T12", gemarkung: "4002", flur: "1", bezeichnung: "1/1"),
    Flurstueck(wea: "T12", gemarkung: "4002", flur: "1", bezeichnung: "10/6"),
    Flurstueck(wea: "T12", gemarkung: "4055", flur: "1", bezeichnung: "1"),

    Flurstueck(wea: "T13", gemarkung: "4055", flur: "1", bezeichnung: "1"),
    Flurstueck(wea: "T13", gemarkung: "4055", flur: "1", bezeichnung: "6"),
    Flurstueck(wea: "T13", gemarkung: "4021", flur: "1", bezeichnung: "27"),
    Flurstueck(wea: "T13", gemarkung: "4002", flur: "1", bezeichnung: "1/1"),
    Flurstueck(wea: "T13", gemarkung: "4002", flur: "1", bezeichnung: "10/6"),
    Flurstueck(wea: "T13", gemarkung: "4002", flur: "1", bezeichnung: "2/2"),
    Flurstueck(wea: "T13", gemarkung: "4018", flur: "2", bezeichnung: "4/1"),
    Flurstueck(wea: "T13", gemarkung: "4018", flur: "2", bezeichnung: "6/1"),
    Flurstueck(wea: "T13", gemarkung: "4018", flur: "2", bezeichnung: "6/3"),

    Flurstueck(wea: "T13_ohne_27", gemarkung: "4055", flur: "1", bezeichnung: "1"),
    Flurstueck(wea: "T13_ohne_27", gemarkung: "4055", flur: "1", bezeichnung: "6"),
    Flurstueck(wea: "T13_ohne_27", gemarkung: "4002", flur: "1", bezeichnung: "1/1"),
    Flurstueck(wea: "T13_ohne_27", gemarkung: "4002", flur: "1", bezeichnung: "10/6"),
    Flurstueck(wea: "T13_ohne_27", gemarkung: "4002", flur: "1", bezeichnung: "2/2"),
    Flurstueck(wea: "T13_ohne_27", gemarkung: "4018", flur: "2", bezeichnung: "4/1"),
    Flurstueck(wea: "T13_ohne_27", gemarkung: "4018", flur: "2", bezeichnung: "6/1"),
    Flurstueck(wea: "T13_ohne_27", gemarkung: "4018", flur: "2", bezeichnung: "6/3"),

    Flurstueck(wea: "K16", gemarkung: "4002", flur: "1", bezeichnung: "1/1"),
    Flurstueck(wea: "K16", gemarkung: "4021", flur: "1", bezeichnung: "24/1"),
    Flurstueck(wea: "K16", gemarkung: "4021", flur: "1", bezeichnung: "24/2"),
    Flurstueck(wea: "K16", gemarkung: "4021", flur: "1", bezeichnung: "25"),
    Flurstueck(wea: "K16", gemarkung: "4021", flur: "1", bezeichnung: "27"),
    Flurstueck(wea: "K16", gemarkung: "4055", flur: "1", bezeichnung: "1"),
    Flurstueck(wea: "K16", gemarkung: "4055", flur: "1", bezeichnung: "2"),
    Flurstueck(wea: "K16", gemarkung: "4055", flur: "1", bezeichnung: "4"),
    Flurstueck(wea: "K16", gemarkung: "4055", flur: "1", bezeichnung: "6"),

    Flurstueck(wea: "K17", gemarkung: "4021", flur: "1", bezeichnung: "24/1"),
    Flurstueck(wea: "K17", gemarkung: "4021", flur: "1", bezeichnung: "24/2"),
    Flurstueck(wea: "K17", gemarkung: "4021", flur: "1", bezeichnung: "25"),
    Flurstueck(wea: "K17", gemarkung: "4055", flur: "1", bezeichnung: "1"),
    Flurstueck(wea: "K17", gemarkung: "4055", flur: "1", bezeichnung: "2"),
    Flurstueck(wea: "K17", gemarkung: "4055", flur: "1", bezeichnung: "4"),
    Flurstueck(wea: "K17", gemarkung: "4055", flur: "1", bezeichnung: "6"),
    Flurstueck(wea: "K17", gemarkung: "4055", flur: "1", bezeichnung: "7/1"),

    Flurstueck(wea: "K18", gemarkung: "4021", flur: "1", bezeichnung: "19"),
    Flurstueck(wea: "K18", gemarkung: "4021", flur: "1", bezeichnung: "20"),
    Flurstueck(wea: "K18", gemarkung: "4021", flur: "1", bezeichnung: "21"),
    Flurstueck(wea: "K18", gemarkung: "4021", flur: "1", bezeichnung: "24/2"),
    Flurstueck(wea: "K18", gemarkung: "4055", flur: "1", bezeichnung: "2"),
    Flurstueck(wea: "K18", gemarkung: "4055", flur: "1", bezeichnung: "4"),
    Flurstueck(wea: "K18", gemarkung: "4055", flur: "1", bezeichnung: "7/1"),
    Flurstueck(wea: "K18", gemarkung: "4055", flur: "3", bezeichnung: "19/2"),
    Flurstueck(wea: "K18", gemarkung: "4055", flur: "3", bezeichnung: "20")
]


