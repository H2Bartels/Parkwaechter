//
//  CSV.swift
//  Parkwaechter
//
//  Created by Benjamin Bartels on 19.12.25.
//
import UniformTypeIdentifiers
import SwiftUI

struct CSV: FileDocument {
    var text: String = ""

    init(_ text: String = "") {
        self.text = text
    }
    
    static var readableContentTypes: [UTType] = [.text]
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
